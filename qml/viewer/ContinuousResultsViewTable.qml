import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

ListView {

    id: listView
    Layout.fillWidth: true
    Layout.preferredWidth: continuousResultsScrollView.viewport.width
    Layout.preferredHeight: Math.max(30, (model.count + 1) * 30 + 20);

    interactive: false

    delegate: contResDelegate

    property int nameColumnWidth: width - 850 - 30

    Component {
            id: contResDelegate

            Rectangle {
                width: listView.width;
                height: 30
                color: order % 2? "#fff" : "#eee"

                RowLayout {
                    anchors.fill: parent;
                    anchors.leftMargin: 5
                    spacing: 5

                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: order
                        Layout.preferredWidth: 50
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                        Layout.preferredWidth: 200
                        Layout.minimumWidth: 200
                        Layout.fillWidth: true
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: category
                        Layout.preferredWidth: 100
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: startTime == -1 ? "" : startTime
                        Layout.preferredWidth: 100
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: speed == -1 ? "" : speed
                        Layout.preferredWidth: 50
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: planeReg == -1 ? "" : planeReg
                        Layout.preferredWidth: 150
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: planeType == -1 ? "" : planeType
                        Layout.preferredWidth: 150
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: points == -1 ? "" : points
                        Layout.preferredWidth: 50
                    }
                    NativeText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: points1000 == -1 ? "" : points1000
                        Layout.preferredWidth: 50
                    }
                }
            }
    }
}


/*
TableView {

    Layout.fillWidth: true
    Layout.preferredWidth: 900//continuousResultsScrollView.viewport.width
    Layout.preferredHeight: Math.max(30, (model.count + 1) * 30 + 20);

    rowDelegate: Rectangle {
        height: 30;
        color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")
    }

    itemDelegate: Item {

        anchors.fill: parent;

        NativeText {
            width: parent.width
            anchors.margins: 4
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            elide: styleData.elideMode
            text: (styleData.value != -1) ? styleData.value : ""
            verticalAlignment: Text.AlignVCenter
        }
    }

    TableViewColumn {
        role: "order"
        title: qmlTranslator.myTranslate("html-continuous-results-order");
        width: 50
    }
    TableViewColumn {
        role: "name"
        title: qmlTranslator.myTranslate("html-continuous-results-name");
    }
    TableViewColumn {
        role: "category"
        title: qmlTranslator.myTranslate("html-results-ctnt-category");
        width: 100
    }
    TableViewColumn {
        role: "startTime"
        title: qmlTranslator.myTranslate("html-results-ctnt-startTime");
        width: 100
    }
    TableViewColumn {
        role: "speed"
        title: qmlTranslator.myTranslate("html-results-ctnt-speed");
        width: 100
    }
    TableViewColumn {
        role: "planeReg"
        title: qmlTranslator.myTranslate("html-results-ctnt-aircraft-registration");
        width: 100
    }
    TableViewColumn {
        role: "planeType"
        title: qmlTranslator.myTranslate("html-results-ctnt-aircraft-type");
        width: 100
    }
    TableViewColumn {
        role: "points"
        title: qmlTranslator.myTranslate("html-results-ctnt-score-points");
        width: 100
    }
    TableViewColumn {
        role: "points1000"
        title: qmlTranslator.myTranslate("html-results-ctnt-score-points1000");
        width: 100
    }
}
*/


