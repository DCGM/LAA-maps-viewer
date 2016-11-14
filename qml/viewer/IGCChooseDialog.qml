import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F


ApplicationWindow {
    id: igcChooseDialog;
    modality: "WindowModal"
    width: 550;
    height: 700;


    //% "Choose IGC File"
    title: qsTrId("igc-choose-dialog");
    property variant datamodel; // igcFolderModel
    property variant cm; // contestantsListModel
    property int row;
    property int lateSelect

    ListModel {
        id: fileContestantPairModel
    }


    signal choosenFilename(string filename, string filePath);

    function folderModelChanged() {

        if (datamodel === undefined) {
            return;
        }

        if (cm === undefined) {
            return;
        }

        if (datamodel === undefined) {
            return;
        }

        var cmItem = cm.get(row); // contestant from contestant Table
        var selectedFilename = cmItem.filename; //

        lateSelect = -1;
        fileContestantPairModel.clear();
        for (var i = 0; i < datamodel.count; i++) {
            var filename = datamodel.get(i, "fileName");
            var filepath = datamodel.get(i, "filePath");
            var matchCount = 0;
            var contestant = "";
            for (var j = 0; j < cm.count; j++) {
                var item = cm.get(j);
                if (item.filename === filename) {
                    contestant = contestant + item.name + " ";
                    matchCount++;
                }
            }

            if (filename === selectedFilename) {
                lateSelect = i;
            }


            fileContestantPairModel.append
                    ({
                         "filepath" : filepath,
                         "filename" : filename,
                         "contestant" : contestant,
                         "matchCount" : matchCount,
                     })
        }


    }


    Component.onCompleted: {
        datamodel.countChanged.connect(folderModelChanged); // FolderListModel
        rowChanged.connect(folderModelChanged); // index of row in ContestantTable
        selectionTableView.rowCountChanged.connect(doLateSelect);
        selectionTableView.modelChanged.connect(doLateSelect);
        lateSelectChanged.connect(doLateSelect);
    }


    function doLateSelect() {
        if (lateSelect === -1) {
            selectionTableView.positionViewAtRow(0, ListView.Contain)
            return;
        }

        if (selectionTableView.rowCount > lateSelect) {
            selectionTableView.selection.clear();
            selectionTableView.selection.select(lateSelect);
            selectionTableView.positionViewAtRow(lateSelect, ListView.Contain)
        }
    }

    TableView {
        id: selectionTableView;
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10

        model: fileContestantPairModel;
        selectionMode: SelectionMode.SingleSelection;
        TableViewColumn {
            //% "Filename"
            title: qsTrId("IGC-Choose-dialog-filename")
            role: "filename"
        }
        TableViewColumn {
            //% "Contestant"
            title: qsTrId("IGC-Choose-dialog-contestant")
            role: "contestant"
        }
        TableViewColumn {
            //% "Count"
            title: qsTrId("IGC-Choose-dialog-match-count")
            role: "matchCount"
        }
        onDoubleClicked: {
            console.log(row)

                var filename = datamodel.get(row, "fileName");
                var filePath = datamodel.get(row, "filePath");
                choosenFilename(filename, filePath)

//            if (!found) {
//                choosenFilename("","");
//            }
            selectionTableView.selection.clear();

            igcChooseDialog.close();
            folderModelChanged();


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

                var found = false;

                selectionTableView.selection.forEach(function(rowIndex) {
                    var filename = datamodel.get(rowIndex, "fileName");
                    var filePath = datamodel.get(rowIndex, "filePath");
                    choosenFilename(filename, filePath)
                    found = true;
                    return;

                });

                if (!found) {
                    choosenFilename("","");
                }

                igcChooseDialog.close();
                folderModelChanged();


            }
        }

        Button {
            //% "None"
            text: qsTrId("IGC-Choose-Dialog-deselect")
            onClicked: {
                choosenFilename("", "");
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
