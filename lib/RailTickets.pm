package RailTickets;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::DBIC 'schema';
use Dancer2::Plugin::Ajax;
use Dancer2::Plugin::Emailesque;
use Dancer2::Plugin::UnicodeNormalize;
use Dancer2::Session::Cookie;
use Digest::SHA1 qw/sha1_hex/;
use Data::UUID;
use MIME::Base64;
use Email::Valid;
use Encode;
use HTML::Entities;
use List::MoreUtils qw/uniq/;
use Try::Tiny;
use URI;
use POSIX 'strftime';

our $version = '0.00000';

my $filters = {
    encode_entities => sub { my $t = shift; HTML::Entities::encode_entities( $t, '<>&\'"'); return $t },
    newline_to_br => sub { my $t = shift; $t =~ s#\n#<br />#g; return $t; },
    url_encode => sub { my $t = shift; $t = URI->new($t)->as_string; $t =~ s/'/%27/; return $t; },
};

sub activation_hash {
    my ($user) = @_;
    return sha1_hex(encode('UTF-8', $user->email . $user->login . config->{'email_secret'}));
}

sub rt_template {
    my $template = shift;
    template $template => {
        appname => config->{'appname'},
        tagline => config->{'tagline'},
        %{$filters},
        %{$_[0]},
    }
}

sub email_confirmation {
    my ($user) = @_;
    my $hash = activation_hash($user);
    my $email = template 'email/registration' => {
        user => $user,
        url  => config->{'base_url'},
        site_admin => config->{'site_admin'},
        admin_mail => config->{'admin_mail'},
        activate_url => config->{'base_url'} . 'a/' . $user->id . "/$hash",
    },
    { layout => undef };

    email { to => $user->email,
            subject => config->{'appname'} . " new account registration confirmation",
            message => $email,
            type => 'text',
    };

}

ajax '/tags' => sub {
    my $schema = schema('default');
    my $tag = params->{'query'};
    my @tags = map { $_->name } $schema->resultset('Tag')->search( { name => { like => "$tag%" } } );

    return {
        query => "Unit",
        suggestions => \@tags,
    }
};

get '/' => sub {
    my $user_id = session 'id';
    my $schema = schema('default');
    my $user = $schema->resultset('User')->find($user_id);
    ($user) && redirect '/bookmarks';
    rt_template 'index' => {
    };
};

get '/register' => sub {
    my $user_id = session 'id';
    my $schema = schema('default');
    my $user = ($user_id && $schema->resultset('User')->find($user_id));
    ($user) && redirect '/';

    rt_template 'register' => {
        err_login => param('err_login'),
        err_email => param('err_email'),
        err_email1 => param('err_email1'),
        err_pwd => param('err_pwd'),
        err_pwd1 => param('err_pwd1'),
        login => param('login'),
        email => param('email'),
        email1 => param('email1'),
    };
};

post '/register' => sub {
    my $schema = schema('default');
    my %err;

    if (!param('login')) {
        $err{ err_login } = "You must give a user name";
    }
    elsif (param('login') =~  /[^\p{Alnum}]/) {
        $err{ err_login } = "Usernames may be alphanumeric only";
    }
    elsif ($schema->resultset('User')->find( { login => param('login') } )) {
        $err{ err_login } = "Sorry, this username has been taken";
    }

    if (!param('email')) {
        $err{ err_email } = "You must give an email address";
    }
    elsif (!Email::Valid->address(param('email1'))) {
        $err{ err_email }  = "<a href='https://metacpan.org/module/Email::Valid'>Email::Valid</a> claims this address is invalid. If this is not the case, please email <a href='mailto:john\@jbrt.org'>john\@jbrt.org</a>";
    }
    elsif ($schema->resultset('User')->find( { email => param('email') } )) {
        $err{ err_email }  = "Sorry, this email address is in use by another user";
    }
    elsif (param('email') ne param('email1')) {
        $err{ err_email1 } = "Email addresses do not match";
    }

    if (!param('password')) {
        $err{ err_pwd } = "You must give a password";
    }
    elsif (param('password') ne param('password1')) {
        $err{ err_pwd1 } = "Passwords do not match";
    }

    (%err) && return forward "/register", { %err }, { method => 'get'};

    try {
        my $user = $schema->resultset('User')->create({
            login => param('login'),
            email => param('email'),
            password => param('password'),
            preferences => ({ results => config->{'results_per_page'} }),
            joined => time,
            activated => 0,
        });
        email_confirmation($user);

        return rt_template 'message' => {
            message => "Thanks for registering! Please check your email for confirmation link.",
            success => 1,
            homelink => 1,
        }
    }
    catch {
        error $_;
        return rt_template 'message' => { message => strftime(localtime) . " : Something terrible happened", failure => 1 };
    };
};

get '/a/:user/:emailhash' => sub {
    my $schema = schema('default');
    my $user = $schema->resultset('User')->find(param('user'));
    (!$user) && return rt_template 'message' => { message => "User not known", failure => 1 };

    ($user->activated) && return rt_template 'message' => { message => "User already activated", warning => 1 };
    (param('emailhash') ne activation_hash($user)) &&
        return rt_template 'message' => { message => "Invalid activation URL", failure => 1 };
    $user->update( { activated => 1 } );
    rt_template 'message' => { message => "User account activated. Thank you.", success => 1 };
};

get '/bookmarks' => sub {
    forward '/bookmarks/1';
};

get '/bookmarks/:page' => sub {
    my $schema = schema('default');
    my $user_id = session 'id';
    my $user = $schema->resultset('User')->find($user_id);
    ($user) || return redirect '/';

    my $page = param('page') || 1;
    my $results = ($user->preferences->{'results'}) || config->{'results_per_page'} || 10;

    rt_template 'bookmarks' => {
        user => $user,
        bookmarks => ($user) ?
            [ $schema->resultset('Bookmark')->page_for_user($user_id, $page, $results) ] :
            (),
    };
};

# passing a :url as a route parameter, even encoded, seems to want to match '/' and '%2F', so...
# request: /add?url=http://example.com/
get '/add' => sub {
    my $schema = schema('default');
    my $user_id = session 'id';
    my $user = $schema->resultset('User')->find($user_id);
    my $url = param('url');

    ($user) || return redirect '/login?redir=/add?url=' . $url;

    rt_template 'bookmarks_form' => {
        url => param('url'),
    };
};

get '/login' => sub {
    my $schema = schema('default');
    my $user_id = session 'id';
    my $user = $schema->resultset('User')->find($user_id);
    ($user) || return redirect '/';

    my $redir = param('redir');
    rt_template 'login_form' => {
        redir => $redir,
    };
};

get '/tag/**' => sub { # megasplat to allow '/' in tags, or not. http://en.wikipedia.org/wiki/Either/Or
    my $schema = schema('default');
    my $user_id = session 'id';
    my $user = $schema->resultset('User')->find($user_id);
    ($user) || return redirect '/';

    my ($tag) = splat; $tag = join '/', @{$tag};
    my $page = param('page');
    my $results = ($user->preferences->{'results'}) || config->{'results_per_page'} || 10;

    rt_template 'bookmarks' => {
        user => $user,
        bookmarks => ($user) ?
            [ $schema->resultset('Bookmark')->page_for_user_tag($user_id, $page, $results, $tag) ] :
            (),
    };
};

post '/bookmarks' => sub {
    my $schema = schema('default');
    my $user_id = session 'id';
    my $user = $schema->resultset('User')->find($user_id);
    ($user) || return redirect '/';

    try {
        my $bookmark = $schema->resultset('Bookmark')->create({
            url => param('url'),
            title => param('title'),
            description => param('description'),
            user_id => $user_id + 0,
            private => 1,
            read => 0,
            timestamp => time,
        });
        $bookmark->add_to_tags( name => $_ ) for uniq map { $_ =~ /^\s*(.*?)\s*$/ } (split ',', param('tags') );
    } catch {
        die $_;
    };

    redirect '/bookmarks/1';
};

get '/logout' => sub {
    session->expires(-1);
    redirect '/';
};

post '/login' => sub {
    my $schema = schema('default');
    my $login  = param('login');
    my $password  = param('password');
    my $redir = param('redir') || '/bookmarks';
    ($redir =~ /^\//) || ($redir = '/bookmarks');
    my $user = $schema->resultset('User')->find( { login => $login } );

    ($user) ||
        return rt_template 'message' => { message => 'Incorrect username or password', failure => 1 };
    ($user->check_password($password)) ||
        return rt_template 'message' => { message => 'Incorrect username or password', failure => 1 };
    ($user->activated) ||
        return rt_template 'message' => { message => "User not activated, please check your email for activation URL", warning => 1 };

    session user => $login;
    session id => $user->id;
    session token => sha1_hex(Data::UUID->new()->create_str() . encode_base64 rand);

    redirect $redir;
};

1;

