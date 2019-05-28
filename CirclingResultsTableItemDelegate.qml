import QtQuick 2.9
import "functions.js" as F

Item {

    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: getTextForRole(styleData.row, styleData.role, styleData.value);
    }

    function getTextForRole(row, role, value) {

        var item;
        if (row < 0) {
            return "";
        }
        switch (role) {

            case "time":
            case "time1":
            case "time2":
                var ret = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(value), applicationWindow.utc_offset_sec));;
                return ret;
            case "lat":
                return F.getLat(value, {coordinateFormat: "DMS"});
            case "lon":
                return F.getLon(value, {coordinateFormat: "DMS"});
            case "azimuth":
                return parseFloat(value).toFixed(2);
            default:
                return value;
        }
    }
}
