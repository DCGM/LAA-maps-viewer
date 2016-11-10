import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Rectangle {

    id: mainRectangle
    clip: true
    color: "transparent"

    ListModel { id: ral1 }
    ListModel { id: ral2 }
    ListModel { id: sal1 }
    ListModel { id: sal2 }
    ListModel { id: rwl1 }
    ListModel { id: rwl2 }
    ListModel { id: swl1 }
    ListModel { id: swl2 }
    ListModel { id: custom1 }
    ListModel { id: custom2 }
    ListModel { id: custom3 }
    ListModel { id: custom4 }

    function initLists() {

        ral1.clear();
        ral2.clear();
        sal1.clear();
        sal2.clear();
        rwl1.clear();
        rwl2.clear();
        swl1.clear();
        swl2.clear();
        custom1.clear();
        custom2.clear();
        custom3.clear();
        custom4.clear();
    }

    function appendToList(key, data) {

        var listModel = null;

        switch(key) {
            case "R-AL1":
                listModel = ral1;
                break;
            case "R-AL2":
                listModel = ral2;
                break;
            case "S-AL1":
                listModel = sal1;
                break;
            case "S-AL2":
                listModel = sal2;
                break;
            case "R-WL1":
                listModel = rwl1;
                break;
            case "R-WL2":
                listModel = rwl2;
                break;
            case "S-WL1":
                listModel = swl1;
                break;
            case "S-WL2":
                listModel = swl2;
                break;
            case "CUSTOM1":
                listModel = custom1;
                break;
            case "CUSTOM2":
                listModel = custom2;
                break;
            case "CUSTOM3":
                listModel = custom3;
                break;
            case "CUSTOM4":
                listModel = custom4;
                break;
            default:
                console.log("appendToList: Unknown category " + key)
                return;
        }

        listModel.append({
                            "order" : (listModel.count + 1),
                            "name" : data[0],
                            "category" : data[1],
                            "startTime" : data[2],
                            "speed" : data[3],
                            "planeReg" : data[4],
                            "planeType" : data[5],
                            "points" : data[6],
                            "points1000" : data[7]
                 });
    }
    ScrollView {

        id: continuousResultsScrollView
        anchors.fill: parent
        anchors.margins: 5

        ColumnLayout {

            spacing: 20

            ContinuousResultsViewTable { model: ral1 }
            ContinuousResultsViewTable { model: ral2 }
            ContinuousResultsViewTable { model: sal1 }
            ContinuousResultsViewTable { model: sal2 }
        }
    }
}
