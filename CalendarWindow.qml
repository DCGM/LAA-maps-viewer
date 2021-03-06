import QtQuick 2.9
import QtQuick.Controls 1.4

ApplicationWindow {

    id: dateDialog
    width: 320
    height: 320
    visible: false
    //"Choose date window"
    title: qsTr("calendar")
    modality: Qt.ApplicationModal

    signal accepted(string date);


    Rectangle {

        id: calendarRow
        anchors.margins: 10
        anchors.left: parent.left;
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: actionButtons.top

        Calendar {

            id: calendar
            anchors.fill: parent

            onDoubleClicked: {

                dateDialog.accepted(calendar.selectedDate.toLocaleDateString(Qt.locale(),"yyyy-MM-dd"));
                dateDialog.close();
            }
        }
    }

    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("path-configuration-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                dateDialog.accepted(calendar.selectedDate.toLocaleDateString(Qt.locale(),"yyyy-MM-dd"));
                dateDialog.close();
            }
        }

        Button {
            //% "Cancel"
            text: qsTrId("path-configuration-ok-cancel")
            onClicked: {

                dateDialog.close();
            }
        }
    }
}
