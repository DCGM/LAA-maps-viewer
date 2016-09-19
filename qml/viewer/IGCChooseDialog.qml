import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F


ApplicationWindow {
    id: igcChooseDialog;
    modality: "WindowModal"
    width: 500;
    height: 300;


    //% "Choose IGC File"
    title: qsTrId("igc-choose-dialog");
    property variant datamodel
    property int row;

    signal choosenFilename(string filename);

    TableView {
        id: selectionTableView;
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10

        model: datamodel;
        selectionMode: SelectionMode.SingleSelection;
        TableViewColumn {
            //% "Filename"
            title: qsTrId("IGC-Choose-dialog-filename")
            role: "fileName"
        }
    }
    /// Action Buttons
    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("IGC-Choose-Dialog-ok")
            focus: true;
            isDefault: true;
            onClicked: {
                selectionTableView.selection.forEach(function(rowIndex) {
                    var fileName = datamodel.get(rowIndex, "fileName");
                    choosenFilename(fileName)
                });
                selectionTableView.selection.clear();
                igcChooseDialog.close();


            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("IGC-Choose-Dialog-cancel")
            onClicked: {
                igcChooseDialog.close();
            }

        }
    }



}
