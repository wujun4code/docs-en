

// size format
(function() {
    var prettyBytes = function(num) {
        if (typeof num !== 'number') {
            throw new TypeError('Input must be a number');
        }

        var exponent;
        var unit;
        var neg = num < 0;

        if (neg) {
            num = -num;
        }

        if (num === 0) {
            return '0 B';
        }

        exponent = Math.floor(Math.log(num) / Math.log(1000));
        num = (num / Math.pow(1000, exponent)).toFixed(2) * 1;
        unit = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'][exponent];

        return (neg ? '-' : '') + num + ' ' + unit;
    };

    if (typeof module !== 'undefined' && module.exports) {
        module.exports = prettyBytes;
    } else {
        window.prettyBytes = prettyBytes;
    }
})();



// doc search
$(function() {
    $(".search-form input").keyup(function(event) {
        if ($(event).keyCode == 13) {
            $(this).parents("form.search-form").submit()
        }
    });
});

function openWindow(url, title, w, h) {
   wLeft = window.screenLeft ? window.screenLeft : window.screenX;
   wTop = window.screenTop ? window.screenTop : window.screenY;
   var left = wLeft + (window.innerWidth / 2) - (w / 2);
   var top = wTop + (window.innerHeight / 2) - (h / 2);
   return window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
}



