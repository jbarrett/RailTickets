$(document).ready(function() {
    $('#tags').autocomplete({
        serviceUrl: '/tags',
        minChars: 2,
        delimiter: ','
    });
});

