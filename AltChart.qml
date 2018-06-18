import QtQuick 2.9

Canvas {

    id: canvas;
    property variant gpsModel;
    property int currentPositionIndex: 0
    signal xClicked(int pos);

    onCurrentPositionIndexChanged: {
        requestPaint();
    }

    function igcUpdate() {
        if (!visible) {
            return;
        }


        requestPaint();
    }

    onVisibleChanged: {
        igcUpdate();
    }

    onPaint: {
        if (!visible) {
            return;
        }

        var dataWidth = gpsModel.count;
        var i;
        var ctx;

        if (dataWidth <= 0) {
            ctx = canvas.getContext("2d");
            ctx.lineCap = "butt"
            ctx.lineJoin = "bevel"
            ctx.lineWidth = 2;
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            return;
        }

        var item = gpsModel.get(0);
        var minAlt = item.alt;
        var maxAlt = item.alt;

        for (i = 1; i < gpsModel.count; i++) {
            item = gpsModel.get(i);
            minAlt = Math.min(minAlt, item.alt);
            maxAlt = Math.max(maxAlt, item.alt);
        }

        ctx = canvas.getContext("2d");
        ctx.lineCap = "butt"
        ctx.lineJoin = "bevel"
        ctx.lineWidth = 1;
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        var dataHeight = maxAlt - minAlt;

        var step = 50;
        var stepRoundedMin = Math.round(minAlt/step)*step
        var xCoord = 0;
        var yCoord = 0;
        for (i = stepRoundedMin; i < maxAlt; i += step) {

            yCoord = height-(height*(i-minAlt)/dataHeight);

            ctx.strokeStyle="#66cccccc";
            ctx.beginPath();
            ctx.moveTo(0, yCoord);
            ctx.lineTo(width, yCoord);
            ctx.stroke();

        }

        item = gpsModel.get(0);

        yCoord = height-(height*(item.alt-minAlt)/dataHeight);

        ctx.lineWidth = 2;
        ctx.strokeStyle="#ff0000";
        ctx.beginPath();
        ctx.moveTo(xCoord, yCoord);

        for (i = 1; i < gpsModel.count; i++) {
            item = gpsModel.get(i);

            xCoord = width*i/dataWidth;
            yCoord = height-(height*(item.alt-minAlt)/dataHeight);
            ctx.lineTo(xCoord, yCoord);

        }
        ctx.stroke();

        xCoord = width*currentPositionIndex/dataWidth;
        ctx.strokeStyle="#660000ff";
        ctx.beginPath();
        ctx.moveTo(xCoord, 0);
        ctx.lineTo(xCoord, height);
        ctx.stroke();
    }

    onHeightChanged: {
        requestPaint();
    }

    onWidthChanged: {
        requestPaint();
    }


    MouseArea {
        anchors.fill: parent;
        onClicked: {

            var xCoord = igc.count*mouse.x/width;
            xClicked(xCoord);
        }
    }
}
