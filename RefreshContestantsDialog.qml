import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

Window {

    id: refreshDialogMainWindow
    width: applicationWindow.width;
    height: applicationWindow.height;
    modality: "WindowModal"
    color: "#ffffff"
    //% "Refresh window title"
    title: qsTrId("refresh-window-dialog-title")

    signal ok();
    signal cancel();

    onVisibleChanged: {
        if(visible) {
            workingTimer.running = false;  // stop working timer - spin box in main.qml
        }
    }

    ScrollView {

        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: actionButtons.top
        anchors.margins: 20
        horizontalScrollBarPolicy: column1.visibleCol ? Qt.ScrollBarAsNeeded : Qt.ScrollBarAlwaysOff

        Column {

            width: Math.max(column1.width, column2.width)
            spacing: 20

            Column {

                id: column1
                width: visibleCol ? columnWidth : 0
                height: visibleCol ? children.height : 0
                spacing: 20

                property bool visibleCol: updatedContestants.count > 0
                property int minWidth: 1990 //pix
                property int columnWidth: (refreshDialogMainWindow.visibility === Qt.WindowFullScreen || scrollView.width > column1.minWidth) ? scrollView.width : column1.minWidth

                NativeText {
                    id: updatedLabel
                    //% "Updated crews %1/%2"
                    text: qsTrId("refresh-dialog-updated-crews-title %1/%2").arg(updatedContestants.selected).arg(updatedContestants.count);
                    visible: updatedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {

                    id: modifiedCrewListViewCheckBox
                    visible: updatedContestants.count > 0
                    model: updatedContestants
                }
            }

            Column {

                id: column2
                spacing: 20
                width: refreshDialogMainWindow.width - scrollView.anchors.margins * 2
                height: children.height

                NativeText {
                    id: unmodifiedLabel
                    //% "Unmodified crews %1/%2"
                    text: qsTrId("refresh-dialog-unmodified-crews-title %1/%2").arg(unmodifiedContestants.selected).arg(unmodifiedContestants.count)

                    visible: unmodifiedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {
                    id: unmodifiedCrewListViewCheckBox
                    visible: unmodifiedContestants.count > 0
                    model: unmodifiedContestants
                }

                NativeText {
                    id: addedLabel
                    //% "Added crews %1/%2"
                    text: qsTrId("refresh-dialog-added-crews-title %1/%2").arg(addedContestants.selected).arg(addedContestants.count)
                    visible: addedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {

                    id: addedCrewListViewCheckBox
                    visible: addedContestants.count > 0
                    model: addedContestants
                }

                NativeText {
                    id: missingLabel
                    //% "Missing crews %1/%2"
                    text: qsTrId("refresh-dialog-missing-crews-title %1/%2").arg(removedContestants.selected).arg(removedContestants.count)
                    visible: removedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {

                    id: removedCrewListViewCheckBox
                    visible: removedContestants.count > 0
                    model: removedContestants
                }

                NativeText { text: " "; visible: column1.visibleCol } // spacer used when horizontal scroll bar is visible
            }
        }
    }

    RowLayout {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Row {
            spacing: 10;

            Button {
                id: okButton;
                //% "Ok"
                text: qsTrId("refresh-dialog-ok-button")
                focus: true;
                isDefault: true;
                onClicked: {

                    ok();
                    refreshDialogMainWindow.close();
                }
            }
            Button {
                //% "Cancel"
                text: qsTrId("refresh-dialog-cancel-button")

                onClicked: {
                    cancel();
                    refreshDialogMainWindow.close()
                }
            }
        }
    }
}
