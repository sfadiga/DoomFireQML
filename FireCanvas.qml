import QtQuick 2.0

Canvas {
    id: canvas

    property var ctx

    // Palette based framebuffer. Coordinate system origin upper-left.
    property var firePixels : []

    property var rgbs : [ 0x07,0x07,0x07, 0x1F,0x07,0x07, 0x2F,0x0F,0x07, 0x47,0x0F,0x07, 0x57,0x17,0x07,
        0x67,0x1F,0x07, 0x77,0x1F,0x07, 0x8F,0x27,0x07, 0x9F,0x2F,0x07, 0xAF,0x3F,0x07,
        0xBF,0x47,0x07, 0xC7,0x47,0x07, 0xDF,0x4F,0x07, 0xDF,0x57,0x07, 0xDF,0x57,0x07,
        0xD7,0x5F,0x07, 0xD7,0x5F,0x07, 0xD7,0x67,0x0F, 0xCF,0x6F,0x0F, 0xCF,0x77,0x0F,
        0xCF,0x7F,0x0F, 0xCF,0x87,0x17, 0xC7,0x87,0x17, 0xC7,0x8F,0x17, 0xC7,0x97,0x1F,
        0xBF,0x9F,0x1F, 0xBF,0x9F,0x1F, 0xBF,0xA7,0x27, 0xBF,0xA7,0x27, 0xBF,0xAF,0x2F,
        0xB7,0xAF,0x2F, 0xB7,0xB7,0x2F, 0xB7,0xB7,0x37, 0xCF,0xCF,0x6F, 0xDF,0xDF,0x9F,
        0xEF,0xEF,0xC7, 0xFF,0xFF,0xFF ]


    onCanvasSizeChanged: {
        timer.stop()
        if(ctx) {
            setup()
            ctx.fillStyle = "black";
            ctx.fillRect(0, 0, width, height);
        }
    }

    onAvailableChanged: {
        if (available) {
            setup()
            ctx = getContext('2d');
            ctx.fillStyle = "black";
            ctx.fillRect(0, 0, width, height);
        }
    }

    onPaint: {
        if (!ctx)
            return

        var fireData = ctx.getImageData(0, 0, width, height)
        for(var y = 0 ; y < height ; y++) {
            for(var x = 0 ; x < width ; x++) {
                var index = firePixels[y * width + x];
                var r = rgbs[index * 3 + 0]
                var g = rgbs[index * 3 + 1]
                var b = rgbs[index * 3 + 2]

                fireData.data[((width * y) + x) * 4 + 0] = r
                fireData.data[((width * y) + x) * 4 + 1] = g
                fireData.data[((width * y) + x) * 4 + 2] = b

                if (r === 0x07 && g === 0x07 && b === 0x07) {
                    fireData.data[((width * y) + x) * 4 + 3] = 0;
                } else {
                    // Black pixels need to be transparent to show DOOM logo
                    // TODO, maybe in the future...
                    fireData.data[((width * y) + x) * 4 + 3] = 255;
                }
            }
        }

        ctx.drawImage(fireData, 0 , 0)
        timer.start()
    }


    Timer {
        id: timer
        interval: 60
        repeat: true
        onTriggered: {
            canvas.doFire()
            canvas.requestPaint()
        }
    }

    function setup() {
        // Set whole screen to 0 (color: 0x07,0x07,0x07)
        for(var i = 0; i < width * height; i++) {
            firePixels[i] = 0;
        }

        // Set bottom line to 37 (color white: 0xFF,0xFF,0xFF)
        for(var j = 0; j < width; j++) {
            firePixels[(height - 1) * width + j] = 36;
        }
    }

    function spreadFire(src) {
        var pixel = firePixels[src];
        if(pixel === 0) {
            firePixels[src - width] = 0;
        } else {
            var randIdx = Math.round(Math.random() * 3.0) & 3;
            var dst = src - randIdx + 1;
            firePixels[dst - width ] = pixel - (randIdx & 1);
        }
    }

    function doFire() {
        for(var x = 0 ; x < width ; x++) {
            for (var y = 1; y < height ; y++) {
                spreadFire(y * width + x);
            }
        }
    }

}
