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

            case "inside_time_start":
            case "inside_time_end":
            case "outside_time_start":
            case "outside_time_end":
                var ret = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(value), applicationWindow.utc_offset_sec));;
                return ret;
            default:
                return value;
        }
    }
}
