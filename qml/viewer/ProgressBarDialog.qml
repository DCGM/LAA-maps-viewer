import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

Window {

    id: dialogWindow
    width: 380
    height: 160
    minimumWidth: 280
    minimumHeight: 140
    modality: Qt.ApplicationModal
    color: "#edeceb"
    visible: false

    property alias dialogTitle: dialogWindow.title
    property alias dialogText: mDialogText.text
    property alias progressBarValue: progressBar.value

    signal cancel();

    onVisibleChanged: {

        if (visible) {

            progressBarValue = 0.0;

            //dialogWindow.x = (mainWindow.width - dialogWindow.width) / 2.0 + mainWindow.x;
            //dialogWindow.y = (mainWindow.height - dialogWindow.height) / 2.0 + mainWindow.y;
        }
    }

    //onClosing: cancelTransfer();

    Text {

        id: mDialogText
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: progressBarRec.top
        anchors.bottomMargin: 20
        renderType: Text.NativeRendering
    }

    Rectangle {

        id: progressBarRec
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: rowButtonLayout.top
        anchors.bottomMargin: 10
        height: 60
        color: "Transparent"

        ProgressBar {

                id: progressBar
                minimumValue: 0
                maximumValue: 100
                value: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
        }
    }

    HorizontalDelimeter {

        width: parent.width
        anchors.top: progressBarRec.bottom
    }


    RowLayout {

        id: rowButtonLayout
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10

        Button {

            id: cancelButtonSettings
            text: qsTr("cancel")

            onClicked: {

                //cancelTransfer();
            }
        }
    }
}
