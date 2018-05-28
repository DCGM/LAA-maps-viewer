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

        if (dataWidth <= 0) {
            var ctx = canvas.getContext("2d");
            ctx.lineCap = "butt"
            ctx.lineJoin = "bevel"
            ctx.lineWidth = 2;
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            return;
        }

        var item = gpsModel.get(0);
        var minAlt = item.alt;
        var maxAlt = item.alt;

        for (var i = 1; i < gpsModel.count; i++) {
            var item = gpsModel.get(i);
            minAlt = Math.min(minAlt, item.alt);
            maxAlt = Math.max(maxAlt, item.alt);
        }

        var ctx = canvas.getContext("2d");
        ctx.lineCap = "butt"
        ctx.lineJoin = "bevel"
        ctx.lineWidth = 1;
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        var dataHeight = maxAlt - minAlt;

        var step = 50;
        var stepRoundedMin = Math.round(minAlt/step)*step
        for (var i = stepRoundedMin; i < maxAlt; i += step) {

            var yCoord = height-(height*(i-minAlt)/dataHeight);

            ctx.strokeStyle="#66cccccc";
            ctx.beginPath();
            ctx.moveTo(0, yCoord);
            ctx.lineTo(width, yCoord);
            ctx.stroke();

        }

        var item = gpsModel.get(0);
        var xCoord = 0;
        var yCoord = height-(height*(item.alt-minAlt)/dataHeight);

        ctx.lineWidth = 2;
        ctx.strokeStyle="#ff0000";
        ctx.beginPath();
        ctx.moveTo(xCoord, yCoord);

        for (var i = 1; i < gpsModel.count; i++) {
            var item = gpsModel.get(i);

            var xCoord = width*i/dataWidth;
            var yCoord = height-(height*(item.alt-minAlt)/dataHeight);
            ctx.lineTo(xCoord, yCoord);

        }
        ctx.stroke();

        var xCoord = width*currentPositionIndex/dataWidth;
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
