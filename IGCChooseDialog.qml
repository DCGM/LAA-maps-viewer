import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "functions.js" as F

ApplicationWindow {
    id: igcChooseDialog;
    modality: "WindowModal"
    width: 900;
    height: 700;

    //% "Choose IGC File"
    title: qsTrId("igc-choose-dialog");
    property variant datamodel; // igcFolderModel
    property variant cm; // contestantsListModel
    property int crow;
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

        var cmItem = cm.get(crow); // contestant from contestant Table

        var selectedFilename = cmItem === undefined ? "" : cmItem.filename; //

        lateSelect = -1;
        fileContestantPairModel.clear();
        for (var i = 0; i < datamodel.count; i++) {
            var filename = datamodel.get(i, "fileName");
            var filepath = datamodel.get(i, "filePath");
            var matchCount = 0;
            var contestant = "";
            var fixFirst = "00:00:00"
            var fixLast = "00:00:00"
            var fixCount = 0;
            for (var j = 0; j < cm.count; j++) {
                var item = cm.get(j);
                if (item.filename === filename) {
                    contestant = contestant + item.name + " ";
                    matchCount++;
                }
            }
            igc_helper.load(filepath, "00:00:00", false)
            fixCount = igc_helper.count;
            fixFirst = igc_helper.get(0).time
            fixFirst = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(fixFirst), applicationWindow.utc_offset_sec));
            fixLast = igc_helper.get(fixCount - 1).time
            fixLast = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(fixLast), applicationWindow.utc_offset_sec));

            fileContestantPairModel.append
                    ({
                         "filepath" : filepath,
                         "filename" : filename,
                         "contestant" : contestant,
                         "matchCount" : matchCount,
                         "fixFirst": fixFirst,
                         "fixLast": fixLast,
                         "fixCount": fixCount,
                         "date": igc_helper.date.toLocaleDateString(Qt.locale(locale), Locale.ShortFormat),
                         "altimeterSetting": igc_helper.altimeterSetting,
                         "competitionClass": igc_helper.competitionClass,
                         "competitionId": igc_helper.competitionId,
                         "manufacturer": igc_helper.manufacturer,
                         "frType": igc_helper.frType,
                         "gliderId": igc_helper.gliderId,
                         "gps": igc_helper.gps,
                         "pilot": igc_helper.pilot,
                     })

            if (filename === selectedFilename) {
                lateSelect = i;
            }
        }
    }

    Component.onCompleted: {
        datamodel.countChanged.connect(folderModelChanged); // FolderListModel
        crowChanged.connect(folderModelChanged); // index of row in ContestantTable
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
            selectionTableView.currentRow = lateSelect;
            selectionTableView.positionViewAtRow(lateSelect, ListView.Contain)

            //console.log("doen for " + lateSelect + "    " + selectionTableView.rowCount + " " + selectionTableView.currentRow)
        }
    }


    TableView {
        id: selectionTableView;
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10

        signal selectRow(int row);

        model: fileContestantPairModel;
        selectionMode: SelectionMode.SingleSelection;
        TableViewColumn {
            //% "Filename"
            title: qsTrId("IGC-Choose-dialog-filename")
            role: "filename"
            width: 250
        }
        TableViewColumn {
            //% "Contestant"
            title: qsTrId("IGC-Choose-dialog-contestant")
            role: "contestant"
            width: 300
        }
        TableViewColumn {
            //% "Crew count"
            title: qsTrId("IGC-Choose-dialog-match-count")
            role: "matchCount"
            width: 40
        }
        TableViewColumn {
            //% "First fix"
            title: qsTrId("IGC-Choose-dialog-fix-first")
            role: "fixFirst"
            width: 80
        }
        TableViewColumn {
            //% "Last fix"
            title: qsTrId("IGC-Choose-dialog-fix-last")
            role: "fixLast"
            width: 80
        }
        TableViewColumn {
            //% "Count of fixes"
            title: qsTrId("IGC-Choose-dialog-fix-count")
            role: "fixCount"
            width: 80
        }

        TableViewColumn {
            //% "Date"
            title: qsTrId("IGC-Choose-dialog-date")
            role: "date"
            width: 80
        }

        TableViewColumn {
            //% "Pilot"
            title: qsTrId("IGC-Choose-dialog-pilot")
            role: "pilot"
            width: 80
        }
        TableViewColumn {
            //% "Altimeter Setting"
            title: qsTrId("IGC-Choose-dialog-altimeterSetting")
            role: "altimeterSetting"
            width: 80
        }

        TableViewColumn {
            //% "competitionClass"
            title: qsTrId("IGC-Choose-dialog-competitionClass")
            role: "competitionClass"
            width: 80
        }

        TableViewColumn {
            //% "competitionId"
            title: qsTrId("IGC-Choose-dialog-competitionId")
            role: "competitionId"
            width: 80
        }
        TableViewColumn {
            //% "manufacturer"
            title: qsTrId("IGC-Choose-dialog-manufacturer")
            role: "manufacturer"
            width: 80
        }

        TableViewColumn {
            //% "frType"
            title: qsTrId("IGC-Choose-dialog-frType")
            role: "frType"
            width: 80
        }
        TableViewColumn {
            //% "gliderId"
            title: qsTrId("IGC-Choose-dialog-gliderId")
            role: "gliderId"
            width: 80
        }
        TableViewColumn {
            //% "gps"
            title: qsTrId("IGC-Choose-dialog-gps")
            role: "gps"
            width: 80
        }


        onDoubleClicked: {

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

                folderModelChanged();
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
