import QtQuick 2.9
import QtQuick.Controls 1.4
import "functions.js" as F
import "./components"

Item {
    id: delegate;
    property variant comboModel
    property variant typeModel
    property variant category_defaults;
    signal changeModel(int row, string role, variant value);


    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: getTextForRole(styleData.row, styleData.role, styleData.value);
        color:  ((styleData.value === -1 ||
                 (styleData.role === "tg_time_manual" && styleData.value === "00:00:00")) &&
                 (styleData.role !== "manualAltMinEntriesTime" && styleData.role !== "manualAltMaxEntriesTime" && styleData.role !== "manualTime_spent_out"))
                ?  "#aaa" : styleData.textColor;

        visible: ((styleData.role === "title") ||
                  (styleData.role === "type") ||
                  (styleData.role === "distance_from_vbt") ||
                  (styleData.role === "tg_time_calculated") ||
                  (styleData.role === "tg_time_measured") ||
                  (styleData.role === "tg_time_difference") ||
                  (styleData.role === "tg_score") ||
                  (styleData.role === "tp_hit_measured") ||
                  (styleData.role === "tp_score") ||
                  (styleData.role === "sg_hit_measured") ||
                  (styleData.role === "sg_score") ||
                  (styleData.role === "alt_max") ||
                  (styleData.role === "alt_min") ||
                  (styleData.role === "alt_measured") ||
                  (styleData.role === "alt_score") ||
                  (styleData.role === "startPointName") ||
                  (styleData.role === "endPointName") ||
                  (styleData.role === "speedDifference") ||
                  (styleData.role === "speedSecScore") ||
                  (styleData.role === "manualAltMinEntriesTime") ||
                  (styleData.role === "manualAltMaxEntriesTime") ||
                  (styleData.role === "manualTime_spent_out") ||
                  (styleData.role === "altSecScore") ||
                  (styleData.role === "spaceSecScore") ||
                  (styleData.role === "time_diff") ||
                  (styleData.role === "time_start") ||
                  (styleData.role === "time_end")
                  ) ||
                  (!styleData.selected && (styleData.role !== "classify"))
    }

    

    /// Type other (editbox)

    Loader { // Initialize text editor lazily to improve performance
        id: loaderEditor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderEditor.item
            function onNewValue(value) {
                var num =0;

                switch (styleData.role) {

                    case "sg_hit_manual":
                    case "tp_hit_manual":

                        var pattYes = /y|Y|a|A|yes|YES|Yes|YEs|ano|ANO|Ano|ANo/;
                        var pattNo = /n|N|no|NO|ne|NE|No|Ne/;

                        if (pattYes.test(value))
                            changeModel(styleData.row, styleData.role, 1);
                        else if (pattNo.test(value))
                            changeModel(styleData.row, styleData.role, 0);
                        else
                            changeModel(styleData.row, styleData.role, -1);

                        break;

                    case "alt_manual":

                        num = parseFloat(value);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, -1)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                        }
                        break;

                    case "tg_time_manual":

                        var str = value;
                        var sec = F.timeToUnix(str);
                        if (sec > 0) {
                            changeModel(styleData.row, styleData.role, F.subUtcFromTime(sec, applicationWindow.utc_offset_sec));
                        } else {
                            changeModel(styleData.row, styleData.role, -1)
                        }
                        break;

                    case "manualSpeed":

                        num = parseInt(value);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, -1)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                        }

                        break;

                    case "manualAltMinEntriesCount":
                        num = parseInt(value);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, -1)
                            changeModel(styleData.row, "manualAltMinEntriesTime", -1)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                            changeModel(styleData.row, "manualAltMinEntriesTime", parseInt(""))
                        }

                        break;

                    case "manualAltMaxEntriesCount":

                        num = parseInt(value);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, -1)
                            changeModel(styleData.row, "manualAltMaxEntriesTime", -1)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                            changeModel(styleData.row, "manualAltMaxEntriesTime", parseInt(""))
                        }

                        break;

                    case "manualEntries_out":

                        num = parseInt(value);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, -1)
                            changeModel(styleData.row, "manualTime_spent_out", -1)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                            changeModel(styleData.row, "manualTime_spent_out", parseInt(""))
                        }

                        break;

                    default:
                        changeModel(styleData.row, styleData.role, value)
                        break;
                }

            }
        }


        sourceComponent:
            (
                styleData.role !== "title" &&
                styleData.role !== "type" &&
                styleData.role !== "classify" &&
                styleData.role !== "distance_from_vbt" &&
                styleData.role !== "tg_time_calculated" &&
                styleData.role !== "tg_time_measured" &&
                styleData.role !== "tg_time_difference" &&
                styleData.role !== "tg_score" &&
                styleData.role !== "tp_hit_measured" &&
                styleData.role !== "tp_score" &&
                styleData.role !== "sg_hit_measured" &&
                styleData.role !== "sg_score" &&
                styleData.role !== "alt_max" &&
                styleData.role !== "alt_min" &&
                styleData.role !== "alt_measured" &&
                styleData.role !== "alt_score" &&
                styleData.role !== "startPointName" &&
                styleData.role !== "endPointName" &&
                styleData.role !== "speedDifference" &&
                styleData.role !== "speedSecScore" &&
                styleData.role !== "manualAltMinEntriesTime" &&
                styleData.role !== "manualAltMaxEntriesTime" &&
                styleData.role !== "altSecScore" &&
                styleData.role !== "manualTime_spent_out" &&
                styleData.role !== "spaceSecScore" &&
                styleData.role !== "time_diff" &&
                styleData.role !== "time_start" &&
                styleData.role !== "time_end"

             ) && (styleData.selected)
            ? editor : null

        Component {
            id: editor

            NativeTextInput {
                id: textinput
                signal newValue(string value);

                color: styleData.textColor
                text: getTextForRole(styleData.row, styleData.role, styleData.value);

                onAccepted: {

                    newValue(text);
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        textinput.forceActiveFocus()
                    }
                }
            }
        }
    }

    function getTextForRole(row, role, value) {

        if (row < 0) {
            return "";
        }

        var show = value;
        var it;

        // set up details
        if (value < 0) {
            switch (role) {

                case "tp_hit_manual":
                    it = currentWptScoreList.get(styleData.row);
                    show = it.tp_hit_measured
                    break;

                case "sg_hit_manual":
                    it = currentWptScoreList.get(styleData.row);
                    show = it.sg_hit_measured
                    break;

                case "alt_min":
                case "alt_max":
                    show = ""
                    break;

                case "tg_time_manual":
                    it = currentWptScoreList.get(styleData.row);
                    show = it.tg_time_measured;
                    break;

                case "alt_manual":
                    it = currentWptScoreList.get(styleData.row);
                    show = it.alt_measured;
                    break;

                case "manualSpeed":
                    it = currentSpeedSectionsScoreList.get(styleData.row);
                    show = it.calculatedSpeed;
                    break;

                case "manualAltMinEntriesCount":
                    it = currentAltitudeSectionsScoreList.get(styleData.row);
                    show = it.altMinEntriesCount;
                    break;

                case "manualAltMaxEntriesCount":
                    it = currentAltitudeSectionsScoreList.get(styleData.row);
                    show = it.altMaxEntriesCount;
                    break;

                case "manualAltMinEntriesTime":
                    it = currentAltitudeSectionsScoreList.get(styleData.row);
                    show = it.altMinEntriesTime;
                    break;

                case "manualAltMaxEntriesTime":
                    it = currentAltitudeSectionsScoreList.get(styleData.row);
                    show = it.altMaxEntriesTime;
                    break;
                case "manualEntries_out":
                    it = currentSpaceSectionsScoreList.get(styleData.row);
                    show = it.entries_out;
                    break;
                case "manualTime_spent_out":
                    it = currentSpaceSectionsScoreList.get(styleData.row);
                    show = it.time_spent_out;
                    break;
                case "type":
                    break;

                default:
                    show = value;
                    break;
            }
        }

        switch (role) {


            case "distance_from_vbt":
                show = Math.round(show/10) / 100; //(show/1000 * 100)/100
                break;

            case "manualTime_spent_out":
            case "manualAltMinEntriesTime":
            case "manualAltMaxEntriesTime":
                show = F.addTimeStrFormat(show);
                break;
            case "tg_time_calculated":
            case "tg_time_manual":
                show = F.addTimeStrFormat(F.addUtcToTime(show, applicationWindow.utc_offset_sec));
                break;
            case "tg_time_difference":
                show = F.addTimeStrFormat(show);
                break;

            case "sg_hit_manual":
            case "tp_hit_manual":
            case "tp_hit_measured":
            case "sg_hit_measured":

                show = show ?
                       //% "YES"
                       qsTrId("hit-yes") :
                       //% "NO"
                       qsTrId("hit-no")
                break;

            case "tg_score":
            case "tp_score":
            case "sg_score":
            case "alt_score":
                show = show === -1 ? "" : show;
                break;

            case "type":
                //show = flagsToStr(show);
                show = results_creator.pointFlagToString(show);
                break;


            case "alt_manual":
                //show = isNaN(show) ? "" : show;
                show = show < 0 ? "" : show;
                break;

            case "classify":
            case "flags":
                break;

            case "time_diff":
                show = F.addTimeStrFormat(show);
                break;
            case "time_start":
            case "time_end":
                show = F.addTimeStrFormat(F.addUtcToTime(show, applicationWindow.utc_offset_sec));
                break;

            default:

        }

        return show;
    }
}

