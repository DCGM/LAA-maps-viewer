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
    property variant datamodel; // igcFolderModel
    property variant cm; // contestantsListModel
    property int row;

    signal choosenFilename(string filename);

    onRowChanged: {
        if (datamodel === undefined) {
            return;
        }

        if (cm === undefined) {
            return;
        }

        var item = cm.get(row);
        selectionTableView.selection.clear();
        var selectedFilename = item.fileName;

        for (var i = 0; i < datamodel.count; i++) {
            var fileName = datamodel.get(i, "fileName");
            if (fileName === selectedFilename) {
                selectionTableView.selection.select(i);
            }
        }

    }

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
                if (datamodel === undefined) {
                    return;
                }

                selectionTableView.selection.forEach(function(rowIndex) {
                    var fileName = datamodel.get(rowIndex, "fileName");
                    choosenFilename(fileName)
                });
                igcChooseDialog.close();


            }
        }

        Button {
            //% "None"
            text: qsTrId("IGC-Choose-Dialog-deselect")
            onClicked: {
                choosenFilename("");
                igcChooseDialog.close();
            }
        }

        Button {
            //% "Close"
            text: qsTrId("IGC-Choose-Dialog-cancel")
            onClicked: {
                igcChooseDialog.close();
            }
        }



    }

}
