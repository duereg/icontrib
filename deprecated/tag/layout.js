//
// Layout with hugging and spooning
//

// All combinators are of type "Maybe attrs -> Array a -> Maybe a -> a"
//
// hug(  ['a','b','c'])       === 'abc'
// hug(  ['a','b','c'], ' ')  === 'a b c'
// spoon(['a','b','c'])       === 'a\nb\nc'
// spoon(['a','b','c'], '\n') === 'a\n\nb\n\nc'

var deps = [
    'tag.js',
    '/jquery/jquery-mod.js'
];

function onReady(E, $) {

    // Concatenate elements
    function concat(as, xs, pad, isVert) {
        pad = pad || 0;
        var e = E.div(as);
        for (var i = 0; i < xs.length; i++) {
            var x = xs[i];
            if (x.constructor !== Pillow) {
                e.appendChild(x);
            }
        }
        $(e).ready(function() { 
        setTimeout(function(){  // Awful workaround to get Safari and Chrome to render after images have been loaded
            var height = 0;
            var width = 0;
            for (var i = 0; i < xs.length; i++) {
               var x = xs[i];
               var h, w = 0;
               if (x.constructor === Pillow) {
                   h = x.height;
                   w = x.width;
               } else {
                   x.style.position = 'absolute';
                   if (isVert) {
                       x.style.top = height + 'px';
                       x.style.left = 0;
                   } else {
                       x.style.left = width + 'px';
                       x.style.top = 0;
                   }
                   h = $(x).height();
                   w = $(x).width();
               }
               if (isVert) {
                   height = height + pad + h;
                   width = w > width ? w : width;
               } else {
                   width = width + pad + w;
                   height = h > height ? h : height;
               }
            }
            if (isVert) {
                height = xs.length > 0 ? height - pad : 0;
            } else {
                width = xs.length > 0 ? width - pad : 0;
            }
            e.style.height = height;
            e.style.width = width;
        }, 10);
        });
        return e;
    }

    // Concatenate elements horizontally, adding 'pad' pixels between each element
    function hug(as, xs, pad) {
        if (as && as.constructor === Array) {
            pad = xs;
            xs = as;
            as = null;
        }
        return concat(as, xs, pad, false);
    }
    
    // Concatenate elements vertically, adding 'pad' pixels between each element
    function spoon(as, xs, pad) {
        if (as && as.constructor === Array) {
            pad = xs;
            xs = as;
            as = null;
        }
        return concat(as, xs, pad, true);
    }

    function Pillow(w, h) {
        this.width = w;
        this.height = h;
    }

    // Create empty space of 'w' pixels wide and 'h' pixels tall.  Pillow elements 
    // are not added to the DOM, and are only used for managing space.
    function pillow(w, h) {
        if (h === undefined) {
            h = w;
        }
        return new Pillow(w, h);
    }

    define({
        hug:    hug,
        spoon:  spoon,
        pillow: pillow
    });
}


require(deps, onReady);

