import QtQuick 2.9
import "functions.js" as F
import "geom.js" as G
import cz.mlich 1.0

Rectangle {
    id: pinchmap;
    property bool mapTileVisible: false

    property int zoomLevel: 7;
    property int oldZoomLevel: 99
    property int maxZoomLevel: 19;
    property int minZoomLevel: 2;
    property int tileSize: 256;
    property int cornerTileX: 32;
    property int cornerTileY: 32;
    property int numTilesX: Math.ceil(width/tileSize) + 2;
    property int numTilesY: Math.ceil(height/tileSize) + 2;
    property int maxTileNo: Math.pow(2, zoomLevel) - 1;


    property double latitude: 49.803575
    property double longitude: 15.475555
    property variant scaleBarLength: getScaleBarLength(latitude);
    property variant gpsModel;

    property bool showRuler: false
    property real rulerDistance: -1;

    //    property string url: "http://a.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
    property string url: "";

    property variant polygonCache;

    property int earthRadius: 6371000
    property bool needsUpdate: false


    signal pannedManually
    signal imageReady();



    function pointsInBounds() {

        if (polygonCache === undefined) {
            return;
        }

        var first = true;

        var min_lat, max_lat, min_lon, max_lon;

        for (var i = 0; i < polygonCache.length; i++) {
            var polygon = polygonCache[i];
            var points = polygon.points;
            for (var j = 0; j < points.length; j++) {
                var item = points[j];
                if (first) {
                    first = false;
                    min_lat = item.lat;
                    max_lat = item.lat;
                    min_lon = item.lon;
                    max_lon = item.lon;
                    continue;
                }
                if (item.lat > max_lat) {
                    max_lat = item.lat
                }
                if (item.lat < min_lat) {
                    min_lat = item.lat
                }

                if (item.lon > max_lon) {
                    max_lon = item.lon
                }
                if (item.lon < min_lon) {
                    min_lon = item.lon
                }

            }
        }

        zoomToBounds(min_lat, min_lon, max_lat, max_lon);

    }

    onMaxZoomLevelChanged: {
        if (pinchmap.maxZoomLevel < pinchmap.zoomLevel) {
            setZoomLevel(maxZoomLevel);
        }
    }


    onHeightChanged: {
        requestUpdate();
    }



    function setZoomLevel(z) {
        setZoomLevelPoint(z, pinchmap.width/2, pinchmap.height/2);
    }

    function zoomIn() {
        setZoomLevel(pinchmap.zoomLevel + 1)
    }

    function zoomOut() {
        setZoomLevel(pinchmap.zoomLevel - 1)
    }

    function setZoomLevelPoint(z, x, y) {
        if (z === zoomLevel) {
            return;
        }
        if (z < pinchmap.minZoomLevel || z > pinchmap.maxZoomLevel) {
            return;
        }
        var p = getCoordFromScreenpoint(x, y);
        zoomLevel = z;
        setCoord(p, x, y);
    }

    function pan(dx, dy) {
        map.offsetX -= dx;
        map.offsetY -= dy;
    }

    function panEnd() {
        var changed = false;
        var threshold = pinchmap.tileSize;

        while (map.offsetX < -threshold) {
            map.offsetX += threshold;
            cornerTileX += 1;
            changed = true;
        }
        while (map.offsetX > threshold) {
            map.offsetX -= threshold;
            cornerTileX -= 1;
            changed = true;
        }

        while (map.offsetY < -threshold) {
            map.offsetY += threshold;
            cornerTileY += 1;
            changed = true;
        }
        while (map.offsetY > threshold) {
            map.offsetY -= threshold;
            cornerTileY -= 1;
            changed = true;
        }
        updateCenter();
    }

    function zoomToBounds(lat1, lon1, lat2, lon2) {

        if ((pinchmap.width <= 0) || (pinchmap.height <= 0)) {
            return;
        }

        setCenterLatLon(0.5*(lat1+lat2), 0.5*(lon1+lon2))

        var latFrac = Math.abs(deg2rad(lat1) - deg2rad(lat2))/Math.PI
        var lonFrac = Math.abs(lon1 - lon2) / 360;

        var latZoom = Math.floor(Math.log( pinchmap.height / tileSize / latFrac) / Math.log(2) );
        var lonZoom = Math.floor(Math.log( pinchmap.width  / tileSize / lonFrac) / Math.log(2) );

        setZoomLevel(Math.min(latZoom,lonZoom, maxZoomLevel));

    }

    function updateCenter() {
        var l = getCenter()
        longitude = l[1]
        latitude = l[0]
    }

    function requestUpdate() {
        if (pinchmap.height <= 0) {
            console.log("requestUpdate = 0")
            return;
        }

        canvas.requestPaint()
    }

    function requestUpdateDetails() {
        var start = getCoordFromScreenpoint(0,0)
        var end = getCoordFromScreenpoint(pinchmap.width,pinchmap.height)
        //        controller.downloadGeocaches(start[0], start[1], end[0], end[1])
        console.debug("Download requested.")
    }

    function getScaleBarLength(lat) {
        var destlength = width/5;
        var mpp = getMetersPerPixel(lat);
        var guess = mpp * destlength;
        var base = 10 * -Math.floor(Math.log(guess)/Math.log(10) + 0.00001)
        var length_meters = Math.round(guess/base)*base
        var length_pixels = length_meters / mpp
        return [length_pixels, length_meters]
    }

    function getMetersPerPixel(lat) {
        return Math.cos(lat * Math.PI / 180.0) * 2.0 * Math.PI * earthRadius / (256 * (maxTileNo + 1))
    }

    function deg2rad(deg) {
        return deg * (Math.PI /180.0);
    }

    function deg2num(lat, lon) {
        var rad = deg2rad(lat % 90);
        var n = maxTileNo + 1;
        var xtile = ((lon % 180.0) + 180.0) / 360.0 * n;
        var ytile = (1.0 - Math.log(Math.tan(rad) + (1.0 / Math.cos(rad))) / Math.PI) / 2.0 * n;
        return [xtile, ytile];
    }

    function setLatLon(lat, lon, x, y) {
        var oldCornerTileX = cornerTileX
        var oldCornerTileY = cornerTileY
        var tile = deg2num(lat, lon);
        var cornerTileFloatX = tile[0] + (map.rootX - x) / tileSize // - numTilesX/2.0;
        var cornerTileFloatY = tile[1] + (map.rootY - y) / tileSize // - numTilesY/2.0;
        cornerTileX = Math.floor(cornerTileFloatX);
        cornerTileY = Math.floor(cornerTileFloatY);
        map.offsetX = -(cornerTileFloatX - Math.floor(cornerTileFloatX)) * tileSize;
        map.offsetY = -(cornerTileFloatY - Math.floor(cornerTileFloatY)) * tileSize;
        updateCenter();
    }

    function setCoord(c, x, y) {
        setLatLon(c[0], c[1], x, y);
    }

    function setCenterLatLon(lat, lon) {
        setLatLon(lat, lon, pinchmap.width/2, pinchmap.height/2);
    }

    function setCenterCoord(c) {
        setCenterLatLon(c[0], c[1]);
    }

    function getCoordFromScreenpoint(x, y) {
        var realX = - map.rootX - map.offsetX + x;
        var realY = - map.rootY - map.offsetY + y;
        var realTileX = cornerTileX + realX / tileSize;
        var realTileY = cornerTileY + realY / tileSize;
        return num2deg(realTileX, realTileY);
    }

    function getScreenpointFromCoord(lat, lon) {
        var tile = deg2num(lat, lon)
        var realX = (tile[0] - cornerTileX) * tileSize
        var realY = (tile[1] - cornerTileY) * tileSize
        var x = realX + map.rootX + map.offsetX
        var y = realY + map.rootY + map.offsetY
        return [x, y]
    }

    function getMappointFromCoord(lat, lon) {
        //        console.count()
        var tile = deg2num(lat, lon)
        var realX = (tile[0] - cornerTileX) * tileSize
        var realY = (tile[1] - cornerTileY) * tileSize
        return [realX, realY]

    }

    function getCenter() {
        return getCoordFromScreenpoint(pinchmap.width/2, pinchmap.height/2);
    }

    function sinh(aValue) {
        return (Math.pow(Math.E, aValue)-Math.pow(Math.E, -aValue))/2;
    }

    function num2deg(xtile, ytile) {
        var n = Math.pow(2, zoomLevel);
        var lon_deg = xtile / n * 360.0 - 180;
        var lat_rad = Math.atan(sinh(Math.PI * (1 - 2 * ytile / n)));
        var lat_deg = lat_rad * 180.0 / Math.PI;
        return [lat_deg % 90.0, lon_deg % 180.0];
    }

    function tileUrl(tx, ty) {
        if ((url === undefined) || (url === "")) {
            return "./data/noimage-disabled.png"
        }

        if (tx < 0 || tx > maxTileNo) {
            return "./data/noimage.png"
        }

        if (ty < 0 || ty > maxTileNo) {
            return "./data/noimage.png"
        }


        var res = Qt.resolvedUrl(G.getMapTile(url, tx, ty, zoomLevel));

        return res;

    }

    function imageStatusToString(status) {
        switch (status) {
            //% "Ready"
        case Image.Ready: return qsTrId("pinchmap-ready");
            //% "Not Set"
        case Image.Null: return qsTrId("pinchmap-not-set");
            //% "Error"
        case Image.Error: return qsTrId("pinchmap-error");
            //% "Loading ..."
        case Image.Loading: return qsTrId("pinchmap-loading");
            //% "Unknown error"
        default: return qsTrId("pinchmap-unknown-error");
        }
    }



    Grid {

        id: map;
        columns: numTilesX;
        width: numTilesX * tileSize;
        height: numTilesY * tileSize;
        property int rootX: -(width - parent.width)/2;
        property int rootY: -(height - parent.height)/2;
        property int offsetX: 0;
        property int offsetY: 0;
        x: rootX + offsetX;
        y: rootY + offsetY;


        Repeater {
            id: tiles


            model: (pinchmap.numTilesX * pinchmap.numTilesY);
            Rectangle {
                id: tile
                property alias source: img.source;
                property int tileX: cornerTileX + (index % numTilesX)
                property int tileY: cornerTileY + Math.floor(index / numTilesX)
                Rectangle {
                    id: progressBar;
                    property real p: 0;
                    height: 16;
                    width: parent.width - 32;
                    anchors.centerIn: img;
                    color: "#c0c0c0";
                    border.width: 1;
                    border.color: "#000000";
                    Rectangle {
                        anchors.left: parent.left;
                        anchors.margins: 2;
                        anchors.top: parent.top;
                        anchors.bottom: parent.bottom;
                        width: (parent.width - 4) * progressBar.p;
                        color: "#000000";
                    }
                    visible: mapTileVisible
                }
                NativeText {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    y: parent.height/2 - 32
                    text: imageStatusToString(img.status)
                    visible: mapTileVisible
                }
                Image {
                    visible: mapTileVisible && (img.status === Image.Null)
                    source: "./data/noimage.png"
                }


                Image {
                    id: img;
                    anchors.fill: parent;
                    onProgressChanged: { progressBar.p = progress }
                    source: mapTileVisible ? tileUrl(tileX, tileY) : "";
                    visible: mapTileVisible
                }


                width: tileSize;
                height: tileSize;
                color: mapTileVisible ? "#c0c0c0" : "transparent";
            }

        }


    }


    Canvas {
        id: canvas
        x: map.x
        y: map.y
        width: map.width
        height: map.height
        renderStrategy: Canvas.Immediate
        onPaint: {
            console.time("canvas-print-onPaint")

            pointsInBounds();


            var ctx = canvas.getContext("2d");
            ctx.save();
            ctx.lineCap = "butt"
            ctx.lineJoin = "bevel"
            ctx.lineWidth = 2;
            ctx.clearRect(0, 0, canvas.width, canvas.height)

            var tpinfos = []


            var item, i, c, screenPoint;




            if (polygonCache !== undefined) {

                for (i = 0; i < polygonCache.length; i++) {
                    var polygonCacheItem = polygonCache[i]
                    ctx.strokeStyle="#" + polygonCacheItem.color;
                    ctx.beginPath()
                    var points = polygonCacheItem.points;

                    if (points.length < 2) {
                        continue;
                    }
                    item = points[0];
                    screenPoint = getMappointFromCoord(item.lat,item.lon)
                    ctx.moveTo(screenPoint[0], screenPoint[1])

                    for (var j = 1; j < points.length; j++) {
                        item = points[j];
                        screenPoint = getMappointFromCoord(item.lat,item.lon)
                        ctx.lineTo(screenPoint[0], screenPoint[1])

                    }


                    ctx.stroke();

                }


            }



            ///////////////
            if ((gpsModel !== undefined) && (gpsModel.count > 0)) {

                ctx.strokeStyle="#ff0000"
                ctx.beginPath()

                item = gpsModel.get(0);
                screenPoint = getMappointFromCoord(item.lat, item.lon)
                ctx.moveTo(screenPoint[0], screenPoint[1])

                for (i = 1; i < gpsModel.count; i++) {
                    item = gpsModel.get(i);
                    screenPoint = getMappointFromCoord(item.lat, item.lon)
                    ctx.lineTo(screenPoint[0], screenPoint[1])
                }
                ctx.stroke();
            }

            ctx.restore();

            console.timeEnd("canvas-print-onPaint")
        }

        onPainted: {
            imageReady();
        }

    }


    Rectangle {
        id: scaleBar
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.topMargin: 16
        anchors.top: parent.top
        color: "#000000"
        border.width: 1
        border.color: "#ffffff"
        smooth: false
        height: 6
        width: scaleBarLength[0]
    }

    NativeText {
        text: G.formatDistance(scaleBarLength[1], {'distanceUnit':'m'})
        anchors.horizontalCenter: scaleBar.horizontalCenter
        anchors.top: scaleBar.bottom
        anchors.topMargin: 8
        style: Text.Outline
        styleColor: "white"
        font.pixelSize: 24
    }


    PinchArea {
        id: pincharea;

        property double __oldZoom;

        anchors.fill: parent;

        function calcZoomDelta(p) {
            pinchmap.setZoomLevelPoint(Math.round((Math.log(p.scale)/Math.log(2)) + __oldZoom), p.center.x, p.center.y);
            pan(p.previousCenter.x - p.center.x, p.previousCenter.y - p.center.y);
        }

        onPinchStarted: {
            __oldZoom = pinchmap.zoomLevel;
        }

        onPinchUpdated: {
            calcZoomDelta(pinch);
        }

        onPinchFinished: {
            calcZoomDelta(pinch);
        }


        MouseArea {
            id: mousearea;
            anchors.fill : parent;

            property bool __isPanning: false;
            property int __lastX: -1;
            property int __lastY: -1;
            property int __firstX: -1;
            property int __firstY: -1;

            onWheel:  {
                if (wheel.angleDelta.y > 0) {
                    setZoomLevelPoint(pinchmap.zoomLevel + 1, wheel.x, wheel.y);
                } else {
                    setZoomLevelPoint(pinchmap.zoomLevel - 1, wheel.x, wheel.y);
                }
            }


            onPressed: {

                pannedManually()

                __isPanning = true;


                __lastX = mouse.x;
                __lastY = mouse.y;
                __firstX = mouse.x;
                __firstY = mouse.y;

            }

            onReleased: {
                if (__isPanning) {
                    panEnd();
                }
                __isPanning = false;


            }

            onPositionChanged: {
                if (__isPanning) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;
                    pan(-dx, -dy);
                    __lastX = mouse.x;
                    __lastY = mouse.y;
                    /*
                    once the pan threshold is reached, additional checking is unnecessary
                    for the press duration as nothing sets __wasClick back to true
                    */
                    //                    if (__wasClick && Math.pow(mouse.x - __firstX, 2) + Math.pow(mouse.y - __firstY, 2) > maxClickDistance) {
                    //                        __wasClick = false;
                    //                    }

                }
            }

            onCanceled: {
                __isPanning = false;

            }
        }

    }




}
