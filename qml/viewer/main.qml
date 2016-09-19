import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.1
import cz.mlich 1.0
import "functions.js" as F
import "csv.js" as CSVJS
import "md5.js" as MD5


ApplicationWindow {
    id: applicationWindow
    //% "Trajectory viewer"
    title: qsTrId("application-window-title")
    width: 1280
    height: 860

    property variant tracks;
    property variant trItem;
    property variant ctnt;

    property variant maxPointsArr;

    property int minContestantInCategory: 3
    property int _RAL1_count: 0
    property int _RAL2_count: 0
    property int _SAL1_count: 0
    property int _SAL2_count: 0
    property int _RWL1_count: 0
    property int _RWL2_count: 0
    property int _SWL1_count: 0
    property int _SWL2_count: 0
    property int _CUSTOM1_count: 0
    property int _CUSTOM2_count: 0
    property int _CUSTOM3_count: 0
    property int _CUSTOM4_count: 0

    property variant categoriesScorePoints: [];

    property bool generateResultsFlag: false;

    Component.onCompleted: {

        // load last competition settings
        competitionConfiguretion.competitionName = config.get("competitionName_default", "competitionName");
        competitionConfiguretion.competitionType = config.get("competitionType_default", "competitionType");
        competitionConfiguretion.competitionTypeText = competitionConfiguretion.getCompetitionTypeString(parseInt(competitionConfiguretion.competitionType));
        competitionConfiguretion.competitionDirector = config.get("competitionDirector_default", "competitionDirector");
        competitionConfiguretion.competitionDirectorAvatar = JSON.parse(config.get("competitionDirectorAvatar_default", ""));
        competitionConfiguretion.competitionArbitr = JSON.parse(config.get("competitionArbitr_default", ["competitionArbitr"]));
        competitionConfiguretion.competitionArbitrAvatar = JSON.parse(config.get("competitionArbitrAvatar_default", [""]));
        competitionConfiguretion.competitionDate = config.get("competitionDate_default", Qt.formatDateTime(new Date(), "yyMMdd"));
    }

    menuBar: MenuBar {
        id: menuToolBar
        Menu {
            //% "&File"
            title: qsTrId("main-file-menu")

            MenuItem {
                //% "&Set Environment"
                text: qsTrId("main-file-menu-set-environment")
                onTriggered: {
                    pathConfiguration.show()
                }
                shortcut: "Ctrl+E"
            }

            MenuItem {
                //% "&Set Competition"
                text: qsTrId("main-file-menu-set-competition")
                onTriggered: {
                    competitionConfiguretion.show()
                }
                shortcut: "Ctrl+C"
            }

            MenuItem {
                //% "&Download application"
                text: qsTrId("main-file-menu-download-application")
                onTriggered: {
                    selectCompetitionOnlineDialog.show();
                }
                shortcut: "Ctrl+W"
            }

            MenuItem {
                //% "Evaluate all data"
                text: qsTrId("main-file-menu-process-all");
                onTriggered: evaluate_all_data();
                shortcut: "Ctrl+D"
            }


            MenuItem {
                //% "Generate continuous results"
                text: qsTrId("main-file-menu-generate-continuous-results");
                onTriggered: generateContinuousResults();
                shortcut: "Ctrl+F"
            }

            MenuItem {
                //% "Generate final results"
                text: qsTrId("main-file-menu-generate-final-results");
                onTriggered: generateFinalResults();
                shortcut: "Ctrl+R"
            }

            //            MenuItem {
            //                //% "Export"
            //                text: qsTrId("main-file-menu-export")
            ////                enabled: (igcFilesTable.currentRow >= 0)
            //                onTriggered: {
            //                    exportFileDialog.open()
            //                }
            //            }


            MenuItem {
                //% "Exit"
                text: qsTrId("main-file-menu-exit")
                onTriggered: Qt.quit();
            }

        }

        Menu {
            //% "&Map"
            title: qsTrId("main-map-menu")
            ExclusiveGroup {
                id: mapTypeExclusive
            }

            MenuItem {
                //% "&None"
                text: qsTrId("main-map-menu-none")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "";
                    map.url_subdomains = [];
                }
                //                Component.onCompleted: { // default value
                //                    checked = true;
                //                    map.url = ""
                //                }

                shortcut: "Ctrl+1"
            }
            MenuItem {
                //% "&Local"
                text: qsTrId("main-map-menu-local")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    console.log("Cached OSM")
                    //map.url = QStandardPathsHomeLocation+"/.local/share/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = QStandardPathsApplicationFilePath + "/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = "../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    map.url = "/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    map.url_subdomains = [];

                }
                Component.onCompleted: { // default value

                    checked = true;
                    //map.url = QStandardPathsHomeLocation+"/.local/share/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = QStandardPathsApplicationFilePath + "/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = "../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    map.url = "/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    map.url_subdomains = [];
                }
                shortcut: "Ctrl+2"

            }
            MenuItem {
                //% "&OSM Mapnik"
                text: qsTrId("main-map-menu-osm")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
                    map.url_subdomains = ['a','b', 'c'];
                }
                shortcut: "Ctrl+3"

            }
            MenuItem {
                //% "Google &Roadmap"
                text: qsTrId("main-map-menu-google-roadmap")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.google.com/vt/lyrs=m@248407269&hl=x-local&x=%(x)d&y=%(y)d&z=%(zoom)d&s=Galileo"
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+4"

            }

            MenuItem {
                //% "Google &Terrain"
                text: qsTrId("main-map-menu-google-terrain")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.google.com/vt/lyrs=t,r&x=%(x)d&y=%(y)d&z=%(zoom)d"
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+5"
            }

            MenuItem {
                //% "Google &Satellite"
                text: qsTrId("main-map-menu-google-satellite")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    map.url = 'http://%(s)d.google.com/vt/lyrs=s&x=%(x)d&y=%(y)d&z=%(zoom)d';
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+6"
            }
            MenuItem {
                //% "Custom tile layer"
                text: qsTrId("main-map-menu-custom-tile-layer")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    mapurl_dialog.open();
                    map.url_subdomains = [];
                }
                shortcut: "Ctrl+7"
            }

            ExclusiveGroup {
                id: mapTypeSecondaryExclusive
            }


            MenuItem {
                //% "Airspace Off"
                text: qsTrId("main-map-menu-airspace-off")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                checked: true;
                onTriggered: {
                    map.airspaceUrl = ""
                    map.mapAirspaceVisible = false;
                }
            }

            MenuItem {
                //% "Airspace (prosoar.de)"
                text: qsTrId("main-map-menu-airspace-prosoar")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    map.airspaceUrl = "http://prosoar.de/airspace/%(zoom)d/%(x)d/%(y)d.png"
                    map.mapAirspaceVisible = true;
                }
            }

            MenuItem {
                //% "Airspace (local)"
                text: qsTrId("main-map-menu-airspace-local")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    map.airspaceUrl = QStandardPathsHomeLocation+"/.local/share/Maps/airspace/%(zoom)d/%(x)d/%(y)d.png"
                    map.mapAirspaceVisible = true;
                }
            }



            MenuItem {
                visible: false;
                id: loadGfwMenuItem
                //% "Load &gfw image"
                text: qsTrId("main-map-menu-gfw")
                checkable:  true;
                onTriggered: {
                    if (checked) {
                        gfwDialog.show();

                    }
                    console.log("gfw + gif")
                }
            }
        }

        Menu {
            //% "&View"
            title: qsTrId("main-view-menu")
            MenuItem {
                //% "Zoom to &track"
                text: qsTrId("main-view-menu-zoom-to-points")
                onTriggered: map.pointsInBounds();
                shortcut: "Ctrl+0"
            }
            MenuItem {
                //% "Zoom &in"
                text: qsTrId("main-view-menu-zoom-in")
                onTriggered: map.zoomIn();
            }
            MenuItem {
                //% "Zoom &out"
                text: qsTrId("main-view-menu-zoom-out")
                onTriggered: map.zoomOut();
            }
            MenuItem {
                id: mainViewMenuRuler;
                //% "&Ruler"
                text: qsTrId("main-view-menu-ruler")
                checkable: true;
                checked: map.showRuler
                onCheckedChanged: {
                    map.showRuler = checked

                }
            }
            MenuItem {
                id: mainViewMenuTables
                //% "&Tables"
                text: qsTrId("main-view-menu-tables")
                checkable: true;
                checked: true;
                shortcut: "Ctrl+T"
            }
            MenuItem {
                id: mainViewMenuAltChart
                //% "Altitude profile"
                text: qsTrId("main-view-menu-altchart")
                checkable: true;
                checked: false;
                shortcut: "Ctrl+A"
            }

            MenuItem {
                id: mainViewMenuCategoryCountersStatusBar
                //% "Category counters"
                text: qsTrId("main-view-menu-category-counters-sb")
                checkable: true;
                checked: true;
                //shortcut: "Ctrl+A"
            }
            MenuItem {
                id: mainViewMenuCompetitionPropertyStatusBar
                //% "Competition property"
                text: qsTrId("main-view-menu-comp-property-sb")
                checkable: true;
                checked: true;
                //shortcut: "Ctrl+A"
            }
        }

        Menu {
            //% "&Help"
            title: qsTrId("main-help-menu")
            MenuItem {
                //% "&About"
                text: qsTrId("main-help-menu-about")
                onTriggered: aboutDialog.show()
            }
        }
    }

    SelectCompetitionDialog {

        id: selectCompetitionOnlineDialog

        onContestantsDownloaded: {

            file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), csvString);

            pathConfiguration.ok();
        }
    }

    MyTranslator {

        id: qmlTranslator
    }

    TextDialog {
        id: mapurl_dialog;

        //% "Custom map tile configuration"
        title: qsTrId("main-map-dialog-title")

        //% "Enter URL"
        question: qsTrId("main-map-dialog-question")

        text: "http://m3.mapserver.mapy.cz/ophoto-m/%(zoom)d-%(x)d-%(y)d"
        onAccepted: {
            map.url = text;
        }

    }


    FileDialog {
        id: exportFileDialog;
        selectExisting: false;

        nameFilters: [
            "Keyhole Markup Language (*.kml)",
            "GPS exchange Format (*.gpx)",
        ]
        onAccepted: {
            var str = String(fileUrl);
            if (str.match(/\.kml$/)) {
                exportKml(fileUrl);
            } else if (str.match(/\.gpx$/)) {
                exportGpx(fileUrl);
            } else {
                console.error("unsupported file format (please add file extension)")
            }
        }
    }

    ImportDialog {

        id: importDataDialog

        onVisibleChanged: {

            if (!visible) {

                pathConfiguration.close();
                selectCompetitionOnlineDialog.close();

                checkAndRemoveContestantsInvalidPrevResults();

                igcFolderModel.folder = "";
                igcFolderModel.folder = pathConfiguration.igcDirectory;

                recalculateContestantsScoreOrder();

                storeTrackSettings(pathConfiguration.tsFile);
                map.requestUpdate();
            }
        }
    }

    CreateContestantDialog {

        id: createContestantDialog

        onOk: {

            if (createContestantDialog.comboBoxCurrentIndex === 0) {

                // assign new contestant to the current igc item
                igcFilesTable.selection.clear();
                igcFilesTable.selection.select(igcTableRow);
                igcFilesTable.currentRow = igcTableRow;

                igcFilesModel.setProperty(igcTableRow, "contestant", contestantsListModel.count - 1);
            }
            else {
                // update igc
                var igcItem = igcFilesModel.get(igcTableRow);
                var contestantIndex = igcItem.contestant;
                var igcName = igcItem.fileName

                igcFilesModel.setProperty(igcTableRow, "contestant", 0);    // igcFilesModel is sorted after this change

                for (var i = 0; i < igcFilesModel.count; i++) { // get new position of the igc item

                    if (igcFilesModel.get(i).fileName === igcName) {

                        // select current row and assign updated contestant
                        igcFilesTable.selection.clear();
                        igcFilesTable.selection.select(i);
                        igcFilesTable.currentRow = i;

                        igcFilesModel.setProperty(i, "contestant", contestantIndex);
                        break;
                    }
                }
            }
        }
    }

    CompetitionConfiguration {

        id: competitionConfiguretion;
    }


    CppWorker {

        id: cppWorker;
    }

    PathConfiguration {
        id: pathConfiguration;
        onOk: {

            // clear contestant in categories counters
            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile ))) {
                tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(pathConfiguration.trackFile )))
            } else {
                // cleanup
                //contestantsListModel.clear()

                //% "File %1 not found"
                errorMessage.text = qsTrId("path-configuration-error-trackFile-not-found").arg(pathConfiguration.trackFile);
                errorMessage.open();
                return;
            }

            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile))) {

                importDataDialog.listModel.clear();
                initCategoryCounters();

                console.time("load ctnt")
                loadContestants(Qt.resolvedUrl(pathConfiguration.contestantsFile))
                console.timeEnd("load ctnt")

            } else {

                //% "File %1 not found"
                //errorMessage.text = qsTrId("path-configuration-error-contestantsFile-not-found").arg(pathConfiguration.contestantsFile);
                //errorMessage.open();

                //% "Configuration error"
                contestnatsNotFoundMessage.title = qsTrId("path-configuration-error-contestantsFile-not-found-title");

                //% "File %1 not found. Do you want to download the file from the server?"
                contestnatsNotFoundMessage.text = qsTrId("path-configuration-error-contestantsFile-not-found-text").arg(pathConfiguration.contestantsFile.substring(8));
                contestnatsNotFoundMessage.open();

                return;
            }

            // load import dialog if needed, otherwise load IGC
            if (importDataDialog.listModel.count > 0) {

                importDataDialog.show();
            }
            else {
                checkAndRemoveContestantsInvalidPrevResults();

                igcFolderModel.folder = "";
                igcFolderModel.folder = pathConfiguration.igcDirectory;

                recalculateContestantsScoreOrder();

                storeTrackSettings(pathConfiguration.tsFile);
                map.requestUpdate();

            }

        }
        onCancel: {
        }
    }

    ListModel {

        id: competitionClassModel

        ListElement { text: "-"}
        ListElement { text: "R-AL1"}
        ListElement { text: "R-AL2"}
        ListElement { text: "S-AL1"}
        ListElement { text: "S-AL2"}
        ListElement { text: "R-WL1"}
        ListElement { text: "R-WL2"}
        ListElement { text: "S-WL1"}
        ListElement { text: "S-WL2"}
        ListElement { text: "CUSTOM1"}
        ListElement { text: "CUSTOM2"}
        ListElement { text: "CUSTOM3"}
        ListElement { text: "CUSTOM4"}
    }

    FolderListModel {

        id: igcFolderModel
        nameFilters: ["*.igc", "*.IGC"]
        showDirs: false
        //        property string previousFolder;

        //        onCountChanged: {
        //            if (previousFolder != igcFolderModel.folder) { // beware do not compare with !== operator (string !== object)
        //                igcFilesModel.clear()
        //                previousFolder = igcFolderModel.folder;
        //            }

        //            for (var i = 0; i < igcFolderModel.count; i++) {

        //                var fileName = igcFolderModel.get(i, "fileName")
        //                var filePath = igcFolderModel.get(i, "filePath");

        //                var found = false;

        //                for (var j = 0; j < igcFilesModel.count; j++) {
        //                    var item = igcFilesModel.get(j);
        //                    if ((item.fileName === fileName) && (item.filePath === filePath)) {

        //                        found = true;
        //                    }
        //                }


        //                if (!found) {

        //                    // select item in combobox if filename match
        //                    var contestant_index = 0;
        //                    var contestant;
        //                    for (var j = 0; j < contestantsListModel.count; j++) {

        //                        contestant = contestantsListModel.get(j);

        //                        if (fileName === contestant.filename) {
        //                            contestant_index = j;
        //                        }

        //                    }

        //                    contestant = contestantsListModel.get(contestant_index);

        //                    igcFilesModel.append({"fileName": fileName,
        //                                          "filePath": filePath,
        //                                          "score": "",
        //                                          "score_json": "",
        //                                          contestant: contestant_index,
        //                                          "scorePoints" : -1,
        //                                          "scorePoints1000" : -1,
        //                                          "startTime" : "00:00:00",
        //                                          "category" : "",
        //                                          "speed" : -1,
        //                                          "classify" : -1,
        //                                          "aircraftRegistration" : "",
        //                                          "wptScoreDetails" : "",
        //                                          "trackHash": "",
        //                                          "speedSectionsScoreDetails" : "",
        //                                          "spaceSectionsScoreDetails" : "",
        //                                          "altitudeSectionsScoreDetails" : "",
        //                                          "classOrder": -1
        //                                         })

        //                }
        //            }
        //        }
    }

    //    ListModel {
    //        id: igcFilesModel
    //        onDataChanged: {

    //            if (igcFilesTable.currentRow < 0) {
    //                igcFilesTable.rowSelected();
    //            }
    //        }
    //    }

    ListModel {
        id: wptScoreList
    }

    // ListModel {
    //listModel of listmodels for track points score
    //    id: wptNewScoreList
    // }

    // ListModel {
    //     id: speedSectionsScoreList
    // }

    ListModel {
        id: contestantsListModel
    }

    ListModel {// for reload prev manual values, cache
        id: wptNewScoreListManualValuesCache
    }

    ListModel {// for reload prev manual values
        id: speedSectionsScoreListManualValuesCache
    }

    ListModel {// for reload prev manual values
        id: spaceSectionsScoreListManualValuesCache
    }

    ListModel {// for reload prev manual values
        id: altSectionsScoreListManualValuesCache
    }

    ResultsWindow {

        id: resultsWindow

        onOk: {

            //copy manual values into list models
            var contestantIndex = igcFilesModel.get(igcFilesTable.currentRow).contestant;
            contestantsListModel.setProperty(contestantIndex, "markersOk", curentContestant.markersOk);
            contestantsListModel.setProperty(contestantIndex, "markersNok", curentContestant.markersNok);
            contestantsListModel.setProperty(contestantIndex, "markersFalse", curentContestant.markersFalse);
            contestantsListModel.setProperty(contestantIndex, "markersScore", curentContestant.markersScore);
            contestantsListModel.setProperty(contestantIndex, "photosOk", curentContestant.photosOk);
            contestantsListModel.setProperty(contestantIndex, "photosNok", curentContestant.photosNok);
            contestantsListModel.setProperty(contestantIndex, "photosFalse", curentContestant.photosFalse);
            contestantsListModel.setProperty(contestantIndex, "photosScore", curentContestant.photosScore);
            contestantsListModel.setProperty(contestantIndex, "startTimeMeasured", curentContestant.startTimeMeasured);
            contestantsListModel.setProperty(contestantIndex, "startTimeDifference", curentContestant.startTimeDifference);
            contestantsListModel.setProperty(contestantIndex, "startTimeScore", curentContestant.startTimeScore);
            contestantsListModel.setProperty(contestantIndex, "landingScore", curentContestant.landingScore);
            contestantsListModel.setProperty(contestantIndex, "circlingCount", curentContestant.circlingCount);
            contestantsListModel.setProperty(contestantIndex, "circlingScore", curentContestant.circlingScore);
            contestantsListModel.setProperty(contestantIndex, "oppositeCount", curentContestant.oppositeCount);
            contestantsListModel.setProperty(contestantIndex, "oppositeScore", curentContestant.oppositeScore);
            contestantsListModel.setProperty(contestantIndex, "otherPoints", curentContestant.otherPoints);
            contestantsListModel.setProperty(contestantIndex, "otherPointsNote", curentContestant.otherPointsNote);
            contestantsListModel.setProperty(contestantIndex, "otherPenalty", curentContestant.otherPenalty);
            contestantsListModel.setProperty(contestantIndex, "otherPenaltyNote", curentContestant.otherPenaltyNote);

            // reload current contestant
            ctnt = contestantsListModel.get(contestantIndex);

            // load and save modified score lists
            igcFilesModel.setProperty(igcFilesTable.currentRow, "wptScoreDetails", resultsWindow.currentWptScoreString);

            igcFilesModel.setProperty(igcFilesTable.currentRow, "speedSectionsScoreDetails", resultsWindow.currentSpeedSectionsScoreString);
            igcFilesModel.setProperty(igcFilesTable.currentRow, "altitudeSectionsScoreDetails", resultsWindow.currentAltitudeSectionsScoreString);
            igcFilesModel.setProperty(igcFilesTable.currentRow, "spaceSectionsScoreDetails", resultsWindow.currentSpaceSectionsScoreString);

            // recalculate score
            var score = getTotalScore(ctnt, igcFilesTable.currentRow);
            igcFilesModel.setProperty(igcFilesTable.currentRow, "scorePoints", score);
            recalculateScoresTo1000();

            // save changes into CSV
            writeScoreManulaValToCSV();
        }
    }

    IGCChooseDialog {
        id: igcChooseDialog
        datamodel: igcFolderModel
        onChoosenFilename: {
            contestantsListModel.setProperty(row, "fileName", filename)
        }
    }



    SplitView {
        id: splitView
        anchors.fill: parent;
        orientation: Qt.Horizontal

        ///// IGC file list

        TableView {
            id: contestantsTable;
            model: contestantsListModel;
            width: 1110;
            clip: true;
            itemDelegate: ContestantsDelegate {
                onChangeIgc: {
                    igcChooseDialog.row = row;
                    igcChooseDialog.show();
                }
            }


            rowDelegate: Rectangle {
                height: 30;
                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")
            }


            TableViewColumn {
                //% "Contestant"
                title: qsTrId("filelist-table-contestants")
                role: "name"
            }

            TableViewColumn {
                //% "File name"
                title: qsTrId("filelist-table-filename")
                role: "fileName";
            }
            TableViewColumn {
                //% "Category"
                title: qsTrId("filelist-table-category")
                role: "category"
                width: 120
            }
            TableViewColumn {
                //% "Speed"
                title: qsTrId("filelist-table-speed")
                role: "speed"
                width: 60
            }
            TableViewColumn {
                //% "StartTime"
                title: qsTrId("filelist-table-start-time")
                role: "startTime"
                width: 100
            }
            TableViewColumn {
                //% "Aircraft registration"
                title: qsTrId("filelist-table-aircraft-registration")
                role: "aircraft_registration"
                width: 120
            }
            TableViewColumn {
                //% "Score"
                title: qsTrId("filelist-table-score")
                role: "scorePoints"
                width: 120
            }
            TableViewColumn {
                //% "Score to 1000"
                title: qsTrId("filelist-table-score-to-1000")
                role: "scorePoints1000"
                width: 120
            }
            TableViewColumn {
                //% "Class order"
                title: qsTrId("filelist-table-class-order")
                role: "classOrder"
                width: 60
            }
            TableViewColumn {
                //% "Classify"
                title: qsTrId("filelist-table-classify")
                role: "classify"
                width: 80
            }


        }

        //        TableView {
        //            visible: false;

        //            Rectangle { // disable
        //                color: "#ffffff";
        //                opacity: 0.7;
        //                anchors.fill: parent;
        //                visible: evaluateTimer.running || resultsTimer.running;
        //                MouseArea {
        //                    anchors.fill: parent;
        //                    onClicked: {

        //                        if (evaluateTimer.running) {

        //                            console.log("onClick is disabled when evaluateTimer.running");
        //                            evaluateTimer.running = false;
        //                        }
        //                        else if (resultsTimer.running) {

        //                            console.log("onClick is disabled when resultsTimer.running");
        //                            resultsTimer.running = false;
        //                        }
        //                    }
        //                }
        //            }

        //            id: igcFilesTable
        //            width: 1110;
        ////            visible: mainViewMenuTables.checked
        //            clip: true;
        //            model: igcFilesModel

        //            itemDelegate: IgcFilesDelegate {

        //                id: igcFilesDelegate
        //                comboModel: contestantsListModel

        //                onShowResults: {

        //                    // load contestant property
        //                    ctnt = contestantsListModel.get(igcFilesModel.get(row).contestant);

        //                    // TODO - prasarna aby byla kopie a ne stejny objekt
        //                    resultsWindow.curentContestant = JSON.parse(JSON.stringify(ctnt));

        //                    // load contestant score list
        //                    resultsWindow.wptScore = igcFilesModel.get(row).wptScoreDetails;

        //                    // load sections string
        //                    resultsWindow.speedSections = igcFilesModel.get(row).speedSectionsScoreDetails;
        //                    resultsWindow.altSections = igcFilesModel.get(row).altitudeSectionsScoreDetails;
        //                    resultsWindow.spaceSections = igcFilesModel.get(row).spaceSectionsScoreDetails;

        //                    // load cattegory property
        //                    var arr = tracks.tracks;
        //                    var currentTrck;

        //                    var found = false;
        //                    resultsWindow.time_window_penalty = 0;
        //                    resultsWindow.time_window_size = 0;
        //                    resultsWindow.photos_max_score = 0;
        //                    resultsWindow.oposite_direction_penalty = 0;
        //                    resultsWindow.marker_max_score = 0;
        //                    resultsWindow.gyre_penalty = 0;

        //                    for (var i = 0; i < arr.length; i++) {
        //                        currentTrck = arr[i];

        //                        if (currentTrck.name === ctnt.category) {

        //                            resultsWindow.time_window_penalty = currentTrck.time_window_penalty; //penalty percent
        //                            resultsWindow.time_window_size = currentTrck.time_window_size;
        //                            resultsWindow.photos_max_score = currentTrck.photos_max_score;
        //                            resultsWindow.oposite_direction_penalty = currentTrck.oposite_direction_penalty; //penalty percent
        //                            resultsWindow.marker_max_score = currentTrck.marker_max_score;
        //                            resultsWindow.gyre_penalty = currentTrck.gyre_penalty; //penalty percent
        //                            break;
        //                        }
        //                    }

        //                    // select row
        //                    igcFilesTable.selection.clear();
        //                    igcFilesTable.selection.select(row);
        //                    igcFilesTable.currentRow = row;

        //                    resultsWindow.show();
        //                }

        //                onSelectRow: {

        //                    igcFilesTable.selection.clear();
        //                    igcFilesTable.selection.select(row);
        //                    igcFilesTable.currentRow = row;
        //                }

        //                onRecalculateResults: {

        //                    igcFilesModel.setProperty(row, "score", "");        //compute new score
        //                    igcFilesModel.setProperty(row, "scorePoints", -1);
        //                    igcFilesModel.setProperty(row, "scorePoints1000", -1);

        //                    igcFilesTable.selection.clear();
        //                    igcFilesTable.selection.select(row);
        //                    igcFilesTable.currentRow = row;
        //                }

        //                onGenerateResults: {

        //                    igcFilesTable.selection.clear();
        //                    igcFilesTable.selection.select(row);
        //                    igcFilesTable.currentRow = row;

        //                    // load contestant and igc row
        //                    var item = igcFilesModel.get(row);
        //                    var contestant = contestantsListModel.get(item.contestant);

        //                    // create contestant html file
        //                    results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
        //                                                                JSON.stringify(contestant),
        //                                                                JSON.stringify(item),
        //                                                                competitionConfiguretion.competitionName,
        //                                                                competitionConfiguretion.getCompetitionTypeString(parseInt(competitionConfiguretion.competitionType)),
        //                                                                competitionConfiguretion.competitionDirector,
        //                                                                competitionConfiguretion.competitionDirectorAvatar,
        //                                                                competitionConfiguretion.competitionArbitr,
        //                                                                competitionConfiguretion.competitionArbitrAvatar,
        //                                                                competitionConfiguretion.competitionDate);
        //                }

        //                onChangeModel: {

        //                    //console.log("row: " + row + " role: " + role + " value: " + value + " count: " + igcFilesModel.count)

        //                    if (row >= igcFilesModel.count) {
        //                        console.log("WUT? row role value " +row + " " +role + " " +value)
        //                        return;
        //                    }

        //                    var prevRow = igcFilesTable.currentRow
        //                    var contestant;
        //                    var prevCategory = igcFilesModel.get(row).category;
        //                    var prevName = igcFilesModel.get(row).fileName;

        //                    igcFilesModel.setProperty(row, role, value)
        //                    var ctIndex = igcFilesModel.get(row).contestant;

        //                    if (role === "contestant") {

        //                        //copy values from contestant model into igc model
        //                        updateContestantDetailsIgcListModel(row);
        //                    }
        //                    else if (role === "speed" || role === "startTime" || role === "category") {

        //                        contestantsListModel.setProperty(ctIndex, role, value);
        //                        contestantsListModel.setProperty(ctIndex, "fullName", contestantsListModel.get(ctIndex).name + "_" + contestantsListModel.get(ctIndex).category);
        //                    }

        //                    // load prev results or clear current
        //                    contestant = contestantsListModel.get(ctIndex);

        //                    if (role === "contestant" || role === "speed" || role === "startTime" || role === "category") {

        //                        // load contestant category
        //                        for (var t = 0; t < tracks.tracks.length; t++) {

        //                            if (tracks.tracks[t].name === contestant.category)
        //                                trItem = tracks.tracks[t]
        //                        }

        //                        // recalculate manual values score / markers, photos, ...
        //                        if (ctIndex !== 0) recalculateContestnatManualScoreValues(row);

        //                        // reload update ctnt
        //                        contestant = contestantsListModel.get(ctIndex);

        //                        // no results for this values
        //                        if (ctIndex === 0 || !resultsExist(contestant.speed,
        //                                          contestant.startTime,
        //                                          contestant.category,
        //                                          igcFilesModel.get(row).fileName,
        //                                          MD5.MD5(JSON.stringify(trItem)),
        //                                          contestant.prevResultsSpeed,
        //                                          contestant.prevResultsStartTime,
        //                                          contestant.prevResultsCategory,
        //                                          contestant.prevResultsFileName,
        //                                          contestant.prevResultsTrackHas)) {

        //                            igcFilesModel.setProperty(row, "score", "");        //compute new score
        //                            igcFilesModel.setProperty(row, "scorePoints", -1);
        //                            igcFilesModel.setProperty(row, "scorePoints1000", -1);

        //                            igcFilesModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
        //                            igcFilesModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
        //                            igcFilesModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
        //                            igcFilesModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);

        //                        }
        //                        // load prev results
        //                        else {

        //                            igcFilesModel.setProperty(row, "trackHash", contestant.prevResultsTrackHas);
        //                            igcFilesModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
        //                            igcFilesModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
        //                            igcFilesModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
        //                            igcFilesModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
        //                            igcFilesModel.setProperty(row, "score_json", contestant.prevResultsScoreJson)
        //                            igcFilesModel.setProperty(row, "score", contestant.prevResultsScore)
        //                            igcFilesModel.setProperty(row, "scorePoints", contestant.prevResultsScorePoints);
        //                        }
        //                    }

        //                    // change continuous results models
        //                    if (role === "category") {

        //                        // decrease prev category counter
        //                        if (prevCategory !== "-" && value !== prevCategory) {
        //                            updateContestantInCategoryCounters(prevCategory, false);
        //                        }

        //                        // increase actual category counter
        //                        updateContestantInCategoryCounters(value, true);
        //                    }

        //                    if (role === "startTime" || role === "contestant") sortIgcFilesModelByStartTime();

        //                    // select row
        //                    if (prevRow === row) {

        //                        igcFilesTable.selection.clear();

        //                        for (var i = 0; i < igcFilesModel.count; i++) {
        //                            if (igcFilesModel.get(i).fileName === prevName && prevName !== undefined)
        //                                row = i;
        //                        }

        //                        igcFilesTable.selection.select(row);
        //                        igcFilesTable.currentRow = row;

        //                    }

        //                    // save results into CSV
        //                    writeCSV();
        //                    recalculateScoresTo1000();
        //                    writeScoreManulaValToCSV();
        //                }
        //            }


        //            rowDelegate: Rectangle {
        //                height: 30;
        //                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")
        //            }


        //            TableViewColumn {
        //                //% "File name"
        //                title: qsTrId("filelist-table-filename")
        //                role: "fileName";
        //            }
        //            TableViewColumn {
        //                //% "Contestant"
        //                title: qsTrId("filelist-table-contestants")
        //                role: "contestant"
        //            }
        //            TableViewColumn {
        //                //% "Category"
        //                title: qsTrId("filelist-table-category")
        //                role: "category"
        //                width: 120
        //            }
        //            TableViewColumn {
        //                //% "Speed"
        //                title: qsTrId("filelist-table-speed")
        //                role: "speed"
        //                width: 60
        //            }
        //            TableViewColumn {
        //                //% "StartTime"
        //                title: qsTrId("filelist-table-start-time")
        //                role: "startTime"
        //                width: 100
        //            }
        //            TableViewColumn {
        //                //% "Aircraft registration"
        //                title: qsTrId("filelist-table-aircraft-registration")
        //                role: "aircraftRegistration"
        //                width: 120
        //            }
        //            TableViewColumn {
        //                //% "Score"
        //                title: qsTrId("filelist-table-score")
        //                role: "scorePoints"
        //                width: 120
        //            }
        //            TableViewColumn {
        //                //% "Score to 1000"
        //                title: qsTrId("filelist-table-score-to-1000")
        //                role: "scorePoints1000"
        //                width: 120
        //            }
        //            TableViewColumn {
        //                //% "Class order"
        //                title: qsTrId("filelist-table-class-order")
        //                role: "classOrder"
        //                width: 60
        //            }
        //            TableViewColumn {
        //                //% "Classify"
        //                title: qsTrId("filelist-table-classify")
        //                role: "classify"
        //                width: 80
        //            }

        //            Component.onCompleted: {
        //                selection.selectionChanged.connect(rowSelected);
        //            }

        //            function rowSelected() {

        //              //  console.log("row selected")

        //                if (igcFilesModel.count <= 0) {
        //                    return;
        //                }

        //                var current = -1;

        //                igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

        //                if (current < 0) {
        //                    return;
        //                }

        //                var item = model.get(current)

        //                if (item.contestant >= contestantsListModel.count) {
        //                    console.log("incorrect contestant id " + item.contestant + " " + contestantsListModel.count)
        //                    return;
        //                }

        //                ctnt = contestantsListModel.get(item.contestant)


        //                var arr = tracks.tracks;

        //                var found = false;
        //                for (var i = 0; i < arr.length; i++) {
        //                    trItem = arr[i];

        //                    if (trItem.name === ctnt.category) {
        //                        map.filterCupCategory = i;
        //                        map.filterCupData = 2;
        //                        found = true;
        //                        break;
        //                    }
        //                }
        //                if (!found) {
        //                    map.filterCupData = 3
        //                    console.log("ctnt.category \"" + ctnt.category + "\" not found in track!")
        //                }

        //                //                console.log("setFilter" + ctnt.startTime)
        //                tool_bar.startTime = ctnt.startTime
        //                igc.load( item.filePath, ctnt.startTime)

        //                map.requestUpdate()
        //                altChart.igcUpdate();

        //            }
        //        }



        ///// Map
        Rectangle {
            id: pinchMapOuter
            width: 400;
            Layout.fillWidth: true

            clip: true;



            PinchMap {
                id: map
                //                anchors.fill: parent;
                anchors.left: parent.left;
                anchors.right: parent.right;
                anchors.top: parent.top;
                anchors.bottom: altChartRect.top;
                height: parent.height
                gpsModel: igc;
                trackModel: tracks;
                filterCupData: 2
                currentPositionShow: true;


                onTpiComputedData:  {
                    computeScore(tpi, polys)
                }
            }

            Rectangle {
                id: altChartRect

                visible: mainViewMenuAltChart.checked
                color: "#ffffff"
                height: visible ? 200 : 0;
                anchors.bottom: parent.bottom;
                anchors.left: parent.left;
                anchors.right: parent.right;
                AltChart {
                    id: altChart
                    anchors.margins: 10;
                    anchors.fill: parent;
                    gpsModel: igc;
                    currentPositionIndex: map.currentPositionIndex;
                    onXClicked: {
                        map.currentPositionIndex = pos;
                    }
                }
            }

        }

        /*
        TableView {

            id: results
            width: 400

            sortIndicatorVisible: true
            sortIndicatorColumn: 6

            clip: true;

            model: SortFilterProxyModel {
                id: proxyModel
                source: results_RAL2_listModel.count > 0 ? results_RAL2_listModel : null


                sortOrder: results.sortIndicatorOrder
                sortCaseSensitivity: Qt.CaseInsensitive
                sortRole: results_RAL2_listModel.count > 0 ? results.getColumn(results.sortIndicatorColumn).role : ""

                filterSyntax: SortFilterProxyModel.Wildcard
                filterCaseSensitivity: Qt.CaseInsensitive
            }


            //% "Name"
            TableViewColumn { title: qsTrId("score-table-name"); role: "ctntName"; width: 50; }
            //% "Category"
            TableViewColumn { title: qsTrId("score-table-category"); role: "ctntCategory"; width: 50; }
            //% "Speed"
            TableViewColumn { title: qsTrId("score-table-speed"); role: "ctntSpeed"; width: 50; }
            //% "Start time"
            TableViewColumn { title: qsTrId("score-table-startTime"); role: "ctntStartTime"; width: 50; }
            //% "Aircraft registration"
            TableViewColumn { title: qsTrId("score-table-aircraft-registration"); role: "ctntAircraftRegistration"; width: 50; }
            //% "Aircraft type"
            TableViewColumn { title: qsTrId("score-table-aircraft-type"); role: "ctntAircraftType"; width: 50; }
            //% "Score points"
            TableViewColumn { title: qsTrId("score-table-score"); role: "scorePoints"; width: 50; }
            //% "Score points 1000"
            TableViewColumn { title: qsTrId("score-table-score1000"); role: "scorePoints1000"; width: 50; }

        }
        */




        TableView {
            id: scoreTable
            model: wptScoreList
            //visible: mainViewMenuTables.checked
            visible: false

            width: 200
            //% "Name"
            TableViewColumn { title: qsTrId("score-table-name"); role: "title"; width: 100; }
            //% "Time"
            TableViewColumn { title: qsTrId("score-table-time"); role: "time"; width: 100; }
            //% "Altitude"
            TableViewColumn { title: qsTrId("score-table-altitude"); role: "alt"; width: 50;}
            //% "Visited TP"
            TableViewColumn { title: qsTrId("score-table-visited"); role: "hit"; width: 50;}
            //% "Visited SG"
            TableViewColumn { title: qsTrId("score-table-space-gate-visited"); role: "sg_hit"; width: 50;}
            //% "Latitude"
            TableViewColumn { title: qsTrId("score-table-latitude"); role: "lat"; width: 100;}
            //% "Longitude"
            TableViewColumn { title: qsTrId("score-table-longitude"); role: "lon"; width: 100;}
            //% "Radius"
            TableViewColumn { title: qsTrId("score-table-radius"); role: "radius"; width: 100;}
            //% "Section speed"
            TableViewColumn { title: qsTrId("score-table-section-speed"); role: "speed"; width: 100; }

            //% "Section min altitude"
            TableViewColumn { title: qsTrId("score-table-alt-min"); role: "altmin"; width: 100; }
            //% "Section min altitude time"
            TableViewColumn { title: qsTrId("score-table-alt-min-time"); role: "altmintime"; width: 100; }
            //% "Section min altitude crossings"
            TableViewColumn { title: qsTrId("score-table-alt-min-count"); role: "altmincount"; width: 100; }
            //% "Section min altitude time spent out"
            TableViewColumn { title: qsTrId("score-table-alt-min-time-spent"); role: "altmintime_spent"; width: 100; }

            //% "Section max altitude"
            TableViewColumn { title: qsTrId("score-table-alt-max"); role: "altmax"; width: 100; }
            //% "Section max altitude time"
            TableViewColumn { title: qsTrId("score-table-alt-max-time"); role: "altmaxtime"; width: 100; }
            //% "Section max altitude crossings"
            TableViewColumn { title: qsTrId("score-table-alt-max-count"); role: "altmaxcount"; width: 100; }
            //% "Section max altitude time spent out"
            TableViewColumn { title: qsTrId("score-table-alt-max-time-spent"); role: "altmaxtime_spent"; width: 100; }

            //% "Section max distance"
            TableViewColumn { title: qsTrId("score-table-distance-max"); role: "distance"; width: 100; }
            //% "Section max distance time"
            TableViewColumn { title: qsTrId("score-table-distance-max-time"); role: "distancetime"; width: 100; }
            //% "Section max distance crossing"
            TableViewColumn { title: qsTrId("score-table-distance-out-count"); role: "distanceoutcount"; width: 100; }
            //% "Section max distance time spent out"
            TableViewColumn { title: qsTrId("score-table-distance-out-spent"); role: "distanceoutspent"; width: 100; }

            //% "Section max distance crossing (both)"
            TableViewColumn { title: qsTrId("score-table-distance-out-bi-count"); role: "distanceoutbicount"; width: 100; }
            //% "Section max distance time spent out (both)"
            TableViewColumn { title: qsTrId("score-table-distance-out-bi-spent"); role: "distanceoutbispent"; width: 100; }


            onCurrentRowChanged: {
                if ((scoreTable.currentRow < 0) || (wptScoreList.count <= scoreTable.currentRow)) {
                    return;
                }

                var item = wptScoreList.get(currentRow)
                map.tracksSelectedTid = item.tid

            }

            itemDelegate: Item {
                NativeText {
                    width: parent.width
                    anchors.margins: 4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    elide: styleData.elideMode
                    text: getTextForRole(styleData.row, styleData.role, styleData.value);
                    color: styleData.textColor;

                }
                function getTextForRole(row, role, value) {
                    switch (role) {
                    case "hit":
                    case "sg_hit":
                        return value
                        //% "YES"
                                ? qsTrId("hit-yes")
                                  //% "NO"
                                : qsTrId("hit-no")

                        break;
                    default:
                        return value;
                    }
                }
            }

        }
    }

    FileReader {
        id: file_reader
    }

    ImageSaver {
        id: imageSaver;
    }

    ResultsCreater {
        id: results_creator;
    }

    IgcFile {
        id: igc
        onCountChanged: {
            if (count === 0) {
                return;
            }

        }
    }


    Item {
        id: printMapWindow
        width: 750;
        height: 530;
        visible: false;
        onVisibleChanged: {
            if (visible) {
                printMap.requestUpdate();
            }
        }

        function makeImage() {
            printMapWindow.visible = true;
        }

        PrintMap {
            id: printMap;
            anchors.left: parent.left;
            anchors.top: parent.top;
            width: parent.width;
            height: parent.height;

            gpsModel: igc;
            polygonCache: map.polygonCache

            onImageReady: {
                if (polygonCache === undefined) {
                    return;
                }

                var current = -1;
                igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )
                if (current < 0) {
                    return;
                }

                var item = igcFilesModel.get(current);
                var con = item.contestant;
                if (con <= 0) {
                    printMapWindow.visible = false;
                    return;
                }

                var conDetail = contestantsListModel.get(con);
                imageSaver.save(printMap, Qt.resolvedUrl(pathConfiguration.resultsFolder+"/"+conDetail.fullName+".png"))
                printMapWindow.visible = false;
            }
        }
    }



    statusBar: StatusBar {
        id: tool_bar

        property string startTime

        Column {

            spacing: 5

            Row {
                spacing: 20;

                NativeText {
                    text: (tracks !== undefined)
                          ? F.basename(pathConfiguration.trackFile)
                            //% "No track loaded"
                          : qsTrId("status-no-track-loaded")
                }

                NativeText {
                    text: map.currentPositionTime
                    visible: (text !== "")
                }

                NativeText {
                    text: map.currentPositionAltitude + " m";
                    visible: (map.currentPositionAltitude !== "");
                }

                NativeText {
                    // text: F.formatDistance(map.rulerDistance, {'distanceUnit':'m'})
                    text: map.rulerDistance.toFixed(1)+ " m"
                    visible: (map.rulerDistance > 0)
                }

                NativeText {

                    //% "(Start time: %1)"
                    text: qsTrId("toolbar-start-time").arg(tool_bar.startTime);
                    visible: tool_bar.startTime !== "";

                }

                NativeText {
                    //% "Invalid %n"
                    text: qsTrId("toolbar-invalid-fixes", igc.invalidCount);
                    visible: igc.invalidCount > 0;
                    color: (igc.invalidCount > 500) ? "#ff0000" : "#000000";
                }

                NativeText {
                    //% "Trimmed %n"
                    text: qsTrId("toolbar-trimmed-fixes", igc.trimmedCount);
                    visible: igc.trimmedCount > 0;
                }

                NativeText {
                    //% "Fixes %n"
                    text: qsTrId("toolbar-igc-count", igc.count)
                    visible: (igc.count + igc.trimmedCount + igc.invalidCount) > 0
                    font.bold: (igc.count < 500);
                    color: (igc.count < 500) ? "red" : "black"
                }
            }

            Row {
                id: statusBarCompetitionProperty
                visible: mainViewMenuCompetitionPropertyStatusBar.checked;

                //property int columns: 5
                spacing: 40

                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: competitionConfiguretion.competitionName }
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-type") + ": " + competitionConfiguretion.competitionTypeText}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-director") + ": " +  competitionConfiguretion.competitionDirector}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-arbitr") + ": " +  competitionConfiguretion.competitionArbitr.join(", ")}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-date") + ": " +  competitionConfiguretion.competitionDate}
            }

            Row {
                id: statusBarCategoryCounters
                visible: mainViewMenuCategoryCountersStatusBar.checked;

                property int columns: 12

                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'R-AL1: ' +  applicationWindow._RAL1_count; color: applicationWindow._RAL1_count < applicationWindow.minContestantInCategory && applicationWindow._RAL1_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'R-AL2: ' +  applicationWindow._RAL2_count; color: applicationWindow._RAL2_count < applicationWindow.minContestantInCategory && applicationWindow._RAL2_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'S-AL1: ' +  applicationWindow._SAL1_count; color: applicationWindow._SAL1_count < applicationWindow.minContestantInCategory && applicationWindow._SAL1_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'S-AL2: ' +  applicationWindow._SAL2_count; color: applicationWindow._SAL2_count < applicationWindow.minContestantInCategory && applicationWindow._SAL2_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'R-WL1: ' +  applicationWindow._RWL1_count; color: applicationWindow._RWL1_count < applicationWindow.minContestantInCategory && applicationWindow._RWL1_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'R-WL2: ' +  applicationWindow._RWL2_count; color: applicationWindow._RWL2_count < applicationWindow.minContestantInCategory && applicationWindow._RWL2_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'S-WL1: ' +  applicationWindow._SWL1_count; color: applicationWindow._SWL1_count < applicationWindow.minContestantInCategory && applicationWindow._SWL1_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'S-WL2: ' +  applicationWindow._SWL2_count; color: applicationWindow._SWL2_count < applicationWindow.minContestantInCategory && applicationWindow._SWL2_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'CUSTOM1: ' +  applicationWindow._CUSTOM1_count; color: applicationWindow._CUSTOM1_count < applicationWindow.minContestantInCategory && applicationWindow._CUSTOM1_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'CUSTOM2: ' +  applicationWindow._CUSTOM2_count; color: applicationWindow._CUSTOM2_count < applicationWindow.minContestantInCategory && applicationWindow._CUSTOM2_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'CUSTOM3: ' +  applicationWindow._CUSTOM3_count; color: applicationWindow._CUSTOM3_count < applicationWindow.minContestantInCategory && applicationWindow._CUSTOM3_count > 0 ? "red" : "black" }
                NativeText { width: applicationWindow.width/statusBarCategoryCounters.columns; text: 'CUSTOM4: ' +  applicationWindow._CUSTOM4_count; color: applicationWindow._CUSTOM4_count < applicationWindow.minContestantInCategory && applicationWindow._CUSTOM4_count > 0 ? "red" : "black" }
            }
        }
    }


    function generateFinalResults() {

        // set flag, whitch will be check when all data would be succesfully evaluated
        generateResultsFlag = true;

        // eval all data
        evaluate_all_data();
    }


    // Copy contestant details into igc file list model
    function updateContestantDetailsIgcListModel(igcRow) {

        var conntestantIndex = igcFilesModel.get(igcRow).contestant;
        var contestant = contestantsListModel.get(conntestantIndex);

        igcFilesModel.setProperty(igcRow, "startTime", contestant.startTime);
        igcFilesModel.setProperty(igcRow, "category", conntestantIndex === 0 ? "" : contestant.category);
        igcFilesModel.setProperty(igcRow, "speed", parseInt(contestant.speed));
        igcFilesModel.setProperty(igcRow, "classify", conntestantIndex === 0 ? -1 : contestant.prevResultsClassify);
        igcFilesModel.setProperty(igcRow, "aircraftRegistration", contestant.aircraft_registration);
    }

    // Compare results current and prev results property
    function resultsExist(currentSpeed, currentStartTime, currentCategory, currentIgcFileName, currentTrackHash,
                          prevSpeed, prevStartTime, prevCategory, prevIgcFileName, prevTrackHash) {

        return (currentStartTime === prevStartTime &&
                parseInt(currentSpeed) === parseInt(prevSpeed) &&
                currentCategory === prevCategory &&
                currentIgcFileName === prevIgcFileName &&
                currentTrackHash === prevTrackHash);

    }

    // Sort igc file list model by start time
    function sortIgcFilesModelByStartTime() {

        for (var i = 0; i < igcFilesModel.count - 1; i++) {
            for (var j = 0; j < igcFilesModel.count - i - 1; j++) {

                var item_j = igcFilesModel.get(j)
                var item_j1 = igcFilesModel.get(j + 1)

                var item_j_timeVal = item_j.startTime === "" || item_j.startTime === "00:00:00" ? F.timeToUnix("23:59:59") + 1 : F.timeToUnix(item_j.startTime);
                var item_j1_timeVal = item_j1.startTime === "" || item_j1.startTime === "00:00:00" ? F.timeToUnix("23:59:59") + 1 : F.timeToUnix(item_j1.startTime);

                if(item_j_timeVal > item_j1_timeVal){

                    igcFilesModel.move(j, j + 1, 1);
                }
            }
        }
    }

    // Load contestants from CSV
    function loadContestants(filename) {

        var resultsCSV = [];
        var resCSV = [];
        var index = -1;

        // try to load manual data
        if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.csvResultsFile))) {
            var cnt = file_reader.read(Qt.resolvedUrl(pathConfiguration.csvResultsFile));

            // parse CSV, fast cpp variant or slow JS
            if (String(cnt).indexOf(cppWorker.csv_join_parse_delimeter_property) == -1) {

                resCSV = cppWorker.parseCSV(String(cnt));
                for (var i = 0; i < resCSV.length; i++) {

                    var resItem = resCSV[i];
                    resultsCSV.push(resItem.split(cppWorker.csv_join_parse_delimeter_property))
                }
            }
            else {
                console.log("have to use slow variant of CSV parser for results \n")
                resultsCSV = CSVJS.parseCSV(String(cnt))
            }
        }

        // save current contestant values
        var currentConteIds = [];
        var currentConteSpeed = [];
        var currentConteStartTimes = [];
        var currentConteCategories = [];
        var tmp;

        for (var i = 0; i < contestantsListModel.count; i++) {

            tmp = contestantsListModel.get(i);

            // dont push newly created crew without pilot id
            if (!isNaN(parseInt(tmp.pilot_id))) {

                currentConteIds.push(tmp.pilot_id)
                currentConteCategories.push(tmp.category)
                currentConteStartTimes.push(tmp.startTime)
                currentConteSpeed.push(tmp.speed)
            }
        }

        var f_data = file_reader.read(filename);
        var data = [];

        // parse CSV, fast cpp variant or slow JS
        if (String(f_data).indexOf(cppWorker.csv_join_parse_delimeter_property) == -1) {

            resCSV = cppWorker.parseCSV(String(f_data));
            for (var i = 0; i < resCSV.length; i++) {

                var resItem = resCSV[i];
                data.push(resItem.split(cppWorker.csv_join_parse_delimeter_property))
            }
        }
        else {
            console.log("have to use slow variant of CSV parser for contestant \n")
            data = CSVJS.parseCSV(Stringf_data)
        }


        contestantsListModel.clear()

        for (var i = 0; i < data.length; i++) {

            var item = data[i];
            var itemName = item[0]
            var j;

            // CSV soubor ma alespon 3 Sloupce
            if ((item.length > 2) && (itemName.length > 0)) {


                // Find contestant by id in prev results
                for (j = 0; j < resultsCSV.length; j++) {

                    index = resultsCSV[j].indexOf(item[9]);
                    if (index !== -1) // founded
                        break;
                }

                // check previous results validity
                var csvFileFromOffice = false;
                var csvFileFromViewer = false;
                if (index !== -1 ) {

                    // check CSV file status
                    csvFileFromOffice = resultsCSV[j] !== undefined && resultsCSV[j].length >= 30; // CSV from office has only 30 columns
                    csvFileFromViewer = resultsCSV[j] !== undefined && resultsCSV[j].length >= 48; // CSV from viewer has more then 48 columns
                }

                // load current values for this contestant
                var currentContValuesIndex = currentConteIds.indexOf(item[9])

                // check current and new speed, category and start time values, add contestant into import list model id they are different
                if (currentContValuesIndex !== -1) {

                    var currentSpeed = parseInt(currentConteSpeed[currentContValuesIndex]);
                    var currentCategory = currentConteCategories[currentContValuesIndex];
                    var currentStartTime = currentConteStartTimes[currentContValuesIndex];
                    var newSpeed = parseInt(item[5]);
                    var newCategory = item[1];
                    var newStarTime = item[3];

                    // add to list of contestants to the post processing
                    if (currentSpeed != newSpeed || currentCategory != newCategory || currentStartTime != newStarTime) {

                        importDataDialog.listModel.append({
                                                              "row": importDataDialog.listModel.count,
                                                              "name": itemName,
                                                              "speed": newSpeed,
                                                              "startTime": newStarTime,
                                                              "category": newCategory,
                                                              "prevResultsSpeed": currentSpeed,
                                                              "prevResultsStartTime": currentStartTime,
                                                              "prevResultsCategory": currentCategory,
                                                              "speedSelector": 1,
                                                              "categorySelector": 1,
                                                              "startTimeSelector": 1,

                                                          })
                    }
                }

                contestantsListModel.append({
                                                "name": itemName,
                                                "category": item[1],
                                                "fullName": item[2],
                                                "startTime": item[3],
                                                "filename": (csvFileFromViewer && item[4] === "" ? resultsCSV[j][38] : item[4]),
                                                "speed": parseInt(item[5]),
                                                "currentCategory": (currentContValuesIndex === -1 ? "" : currentConteCategories[currentContValuesIndex]),
                                                "currentStartTime": (currentContValuesIndex === -1 ? "" : currentConteStartTimes[currentContValuesIndex]),
                                                "currentSpeed": (currentContValuesIndex === -1 ? -1 : currentConteSpeed[currentContValuesIndex]),
                                                "aircraft_type": item[6],
                                                "aircraft_registration": item[7],
                                                "crew_id": item[8],
                                                "pilot_id": item[9],
                                                "copilot_id": item[10],
                                                "pilotAvatarBase64" : (item.length >= 13 ? (item[11]) : ""),
                                                "copilotAvatarBase64" : (item.length >= 13 ? (item[12]) : ""),
                                                "markersOk": (csvFileFromOffice ? parseInt(resultsCSV[j][1]) : 0),
                                                "markersNok": (csvFileFromOffice ? parseInt(resultsCSV[j][2]) : 0),
                                                "markersFalse": (csvFileFromOffice ? parseInt(resultsCSV[j][3]) : 0),
                                                "markersScore": (csvFileFromViewer ? parseInt(resultsCSV[j][41]) : 0),
                                                "photosOk": (csvFileFromOffice ? parseInt(resultsCSV[j][4]) : 0),
                                                "photosNok": (csvFileFromOffice ? parseInt(resultsCSV[j][5]) : 0),
                                                "photosFalse": (csvFileFromOffice ? parseInt(resultsCSV[j][6]) : 0),
                                                "photosScore": (csvFileFromViewer ? parseInt(resultsCSV[j][42]) : 0),
                                                "startTimeMeasured": (csvFileFromOffice ? resultsCSV[j][11] : ""),
                                                "startTimeDifference": (csvFileFromOffice ? resultsCSV[j][43] : ""),
                                                "startTimeScore": (csvFileFromOffice ? parseInt(resultsCSV[j][12]) * -1 : 0),
                                                "landingScore": (csvFileFromOffice ? parseInt(resultsCSV[j][7]) : 0),

                                                "circlingCount": (csvFileFromViewer ? parseInt(resultsCSV[j][44]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][13]))),
                                                "circlingScore": (csvFileFromViewer ? parseInt(resultsCSV[j][45]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][14] * -1))),
                                                "oppositeCount": (csvFileFromViewer ? parseInt(resultsCSV[j][46]) : 0),
                                                "oppositeScore": (csvFileFromViewer ? parseInt(resultsCSV[j][47]) : 0),

                                                "otherPoints": (csvFileFromOffice ? parseInt(resultsCSV[j][8]) : 0),
                                                "otherPointsNote": (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[0]) : ""),
                                                "otherPenalty": (csvFileFromOffice ? parseInt(resultsCSV[j][15]) : 0),
                                                "otherPenaltyNote": (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[1]) : ""),
                                                "prevResultsSpeed": (csvFileFromViewer ? parseInt(resultsCSV[j][31]) : -1),
                                                "prevResultsStartTime": (csvFileFromViewer ? resultsCSV[j][32] : ""),
                                                "prevResultsCategory": (csvFileFromViewer ? resultsCSV[j][33] : ""),
                                                "prevResultsWPT": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][34]) : ""),
                                                "prevResultsSpeedSec": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][35]) : ""),
                                                "prevResultsAltSec": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][37]) : ""),
                                                "prevResultsSpaceSec": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][36]) : ""),
                                                "prevResultsTrackHas": (csvFileFromViewer ? resultsCSV[j][30] : ""),
                                                "prevResultsFileName": (csvFileFromViewer ? resultsCSV[j][38] : ""),
                                                "prevResultsScorePoints": (csvFileFromOffice ? parseInt(resultsCSV[j][17]) : -1),
                                                "prevResultsScore": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][39]) : ""),
                                                "prevResultsScoreJson": (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][40]) : ""),
                                                "prevResultsClassify": (csvFileFromOffice ? (resultsCSV[j][19] === "yes" ? 0 : 1) : 0),
                                            })
            }
        }
    }

    // remove invalid results from loaded contestant
    function checkAndRemoveContestantsInvalidPrevResults() {

        for (var i = 0; i < contestantsListModel.count; i++) {

            var curCnt = contestantsListModel.get(i);

            // there is some prev result
            if (curCnt.prevResultsScoreJson !== "") {

                // load contestant category
                for (var t = 0; t < tracks.tracks.length; t++) {

                    if (tracks.tracks[t].name === curCnt.category)
                        trItem = tracks.tracks[t]
                }

                // remove invalid results
                if (!resultsExist(curCnt.speed, curCnt.startTime, curCnt.category, curCnt.filename, MD5.MD5(JSON.stringify(trItem)),
                                  curCnt.prevResultsSpeed, curCnt.prevResultsStartTime, curCnt.prevResultsCategory, curCnt.prevResultsFileName, curCnt.prevResultsTrackHas)) {

                    contestantsListModel.setProperty(i, "markersScore", 0);
                    contestantsListModel.setProperty(i, "photosScore", 0);
                    contestantsListModel.setProperty(i, "circlingScore", 0);
                    contestantsListModel.setProperty(i, "oppositeScore", 0);
                    contestantsListModel.setProperty(i, "startTimeScore", 0);
                    contestantsListModel.setProperty(i, "prevResultsSpeed", -1);
                    contestantsListModel.setProperty(i, "prevResultsStartTime", "");
                    contestantsListModel.setProperty(i, "prevResultsCategory", "");
                    contestantsListModel.setProperty(i, "prevResultsTrackHas", "");
                    contestantsListModel.setProperty(i, "prevResultsFileName", "");
                    contestantsListModel.setProperty(i, "prevResultsScore", "");
                    contestantsListModel.setProperty(i, "prevResultsScoreJson", "");
                    contestantsListModel.setProperty(i, "prevResultsScorePoints", -1);
                }
            }
        }
    }

    // generate results for each category
    function generateContinuousResults() {

        var res = getContinuousResults();
        var csvString = "";
        var resultsFileName = "res";

        var recSize = 8;

        var reStringArr = [];
        for (var key in res) {
            reStringArr.push(JSON.stringify(res[key]));
        }

        // HTML
        results_creator.createContinuousResultsHTML(pathConfiguration.resultsFolder + "/" + competitionConfiguretion.competitionName + "_" + resultsFileName,
                                                    reStringArr,
                                                    recSize,
                                                    competitionConfiguretion.competitionName,
                                                    competitionConfiguretion.getCompetitionTypeString(competitionConfiguretion.competitionType),
                                                    competitionConfiguretion.competitionDirector,
                                                    competitionConfiguretion.competitionDirectorAvatar,
                                                    competitionConfiguretion.competitionArbitr,
                                                    competitionConfiguretion.competitionArbitrAvatar,
                                                    competitionConfiguretion.competitionDate);


        // CSV
        var catArray = [];
        var item;
        for(var key in res) {

            catArray = res[key];

            // no results, just category labels, skip
            if (!Array.isArray(catArray))
                continue;

            // save each contestant
            for (var i = 0; i < catArray.length; i++) {

                item = catArray[i];

                csvString += "\"" + i + "\";"

                for(var j = 0; j < item.length; j++) {

                    csvString += "\"" + F.addSlashes(item[j]) + "\";"
                }
                csvString += "\n";

            }
            csvString += "\n";
        }

        file_reader.write(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + competitionConfiguretion.competitionName + "_" + resultsFileName + ".csv"), csvString);
    }


    // DEBUG func
    function listProperty(item)
    {
        for (var p in item)
            console.log(p + ": " + item[p]);
    }

    function getAltitudeAndSpaceSectionsPenaltyPoints(igcRow, totalPoints) {

        var igcItem = igcFilesModel.get(igcRow);
        var item;
        var i;
        var arr = [];

        // altitude
        if (igcItem.altitudeSectionsScoreDetails !== "") {

            altSectionsScoreListManualValuesCache.clear();
            arr = igcItem.altitudeSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                altSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            arr = [];

            for (i = 0; i < altSectionsScoreListManualValuesCache.count; i++) {
                item = altSectionsScoreListManualValuesCache.get(i)
                item.altSecScore = getAltSecScore(item.manualAltMinEntriesCount, item.altMinEntriesCount, item.manualAltMaxEntriesCount, item.altMaxEntriesCount, item.penaltyPercent, totalPoints);

                arr.push(JSON.stringify(item));
            }

            igcFilesModel.setProperty(igcRow, "altitudeSectionsScoreDetails", arr.join("; "));
            altSectionsScoreListManualValuesCache.clear();
        }

        // space
        if (igcItem.spaceSectionsScoreDetails !== "") {

            spaceSectionsScoreListManualValuesCache.clear();
            arr = igcItem.spaceSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                spaceSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            arr = [];

            for (i = 0; i < spaceSectionsScoreListManualValuesCache.count; i++) {
                item = spaceSectionsScoreListManualValuesCache.get(i)
                item.spaceSecScore = getSpaceSecScore(item.manualEntries_out, item.entries_out, item.penaltyPercent, totalPoints);

                arr.push(JSON.stringify(item));
            }

            igcFilesModel.setProperty(igcRow, "spaceSectionsScoreDetails", arr.join("; "));
            spaceSectionsScoreListManualValuesCache.clear();
        }
    }

    // get points sum from sections and gates
    function getScorePointsSum(contestant, wptScoreListStrin, speedSecString) {

        var sum = 0;
        var p;
        var modelItem;

        // get score points from gates
        if (wptScoreListStrin !== "") {

            wptNewScoreListManualValuesCache.clear();
            var arr = wptScoreListStrin.split("; ")

            for (var i = 0; i < arr.length; i++) {
                wptNewScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (p = 0; p < wptNewScoreListManualValuesCache.count; p++) {
                modelItem = wptNewScoreListManualValuesCache.get(p);
                sum += Math.max(modelItem.sg_score, 0) +
                        Math.max(modelItem.tp_score, 0) +
                        Math.max(modelItem.tg_score, 0) +
                        (modelItem.alt_score === -1 ? 0 : modelItem.alt_score);

            }
        }

        // get score points from speed sec
        if (speedSecString !== "") {

            speedSectionsScoreListManualValuesCache.clear();
            arr = speedSecString.split("; ")
            for (var i = 0; i < arr.length; i++) {
                speedSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (p = 0; p < speedSectionsScoreListManualValuesCache.count; p++) {
                sum += Math.max(speedSectionsScoreListManualValuesCache.get(p).speedSecScore, 0);
            }
        }

        sum += contestant.markersScore +
                contestant.photosScore +
                contestant.landingScore +
                contestant.otherPoints -
                contestant.otherPenalty;

        wptNewScoreListManualValuesCache.clear();
        speedSectionsScoreListManualValuesCache.clear();

        return sum;

    }

    // get total score points fur contestant and current igc item
    function getTotalScore(contestant, igcRow) {

        var igcItem = igcFilesModel.get(igcRow);

        // get score points sum
        var scorePoints = getScorePointsSum(contestant, igcItem.wptScoreDetails, igcItem.speedSectionsScoreDetails);

        // get penalty percent points
        var penaltyPercentPointsSum = contestant.startTimeScore +
                contestant.circlingScore +
                contestant.oppositeScore;

        // get penalty percent points from sections
        var penaltySumSections = 0;
        var arr = [];
        var i;
        var item;

        // alt sec
        if (igcItem.altitudeSectionsScoreDetails !== "") {

            altSectionsScoreListManualValuesCache.clear();
            arr = igcItem.altitudeSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                altSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (i = 0; i < altSectionsScoreListManualValuesCache.count; i++) {
                item = altSectionsScoreListManualValuesCache.get(i)
                penaltySumSections += item.altSecScore;
            }
            altSectionsScoreListManualValuesCache.clear();
        }

        // space sec
        if (igcItem.spaceSectionsScoreDetails !== "") {

            spaceSectionsScoreListManualValuesCache.clear();
            arr = igcItem.spaceSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                spaceSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (i = 0; i < spaceSectionsScoreListManualValuesCache.count; i++) {
                item = spaceSectionsScoreListManualValuesCache.get(i)
                penaltySumSections += item.spaceSecScore;
            }
            spaceSectionsScoreListManualValuesCache.clear();
        }

        return Math.max((scorePoints + penaltyPercentPointsSum + penaltySumSections), 0);
    }

    // recalculate score points for manual values - markers, photos, indirection flight,...
    function recalculateContestnatManualScoreValues(igcRow) {

        var igcItem = igcFilesModel.get(igcRow)
        var ctIndex = igcItem.contestant
        ctnt = contestantsListModel.get(ctIndex);

        //calc contestant manual values score - markers, photos,..
        ctnt.markersScore = getMarkersScore(ctnt.markersOk, ctnt.markersNok, ctnt.markersFalse, trItem.marker_max_score);
        ctnt.photosScore = getPhotosScore(ctnt.photosOk, ctnt.photosNok, ctnt.photosFalse, trItem.photos_max_score);

        var totalPointsScore = getScorePointsSum(ctnt, igcItem.wptScoreDetails, igcItem.speedSectionsScoreDetails);

        ctnt.startTimeScore = getTakeOffScore(ctnt.startTimeDifference, trItem.time_window_size, trItem.time_window_penalty, totalPointsScore);
        ctnt.circlingScore = getGyreScore(ctnt.circlingCount, trItem.gyre_penalty, totalPointsScore);
        ctnt.oppositeScore = getOppositeDirScore(ctnt.oppositeCount, trItem.oposite_direction_penalty, totalPointsScore);

        getAltitudeAndSpaceSectionsPenaltyPoints(igcRow, totalPointsScore);

        // save changes into contestnat list model
        contestantsListModel.setProperty(ctIndex, "markersScore", ctnt.markersScore);
        contestantsListModel.setProperty(ctIndex, "photosScore", ctnt.photosScore);
        contestantsListModel.setProperty(ctIndex, "startTimeScore", ctnt.startTimeScore);
        contestantsListModel.setProperty(ctIndex, "circlingScore", ctnt.circlingScore);
        contestantsListModel.setProperty(ctIndex, "oppositeScore", ctnt.oppositeScore);

    }

    // recalculate score points to 1000
    function recalculateScoresTo1000() {

        var i, item;

        maxPointsArr = {
            "R-AL1": 1,
            "R-AL2": 1,
            "S-AL1": 1,
            "S-AL2": 1,
            "R-WL1": 1,
            "R-WL2": 1,
            "S-WL1": 1,
            "S-WL2": 1,
            "CUSTOM1": 1,
            "CUSTOM2": 1,
            "CUSTOM3": 1,
            "CUSTOM4": 1
        };

        for (i = 0; i < igcFilesModel.count; i++) {
            item = igcFilesModel.get(i)

            if (maxPointsArr[item.category] < item.scorePoints && !item.classify) {
                maxPointsArr[item.category] = item.scorePoints;
            }

        }

        for (i = 0; i < igcFilesModel.count; i++) {
            item = igcFilesModel.get(i)

            // classify set as NO
            if (item.classify) {
                igcFilesModel.setProperty(i, "scorePoints1000", -1);
                continue;
            }

            if (item.scorePoints >= 0) {
                igcFilesModel.setProperty(i, "scorePoints1000", Math.round(item.scorePoints/maxPointsArr[item.category] * 1000));
            }
        }

        // recalculate contestant order
        recalculateContestantsScoreOrder();
    }

    function initScorePointsArrray () {

        categoriesScorePoints = {
            "R-AL1": [],
            "S-AL1": [],
            "R-AL2": [],
            "S-AL2": [],
            "R-WL1": [],
            "S-WL1": [],
            "R-WL2": [],
            "S-WL2": [],
            "CUSTOM1": [],
            "CUSTOM2": [],
            "CUSTOM3": [],
            "CUSTOM4": []
        }
    }

    function recalculateContestantsScoreOrder () {
        return; // FIXME

        var item;
        var i;

        // clear score array
        initScorePointsArrray();

        // push score points
        for (i = 0; i < igcFilesModel.count; i++) {
            item = igcFilesModel.get(i);

            if (item.scorePoints1000 >= 0)
                pushIfNotExistScorePoints(item.category, item.scorePoints1000);
        }

        // sort arrays
        for (var key in categoriesScorePoints) {
            categoriesScorePoints[key].sort(function(a,b) { return b - a; });
        }

        // get order
        for (i = 0; i < igcFilesModel.count; i++) {
            item = igcFilesModel.get(i);

            if (item.scorePoints1000 >= 0) {

                item.classOrder = categoriesScorePoints[item.category].indexOf(item.scorePoints1000) + 1;
            }
            else {
                item.classOrder = -1;
            }
        }
    }

    // function push score points value into class array of not exist
    function pushIfNotExistScorePoints (category, score) {

        if (categoriesScorePoints[category].indexOf(score) === -1)
            categoriesScorePoints[category].push(parseInt(score));
    }

    // function calculate score points for one gate
    function calcPointScore(scoreData) {


        var flags = scoreData["type"];

        var sg_manual = scoreData["sg_hit_manual"];
        var category_sg_max_score = scoreData["sg_category_max_score"];
        var sg_hit_measured = scoreData["sg_hit_measured"];
        var tp_manual = scoreData["tp_hit_manual"];
        var category_tp_max_score = scoreData["tp_category_max_score"];
        var tp_hit_measured = scoreData["tp_hit_measured"];
        var tg_time_difference = scoreData["tg_time_difference"];
        var category_tg_penalty = scoreData["tg_category_penalty"];
        var category_tg_tolerance = scoreData["tg_category_time_tolerance"];
        var category_tg_max_score = scoreData["tg_category_max_score"];
        var point_alt_max = scoreData["alt_max"];
        var point_alt_min = scoreData["alt_min"];
        var alt_manual = scoreData["alt_manual"];
        var category_alt_penalty = scoreData["category_alt_penalty"];
        var alt_measured = scoreData["alt_measured"];

        var tg_score = (flags & (0x1 << 1) ? getTGScore(tg_time_difference, category_tg_max_score, category_tg_penalty, category_tg_tolerance) : -1);
        var tp_score = (flags & (0x1 << 0)) ? getTPScore(tp_manual, tp_hit_measured, category_tp_max_score)  : -1;
        var sg_score = (flags & (0x1 << 2)) ? getSGScore(sg_manual, sg_hit_measured, category_sg_max_score)  : -1;
        var alt_score = getAltScore(alt_manual, alt_measured, point_alt_min, point_alt_max, flags, category_alt_penalty);

        scoreData["tg_score"] = tg_score;
        scoreData["tp_score"] = tp_score;
        scoreData["sg_score"] = sg_score;
        scoreData["alt_score"] = alt_score;

        return scoreData;
    }

    function getMinAltScore(altManual, altAuto, altMin, altPenalty) {

        return (altManual < 0 ? ((altAuto < altMin) ? ((altMin - altAuto) *  altPenalty ) * -1: 0) : ((altManual < altMin) ? (altMin - altManual) *  altPenalty * -1 : 0));
    }

    function getMaxAltScore(altManual, altAuto, altMax, altPenalty) {

        return (altManual < 0 ? ((altAuto > altMax) ? (altAuto - altMax) *  altPenalty * -1: 0) : ((altManual > altMax) ? (altManual - altMax) *  altPenalty * -1: 0));
    }


    function getAltScore(altManual, altAuto, altMin, altMax, flags, altPenalty) {

        if (altManual < 0 && altAuto < 0)
            return -1;

        return parseInt(
                    (flags & (0x1 << 3)) && (flags & (0x1 << 4)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) + getMaxAltScore(altManual, altAuto, altMax, altPenalty) : (
                                                                       (flags & (0x1 << 3)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) : (
                                                                                                  (flags & (0x1 << 4)) ? getMaxAltScore(altManual, altAuto, altMax, altPenalty) :
                                                                                                                         -1)))
    }

    function getSGScore(sgManualVal, sgHitAuto, sgMaxScore) {

        return parseInt(sgManualVal < 0 ? sgHitAuto * sgMaxScore : sgManualVal * sgMaxScore);
    }

    function getTPScore(tpManualVal, tpHitAuto, tpMaxScore) {

        return parseInt(tpManualVal < 0 ? (tpHitAuto * tpMaxScore) : (tpManualVal * tpMaxScore));
    }

    function getTGScore(tgTimeDifference, tgMaxScore, tgPenalty, tgTolerance) {

        return parseInt((tgTimeDifference > tgTolerance) ? Math.max(tgMaxScore - (tgTimeDifference - tgTolerance) * tgPenalty, 0) : tgMaxScore);
    }

    function getSpeedSectionScore(speedDiff, speedTolerance, speedMaxScore, speedPenalty) {

        return parseInt(Math.max(speedDiff > speedTolerance ? (speedMaxScore - (speedDiff - speedTolerance) * speedPenalty) : speedMaxScore, 0));
    }

    function getMarkersScore(markersOk, markersNok, markersFalse, marker_max_score) {

        return markersOk * marker_max_score - (markersNok + markersFalse) * marker_max_score;
    }

    function getPhotosScore(photosOk, photosNok, photosFalse, photos_max_score) {

        return photosOk * photos_max_score - (photosNok + photosFalse) * photos_max_score;
    }

    function getTakeOffScore(startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore) {

        if (F.timeToUnix(startTimeDifferenceText) > time_window_size)
            return Math.round(totalPointsScore/100 * time_window_penalty) * -1;
        else
            return 0;
    }

    function getGyreScore(circlingCountValue, gyre_penalty, totalPointsScore) {

        return Math.round(totalPointsScore/100 * gyre_penalty * circlingCountValue) * -1;
    }

    function getOppositeDirScore(oppositeCountValue, oposite_direction_penalty, totalPointsScore) {

        return Math.round(totalPointsScore/100 * oposite_direction_penalty * oppositeCountValue) * -1;
    }

    function getAltSecScore(manualAltMinEntriesCount, altMinEntriesCount, manualAltMaxEntriesCount, altMaxEntriesCount, altPenaltyPercent, totalPointsScore) {

        var minCount = manualAltMinEntriesCount < 0 ? altMinEntriesCount : manualAltMinEntriesCount;
        var maxCount = manualAltMaxEntriesCount < 0 ? altMaxEntriesCount : manualAltMaxEntriesCount;

        return Math.round(((minCount + maxCount) * altPenaltyPercent * totalPointsScore/100) * -1);
    }

    function getSpaceSecScore(manualEntries_out, entries_out, spacePenaltyPercent, totalPointsScore) {

        return Math.round(((manualEntries_out < 0 ? entries_out : manualEntries_out) * spacePenaltyPercent * totalPointsScore/100) * -1);
    }

    function returnListModelIndexByContent(listModel, refRole1, refRoleVal1, refRole2, refRoleVal2) {

        var index = -1;
        var item;

        for (var i = 0; i < listModel.count; i++) {
            item = listModel.get(i);

            if (item[refRole1] == refRoleVal1 && item[refRole2] == refRoleVal2) {

                index = i;
                break;
            }
        }

        return index;
    }

    // function return value from list model if exist, otherwise return implicit value
    function returnManualValueFromListModelIfExist(listModel, retRole, retImplicitVal, refRole, refVal) {

        var item;

        for (var i = 0; i < listModel.count; i++) {
            item = listModel.get(i);

            if (item[refRole] == refVal) {
                return item[retRole];
            }
        }

        // not found, return implicit val
        return retImplicitVal;
    }

    // function load string into list model
    function loadStringIntoListModel(dstListModel, srcString, srcStringDelimeter) {

        dstListModel.clear();

        if (srcString === "") return;

        var arr = srcString.split(srcStringDelimeter)
        for (var i = 0; i < arr.length; i++) {
            dstListModel.append(JSON.parse(arr[i]))
        }
    }

    // function return index od string for category combobox
    function getClassIndex(compClass) {

        if (compClass === "" || compClass === undefined)
            return 0;

        var index = 1;

        for (; index < competitionClassModel.count; index++) {

            if (compClass === competitionClassModel.get(index).text)
                break;
        }

        return index;
    }


    function computeScore(tpiData, polys) {

        console.log("computing score")

        var current = -1;

        contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

        if (current < 0) {
            console.log("computeScore, but currentRow == " + contestantsTable.currentRow)
            return;
        }

        var item = igcFilesModel.get(current)

        // FIXME
        return;


        if ((item.score !== undefined) && (item.score !== "")) { // pokud je vypocitane, tak nepocitame znovu


            scoreTable.currentRow = -1;
            scoreTable.selection.clear();
            wptScoreList.clear()

            var cacheArr = JSON.parse(item.score_json);

            for (var i = 0; i < cacheArr.length; i++) {
                var cacheItem = cacheArr[i];

                wptScoreList.append(cacheItem)
            }

            return;
        }


        if (tpiData.length > 0) {
            printMapWindow.makeImage();
        }


        // load manual values into list models - used when compute score
        loadStringIntoListModel(wptNewScoreListManualValuesCache, ctnt.prevResultsWPT, "; ");
        loadStringIntoListModel(speedSectionsScoreListManualValuesCache, ctnt.prevResultsSpeedSec, "; ");
        loadStringIntoListModel(spaceSectionsScoreListManualValuesCache, ctnt.prevResultsSpaceSec, "; ");
        loadStringIntoListModel(altSectionsScoreListManualValuesCache, ctnt.prevResultsAltSec, "; ");


        console.time("computeScore")


        var igcthis, igcnext, i, j, k;
        var section;

        var section_speed_start_tid = -1;
        var section_alt_start_tid = -1;
        var section_space_start_tid = -1;
        var section_alt_threshold_max = -1;
        var section_alt_threshold_min = -1;
        var section_space_threshold = -1;
        var section_space_alt_threshold_max = -1;
        var section_space_alt_threshold_min = -1;

        var section_speed_array = [];
        var section_alt_array = [];
        var section_space_array = [];

        var distance_cumul = 0;
        var sectorCache =  map.sectorCache;


        for (j = 0; j < tpiData.length; j++) {
            var ti = tpiData[j]
            var startPointName;

            var flags = ti.flags;
            var section_speed_start = F.getFlagsByIndex(7, flags)
            var section_speed_end   = F.getFlagsByIndex(8, flags)
            var section_alt_start   = F.getFlagsByIndex(9, flags)
            var section_alt_end     = F.getFlagsByIndex(10, flags)
            var section_space_start = F.getFlagsByIndex(11, flags)
            var section_space_end   = F.getFlagsByIndex(12, flags)

            distance_cumul += ti.distance;

            if (section_speed_end && (section_speed_start_tid >= 0)) {
                var item = {
                    "start": section_speed_start_tid,
                    "end": ti.tid,
                    "distance": distance_cumul,
                    "time_start": 0,
                    "time_end": 0,
                    "speed": 0,
                    "startName": startPointName,
                    "endName": ti.name
                }

                section_speed_array.push(item);
                section_speed_start_tid = -1;
            }

            if (section_alt_end && (section_alt_start_tid >= 0)) {
                var item = {
                    "start": section_alt_start_tid,
                    "end": ti.tid,
                    "measure" : false,
                    "threshold_max": section_alt_threshold_max,
                    "threshold_min": section_alt_threshold_min,
                    "alt_max": F.alt_max_init,
                    "alt_max_time" : "00:00:00",
                    "alt_min": F.alt_min_init,
                    "alt_min_time" : "00:00:00",
                    "alt_cumul": 0,
                    "alt_count": 0,
                    "entries_below": 0,
                    "entries_above": 0,
                    "time_spent_below": 0,
                    "time_spent_above": 0,
                    "alt_is_above": false,
                    "alt_is_below": false,
                    "startName": startPointName,
                    "endName": ti.name

                    // defaults
                }
                section_alt_array.push(item);
                section_alt_start_tid = -1;
            }

            if (section_space_end && (section_space_start_tid >= 0)) {
                var item = {
                    "start": section_space_start_tid,
                    "end": ti.tid,
                    "measure" : false,
                    "distance": 0,
                    "distance_time": "00:00:00",
                    "entries_out": 0,
                    "entries_out_bi": 0,
                    "time_spent_out": 0,
                    "time_spent_out_bi": 0,
                    "is_out": false,
                    "is_out_alt_min": false,
                    "is_out_alt_max": false,
                    "is_out_bi": false,
                    "threshold": section_space_threshold,
                    "alt_max_threshold": section_space_alt_threshold_max,
                    "alt_min_threshold": section_space_alt_threshold_min,
                    "startName": startPointName,
                    "endName": ti.name
                }
                section_space_array.push(item);
                section_space_start_tid = -1;
            }

            if (section_speed_start) {
                section_speed_start_tid = ti.tid;
                distance_cumul = 0;
                startPointName = ti.name;
            }
            if (section_alt_start) {
                section_alt_start_tid = ti.tid;
                section_alt_threshold_max = ti.alt_max;
                section_alt_threshold_min = ti.alt_min;
                startPointName = ti.name;
            }
            if (section_space_start) {
                section_space_start_tid = ti.tid;
                section_space_threshold = ti.radius;
                section_space_alt_threshold_max = ti.alt_max;
                section_space_alt_threshold_min = ti.alt_min;
                startPointName = ti.name;
            }

        }

        var poly_alt_min = 1000000;
        var poly_alt_max = -1000000;
        var poly_results = [];
        for (j = 0; j < polys.length; j++) {
            var poly = polys[j];
            var poly_result = {
                "time_start": "00:00:00",
                "time_end": "00:00:00",
                "count": 0,
                "alt_min": poly_alt_min,
                "alt_max": poly_alt_max,
            }
            poly_results.push(poly_result);
        }

        var section_speed_array_length = section_speed_array.length
        var section_alt_array_length = section_alt_array.length
        var section_space_array_length = section_space_array.length

        var intersections = 0;

        if (igc.count > 0) {
            igcnext = igc.get(0);
            for (i = 1; i < igc.count; i++) {
                igcthis = igcnext
                igcnext = igc.get(i);


                for (j = 0; j < tpiData.length; j++) {
                    var ti = tpiData[j]


                    var distance = F.getDistanceTo(ti.lat, ti.lon, igcnext.lat, igcnext.lon);
                    if (distance > (ti.radius + 500)) {
                        continue;
                    }

                    if ((distance <= ti.radius) && (!ti.hit)) {
                        tpiData[j].hit = true;
                    }


                    var gate_inter = F.lineIntersection(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon), ti.gateALat, ti.gateALon, ti.gateBLat, ti.gateBLon);

                    if (gate_inter) {

                        var angle_low = ti.angle + 180;
                        var angle_high = angle_low + 180;
                        var flight_angle = F.getBearingTo(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon))
                        var flight_angle2 = flight_angle + 360;

                        var angle_ok = (((angle_low < flight_angle) && (flight_angle < angle_high)) || ((angle_low < flight_angle2) && (flight_angle2 < angle_high)))


                        if (angle_ok) {
                            tpiData[j].time = igcthis.time
                            tpiData[j].sg_hit = true
                            tpiData[j].alt = parseFloat(igcthis.alt)

                            for (k = 0; k < section_speed_array_length; k++) {
                                section = section_speed_array[k]
                                if (section.start === ti.tid) {
                                    section_speed_array[k].time_start = F.timeToUnix(igcthis.time);
                                }
                                if (section.end === ti.tid) {
                                    var timeStart = section_speed_array[k].time_start;
                                    var timeEnd = F.timeToUnix(igcthis.time);
                                    var timeDiff = Math.abs(timeEnd - timeStart);
                                    var distance = section_speed_array[k].distance;
                                    var speed = distance / timeDiff;
                                    section_speed_array[k].speed = Math.floor(speed * 3.6); // m/s to km/h
                                }
                            }

                            for (k = 0; k < section_alt_array_length; k++) {
                                section = section_alt_array[k]
                                if (section.start === ti.tid) {
                                    section_alt_array[k].measure = true;
                                }
                            }
                            for (k = 0; k < section_space_array_length; k++) {
                                section = section_space_array[k]
                                if (section.start === ti.tid) {
                                    section_space_array[k].measure = true;
                                }
                            }

                        } else {
                            console.log("wrong direction on "+ti.name  +":  B1 < A < B2: " + angle_ok + " " + Math.round(angle_low) + " " + Math.round(flight_angle) + "(+360) " + Math.round(angle_high))
                        }

                    }
                }

                for (j = 0; j < section_alt_array_length; j++) {
                    section = section_alt_array[j]
                    if (section.measure) {
                        if (parseFloat(igcthis.alt) > section.alt_max) {
                            section_alt_array[j].alt_max = parseFloat(igcthis.alt);
                            section_alt_array[j].alt_max_time = igcthis.time;
                        }
                        if (parseFloat(igcthis.alt) < section.alt_min) {
                            section_alt_array[j].alt_min = parseFloat(igcthis.alt);
                            section_alt_array[j].alt_min_time = igcthis.time;
                        }

                        if (parseFloat(igcthis.alt) > section.threshold_max) { // is above
                            section_alt_array[j].time_spent_above = section.time_spent_above + 1;

                            if (!section.alt_is_above) { // entering space above
                                section_alt_array[j].alt_is_above = true;
                                section_alt_array[j].entries_above = section.entries_above + 1;

                            }
                        }

                        if (parseFloat(igcthis.alt) < (section.threshold_max - F.alt_hysteresis)) { // leaving space above
                            section_alt_array[j].alt_is_above = false;
                        }

                        if (parseFloat(igcthis.alt) < section.threshold_min) { // is below
                            section_alt_array[j].time_spent_below = section.time_spent_below + 1;

                            if (!section.alt_is_below) {
                                section_alt_array[j].alt_is_below = true;
                                section_alt_array[j].entries_below = section.entries_below + 1;
                            }
                        }

                        if (parseFloat(igcthis.alt) > (section.threshold_min + F.alt_hysteresis)) { // leaving space below
                            section_alt_array[j].alt_is_below = false;
                        }

                        section_alt_array[j].alt_cumul = parseFloat(igcthis.alt) + section.alt_cumul
                        section_alt_array[j].alt_count = section.alt_count + 1
                    }
                }
                for (j = 0; j < section_space_array_length; j++) {
                    section = section_space_array[j]

                    if (section.measure) {

                        for (var x = 0; x < sectorCache.length; x++) {
                            var sectorData = sectorCache[x];
                            var str = "";
                            if (section.start === sectorData.start) { // measuring only selected section

                                var polygons = sectorData.polygons;
                                var mindistance = F.space_mindistance_init;
                                for (var y = 0; y < polygons.length; y++) {
                                    var polygon = polygons[y];
                                    var prevPoint = polygon[0]
                                    for (var z = 1; z < polygon.length; z++) {
                                        var point = polygon[z];
                                        if ((point.lat == prevPoint.lat)&& (point.lon == prevPoint.lon)) {
                                            continue;
                                        }

                                        var proj = F.projectionPointToLineLatLon(point.lat, point.lon, prevPoint.lat, prevPoint.lon, parseFloat(igcthis.lat), parseFloat(igcthis.lon))
                                        var distance = F.getDistanceTo(proj[0], proj[1], parseFloat(igcthis.lat), parseFloat(igcthis.lon));

                                        mindistance = Math.min(distance, mindistance);
                                        prevPoint = point;
                                    }
                                }
                                if (mindistance > section.distance) {
                                    section_space_array[j].distance = mindistance;
                                    section_space_array[j].distance_time = igcthis.time;
                                }


                                if (mindistance > section.threshold) {
                                    section_space_array[j].time_spent_out = section.time_spent_out + 1
                                    if (!section.is_out) {
                                        section_space_array[j].is_out = true;
                                        section_space_array[j].entries_out = section.entries_out + 1;
                                    }
                                }

                                if ((parseFloat(igcthis.alt) > section.alt_max_threshold) && (!section.is_out_alt_max)) {
                                    section_space_array[j].is_out_alt_max = true;
                                }

                                if ((parseFloat(igcthis.alt) < section.alt_min_threshold) && (!section.is_out_alt_min)) {
                                    section_space_array[j].is_out_alt_min = true;
                                }

                                if ((parseFloat(igcthis.alt) > section.alt_max_threshold) || (parseFloat(igcthis.alt) < section.alt_min_threshold) || (mindistance > section.threshold)) {
                                    section_space_array[j].time_spent_out_bi = section.time_spent_out_bi + 1
                                }

                                if (section_space_array[j].is_out_alt_min || section_space_array[j].is_out_alt_max || section_space_array[j].is_out) {
                                    if (!section.is_out_bi) {
                                        section_space_array[j].is_out_bi = true;
                                        section_space_array[j].entries_out_bi = section.entries_out_bi + 1;
                                    }
                                } else {
                                    section_space_array[j].is_out_bi = false;
                                }

                                if (parseFloat(igcthis.alt) < (section.alt_max_threshold - F.alt_hysteresis)) {
                                    section_space_array[j].is_out_alt_max = false;
                                }
                                if (parseFloat(igcthis.alt) > (section.alt_min_threshold + F.alt_hysteresis)) {
                                    section_space_array[j].is_out_alt_min = false;
                                }

                                if (mindistance < (section.threshold - F.space_hysteresis)) {
                                    section_space_array[j].is_out = false;
                                }



                            }
                        }


                    }
                }

                for (j = 0; j < tpiData.length; j++) {
                    var ti = tpiData[j]
                    var distance = F.getDistanceTo(ti.lat, ti.lon, igcnext.lat, igcnext.lon);
                    if (distance > (ti.radius + 500)) {
                        continue;
                    }
                    var gate_inter = F.lineIntersection(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon), ti.gateALat, ti.gateALon, ti.gateBLat, ti.gateBLon);

                    if (gate_inter) {
                        for (k = 0; k < section_alt_array_length; k++) {
                            section = section_alt_array[k]
                            if (section.end === ti.tid) {
                                section_alt_array[k].measure = false;
                            }
                        }
                        for (k = 0; k < section_space_array_length; k++) {
                            section = section_space_array[k]
                            if (section.end === ti.tid) {
                                section_space_array[k].measure = false;
                            }
                        }

                    }
                }

                for (j = 0; j < polys.length; j++) {
                    var poly = polys[j];
                    var poly_result = poly_results[j];

                    var intersection = F.pointInPolygon(poly.points, igcthis)
                    if (intersection) {
                        intersections++;
                        if (poly_result.count === 0) {
                            poly_result.time_start = igcthis.time;
                        }
                        poly_result.time_end = igcthis.time;
                        poly_result.alt_min = Math.min(poly_result.alt_min, igcthis.alt)
                        poly_result.alt_max = Math.max(poly_result.alt_max, igcthis.alt)
                        poly_result.count = poly_result.count + 1;
                        poly_results[j] = poly_result;
                    }
                }

            }
            console.log("pip " + JSON.stringify(poly_results))

        }


        //console.log(JSON.stringify(section_speed_array))
        //console.log(JSON.stringify(section_alt_array))
        //console.log(JSON.stringify(section_space_array))
        //console.log(JSON.stringify(sectorCache))


        wptScoreList.clear();

        var wptString = [];
        igcFilesModel.setProperty(current, "trackHash", "");
        igcFilesModel.setProperty(current, "wptScoreDetails", "");
        igcFilesModel.setProperty(current, "speedSectionsScoreDetails", "");
        igcFilesModel.setProperty(current, "spaceSectionsScoreDetails", "");
        igcFilesModel.setProperty(current, "altitudeSectionsScoreDetails", "");

        var category_alt_penalty = trItem.alt_penalty;
        var category_marker_max_score = trItem.marker_max_score;
        var category_oposite_direction_penalty = trItem.oposite_direction_penalty;
        var category_gyre_penalty = trItem.gyre_penalty;
        var category_out_of_sector_penalty = trItem.out_of_sector_penalty;
        var category_photos_max_score = trItem.photos_max_score;
        var category_preparation_time = trItem.preparation_time; //sec
        var category_sg_max_score = trItem.sg_max_score;
        var category_speed_penalty = trItem.speed_penalty;
        var category_speed_tolerance = trItem.speed_tolerance;
        var category_tg_max_score = trItem.tg_max_score;
        var category_tg_penalty = trItem.tg_penalty;
        var category_tg_tolerance = trItem.tg_tolerance;
        var category_time_window_penalty = trItem.time_window_penalty;
        var category_time_window_size = trItem.time_window_size;
        var category_tp_max_score = trItem.tp_max_score;

        var str = "";
        var dataArr = [];
        distance_cumul = 0;
        var extra_time_cmul = F.timeToUnix(ctnt.startTime);

        var new_section_speed_array = [];
        var new_section_alt_array = [];
        var new_section_space_array = [];

        var speed_sections_score = 0;
        var space_sections_score = 0;
        var altitude_sections_score = 0;

        // create and compute speed sections data
        var item;
        var arr_item;
        var speed_sec_score = 0;

        for (i = 0; i < section_speed_array.length; i++) {
            item = section_speed_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(speedSectionsScoreListManualValuesCache, "startPointName", item.startName, "endPointName", item.endName);

            arr_item = {
                "startPointName" : item.startName,
                "endPointName" : item.endName,
                "distance ": item.distance,
                "calculatedSpeed": Math.round(item.speed),
                "speedDifference": 0,
                "manualSpeed" : (index !== -1 ? speedSectionsScoreListManualValuesCache.get(index).manualSpeed : -1),
                "speedSecScore": -1,
                "maxScore" : category_tg_max_score,
                "speedTolerance" : category_speed_tolerance,
                "speedPenaly" : category_speed_penalty
            }

            arr_item['speedDifference'] = (arr_item.manualSpeed === -1 ? Math.abs(ctnt.speed - arr_item.calculatedSpeed) : Math.abs(ctnt.speed - arr_item.manualSpeed));
            speed_sec_score = getSpeedSectionScore(arr_item['speedDifference'], category_speed_tolerance, category_tg_max_score, category_speed_penalty);
            arr_item['speedSecScore'] = speed_sec_score;
            speed_sections_score += speed_sec_score;

            // speedSectionsScoreList.append(arr_item);
            new_section_speed_array.push(arr_item);
        }

        // create and alt sections data
        for (i = 0; i < section_alt_array.length; i++) {
            item = section_alt_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(altSectionsScoreListManualValuesCache, "startPointName", item.startName, "endPointName", item.endName);

            arr_item = {
                "startPointName" : item.startName,
                "endPointName" : item.endName,
                "altMinEntriesCount" : item.entries_below,
                "manualAltMinEntriesCount" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMinEntriesCount : -1),
                "altMinEntriesTime" : item.time_spent_below,
                "manualAltMinEntriesTime" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMinEntriesTime : -1),
                "altMaxEntriesCount" : item.entries_above,
                "manualAltMaxEntriesCount" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMaxEntriesCount : -1),
                "altMaxEntriesTime" : item.time_spent_above,
                "manualAltMaxEntriesTime" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMaxEntriesTime : -1),
                "penaltyPercent": category_out_of_sector_penalty,
                "altSecScore": -1
            }

            new_section_alt_array.push(arr_item);
        }

        // create and space sections data
        for (i = 0; i < section_space_array.length; i++) {
            item = section_space_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(spaceSectionsScoreListManualValuesCache, "startPointName", item.startName, "endPointName", item.endName);

            arr_item = {
                "startPointName" : item.startName,
                "endPointName" : item.endName,
                "entries_out": item.entries_out,
                "manualEntries_out": (index !== -1 ? spaceSectionsScoreListManualValuesCache.get(index).manualEntries_out : -1),
                "time_spent_out": item.time_spent_out,
                "manualTime_spent_out": (index !== -1 ? spaceSectionsScoreListManualValuesCache.get(index).manualTime_spent_out : -1),
                "penaltyPercent": category_out_of_sector_penalty,
                "spaceSecScore": -1
            }

            new_section_space_array.push(arr_item);
        }

        for (i = 0; i < tpiData.length; i++ ) {
            var item = tpiData[i];
            var speed = '';
            var alt_min = '';
            var alt_min_time = '';
            var alt_max = '';
            var alt_max_time ='';
            var alt_min_count = '';
            var alt_min_time_spent = '';
            var alt_max_count = '';
            var alt_max_time_spent = '';
            var distance_max = '';
            var distance_time = '';
            var distance_out_count = '';
            var distance_out_spent = '';
            var distance_out_bi_count = '';
            var distance_out_bi_spent = '';

            var trItemCurrentPoint = trItem.conn[i];


            // suma extra casu a vzdalenosti od VBT
            distance_cumul += item.distance;
            extra_time_cmul += trItemCurrentPoint.addTime;


            for (var j = 0; j < section_speed_array_length; j++) {
                section = section_speed_array[j]
                if (section.start == item.tid) {
                    speed = section.speed;
                    if (section.measure || (section.time_start === 0)) {
                        speed = '';
                    }
                }
            }

            for (var j = 0; j < section_alt_array_length; j++) {
                section = section_alt_array[j]
                if (section.start == item.tid) {
                    alt_min = section.alt_min;
                    alt_min_time = section.alt_min_time;
                    alt_min_count = section.entries_below;
                    alt_min_time_spent = section.time_spent_below;

                    alt_max = section.alt_max;
                    alt_max_time = section.alt_max_time;
                    alt_max_count = section.entries_above;
                    alt_max_time_spent = section.time_spent_above;
                    if ((section.alt_min === F.alt_min_init) || section.measure) { // did not pass to end
                        alt_min = alt_min_time = alt_min_count = alt_min_time_spent = alt_max = alt_max_time = alt_max_count = alt_max_time_spent = '';
                    }
                }
            }

            for (var j = 0; j < section_space_array_length; j++) {
                section = section_space_array[j]
                if (section.start == item.tid) {
                    distance_max  = section.distance
                    distance_time = section.distance_time;
                    distance_out_count = section.entries_out;
                    distance_out_spent = section.time_spent_out;
                    distance_out_bi_count = section.entries_out_bi;
                    distance_out_bi_spent = section.time_spent_out_bi;
                    if (section.measure || (distance_max === F.distance_max_init)) {
                        distance_max = distance_time = distance_out_count = distance_out_spent = distance_out_bi_count = distance_out_bi_spent = '';
                    }
                }
            }

            var newData = {
                "tid": item.tid,
                "title": item.name,
                "alt": String(item.alt),
                "lat": F.getLat(item.lat, {coordinateFormat: "DMS"}),
                "lon": F.getLon(item.lon, {coordinateFormat: "DMS"}),
                "radius": parseFloat(item.radius),
                "angle": item.angle,
                "time": item.time,
                "hit": item.hit,
                "sg_hit": item.sg_hit,
                "speed": String(Math.round(speed)),
                "altmax": String(Math.round(alt_max)),
                "altmaxtime": String(alt_max_time),
                "altmin": String(Math.round(alt_min)),
                "altmintime": String(alt_min_time),
                "distance": String(Math.round(distance_max)),
                "distancetime": String(distance_time),
                "distanceoutcount": String(distance_out_count),
                "distanceoutspent": String(F.addTimeStrFormat(distance_out_spent)),
                "distanceoutbicount": String(distance_out_bi_count),
                "distanceoutbispent": String(F.addTimeStrFormat(distance_out_bi_spent)),
                "altmincount": String(alt_min_count),
                "altmintime_spent": String(F.addTimeStrFormat(alt_min_time_spent)),
                "altmaxcount": String(alt_max_count),
                "altmaxtime_spent": String(F.addTimeStrFormat(alt_max_time_spent)),
            }

            var tg_time_calculated = Math.round(distance_cumul * 3.6/ctnt.speed + extra_time_cmul);
            var tg_time_measured = F.timeToUnix(item.time);
            var tg_time_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "tg_time_manual", -1, "tid", item.tid);

            var tg_time_difference = tg_time_manual === -1 ? Math.abs(tg_time_calculated - tg_time_measured) : Math.abs(tg_time_calculated - tg_time_manual);

            var tp_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "tp_hit_manual", -1, "tid", item.tid);
            var sg_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "sg_hit_manual", -1, "tid", item.tid);
            var alt_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "alt_manual", -1, "tid", item.tid);
            var point_alt_min = trItemCurrentPoint.alt_min;
            var point_alt_max = trItemCurrentPoint.alt_max;

            var newScoreData = {

                "tid": item.tid,
                "title": item.name,
                "type": item.flags,
                "distance_from_vbt": distance_cumul,

                "tg_time_calculated": tg_time_calculated,
                "tg_time_measured": tg_time_measured,
                "tg_time_manual": tg_time_manual,
                "tg_time_difference": tg_time_difference,
                "tg_category_time_tolerance": category_tg_tolerance,
                "tg_category_max_score": category_tg_max_score,
                "tg_category_penalty": category_tg_penalty,
                "tg_score": 0,

                "tp_hit_measured": item.hit,
                "tp_hit_manual": tp_manual,
                "tp_category_max_score": category_tp_max_score,
                "tp_score": 0,

                "sg_hit_measured": item.sg_hit,
                "sg_hit_manual": sg_manual,
                "sg_category_max_score": category_sg_max_score,
                "sg_score": 0,

                "alt_max": point_alt_max,
                "alt_min": point_alt_min,
                "alt_measured": isNaN(parseInt(item.alt)) ? -1 : parseInt(item.alt),
                                                            "alt_manual": alt_manual,
                                                            "alt_score": 0,
                                                            "category_alt_penalty": category_alt_penalty

            }

            // calc score points for whole struct
            newScoreData = calcPointScore(newScoreData);

            wptString.push(JSON.stringify(newScoreData));

            wptScoreList.append(newData);
            //wptNewScoreList.append(newScoreData);


            dataArr.push(newData)
            str += "\"" + item.time + "\";";
            str += "\"" + (item.hit ? "YES" : "NO" )+ "\";";
            str += "\"" + (item.sg_hit ? "YES" : "NO" ) + "\";";
            str += "\"" + item.alt + "\";";
            str += "\"" + speed + "\";";
            //str += "\"" + alt_min + "\";";
            //str += "\"" + alt_max + "\";";
            //str += "\"" + alt_min_time + "\";";
            //str += "\"" + alt_max_time + "\";";
            //str += "\"" + distance_max + "\";";
            //str += "\"" + distance_time + "\";";
            str += "\"" + distance_out_count + "\";";
            str += "\"" + distance_out_spent + "\";";
            //str += "\"" + distance_out_bi_count + "\";";
            //str += "\"" + distance_out_bi_spent + "\";";
            str += "\"" + alt_min_count + "\";";
            str += "\"" + alt_min_time_spent + "\";";
            str += "\"" + alt_max_count + "\";";
            str += "\"" + alt_max_time_spent + "\";";
        }
        str += "\"\";";

        for (var i = 0; i < poly_results.length; i++) {
            var poly_result = poly_results[i];
            str += "\"" + poly_result.count + "\";";
            str += "\"" + poly_result.time_start + "\";";
            str += "\"" + poly_result.time_end + "\";";
            str += "\"" + poly_result.alt_min + "\";";
            str += "\"" + poly_result.alt_max + "\";";
        }

        igcFilesModel.setProperty(current, "trackHash", MD5.MD5(JSON.stringify(trItem)));
        igcFilesModel.setProperty(current, "wptScoreDetails", wptString.join("; "));
        igcFilesModel.setProperty(current, "speedSectionsScoreDetails", JSON.stringify(new_section_speed_array));
        igcFilesModel.setProperty(current, "spaceSectionsScoreDetails", JSON.stringify(new_section_space_array));
        igcFilesModel.setProperty(current, "altitudeSectionsScoreDetails", JSON.stringify(new_section_alt_array));

        igcFilesModel.setProperty(current, "score_json", JSON.stringify(dataArr))
        igcFilesModel.setProperty(current, "score", str)

        //calc contestant manual values score - markers, photos,..
        recalculateContestnatManualScoreValues(current);

        // no contestant selected
        var score = -1;
        if (igcFilesModel.get(current).contestant !== 0) {

            score = getTotalScore(ctnt, current);
        }

        igcFilesModel.setProperty(current, "scorePoints", score);
        recalculateScoresTo1000();

        // save changes to CSV
        writeScoreManulaValToCSV();
        writeCSV()

        console.timeEnd("computeScore")
        return str;
    }

    function writeScoreManulaValToCSV() {

        if (igcFilesTable.currentRow < 0)
            return;

        // reload current contestant
        var contestantIndex = igcFilesModel.get(igcFilesTable.currentRow).contestant;
        ctnt = contestantsListModel.get(contestantIndex);

        // load manual values into list models - used when compute score
        loadStringIntoListModel(wptNewScoreListManualValuesCache, ctnt.prevResultsWPT, "; ");
        loadStringIntoListModel(speedSectionsScoreListManualValuesCache, ctnt.prevResultsSpeedSec, "; ");
        loadStringIntoListModel(spaceSectionsScoreListManualValuesCache, ctnt.prevResultsSpaceSec, "; ");
        loadStringIntoListModel(altSectionsScoreListManualValuesCache, ctnt.prevResultsAltSec, "; ");

        //header - from office
        var str = "\"Jmeno\";\"Znaky – ok\";\"Znaky – spatne\";\"Znaky – falesne\";\"Foto – ok\";\"Foto – spatne\";\"Foto – falesne\";\"Presnost pristani\";\"Ostatni – body\";\"Ostatni – procenta\";\"Cas startu – startovka\";\"Cas startu – zmereno\";\"Cas startu – penalizace body\";\"Krouzeni, protismerny let – pocet\";\"Krouzeni, protismerny let – penalizace body\";\"Ostatni penalizace – body\";\"Ostatni penalizace – procenta\";\"Body\";\"Body na 1000\";\"Klasifikovan\";\"Poznamka\";\"Casove brany\";\"Otocne body\";\"Prostorove brany\";\"Vyskove omezeni  penalizace\";\"Rychlostni useky\";\"Vyskove useky penalizace proc\";\"Prostorove useky penalizace proc\";\"Pilot ID\";\"Copilot ID\"";
        str += "\n";

        var igcListModelItem;
        var tgScoreSum = 0;
        var tpScoreSum = 0;
        var sgScoreSum = 0;
        var altPenaltySum = 0;
        var speedSecScoreSum = 0;
        var altSecScoreSum = 0;
        var spaceSecScoreSum = 0;
        var tg_time_manual = [];
        var tp_hit_manual = [];
        var sg_hit_manual = [];
        var alt_manual = [];

        var i;
        var j;
        var item;

        // Calc wpt points sum
        for (i = 0; i < wptNewScoreListManualValuesCache.count; i++) {
            item = wptNewScoreListManualValuesCache.get(i);

            tgScoreSum += item.tg_score === -1 ? 0 : item.tg_score;
            tpScoreSum += item.tp_score === -1 ? 0 : item.tp_score;
            sgScoreSum += item.sg_score === -1 ? 0 : item.sg_score;
            altPenaltySum += item.alt_score === -1 ? 0 : item.alt_score;

            tg_time_manual.push(item.tg_time_manual);
            tp_hit_manual.push(item.tp_hit_manual);
            sg_hit_manual.push(item.sg_hit_manual);
            alt_manual.push(item.alt_manual);
        }
        wptNewScoreListManualValuesCache.clear();

        // Calc sections points sum
        for (i = 0; i < speedSectionsScoreListManualValuesCache.count; i++) {
            item = speedSectionsScoreListManualValuesCache.get(i);

            speedSecScoreSum += item.speedSecScore;
        }
        speedSectionsScoreListManualValuesCache.clear();

        for (i = 0; i < spaceSectionsScoreListManualValuesCache.count; i++) {
            item = spaceSectionsScoreListManualValuesCache.get(i);

            spaceSecScoreSum += item.spaceSecScore;
        }
        spaceSectionsScoreListManualValuesCache.clear();

        for (i = 0; i < altSectionsScoreListManualValuesCache.count; i++) {
            item = altSectionsScoreListManualValuesCache.get(i);

            altSecScoreSum += item.altSecScore;
        }
        altSectionsScoreListManualValuesCache.clear();


        // Find classify field in igc for current contestant
        for (j = 0; j < igcFilesModel.count; j++) {

            igcListModelItem = igcFilesModel.get(j);

            if (igcListModelItem.contestant <= 0 || igcListModelItem.contestant >= contestantsListModel.count)
                continue;

            // get row contestant item
            item = contestantsListModel.get(igcListModelItem.contestant)

            str += "\"" + F.addSlashes(item.name) + "\";"

            str += "\"" + item.markersOk + "\";"
            str += "\"" + item.markersNok + "\";"
            str += "\"" + item.markersFalse + "\";"

            str += "\"" + item.photosOk + "\";"
            str += "\"" + item.photosNok + "\";"
            str += "\"" + item.photosFalse + "\";"

            str += "\"" + item.landingScore + "\";"

            str += "\"" + item.otherPoints + "\";"
            str += "\"" + 0 + "\";"

            str += "\"" + item.startTime + "\";"
            str += "\"" + item.startTimeMeasured + "\";"
            str += "\"" + Math.abs(item.startTimeScore) + "\";"

            str += "\"" + (item.circlingCount + item.oppositeCount) + "\";"
            str += "\"" + Math.abs(item.oppositeScore + item.circlingScore) + "\";"

            str += "\"" + item.otherPenalty + "\";"
            str += "\"" + 0 + "\";"

            str += "\"" + Math.max(igcListModelItem.scorePoints, 0) + "\";"
            str += "\"" + Math.max(igcListModelItem.scorePoints1000, 0) + "\";"
            var classify = igcListModelItem.classify === 0 ? "yes" : "no";

            str += "\"" + classify + "\";"   //index 20

            str += "\"" + F.addSlashes(item.otherPointsNote) + "/&/" + F.addSlashes(item.otherPenaltyNote) + "\";" //note delimeter

            str += "\"" + tgScoreSum + "\";"
            str += "\"" + tpScoreSum + "\";"
            str += "\"" + sgScoreSum + "\";"
            str += "\"" + altPenaltySum + "\";"
            str += "\"" + speedSecScoreSum + "\";"
            str += "\"" + altSecScoreSum + "\";"
            str += "\"" + spaceSecScoreSum + "\";"
            str += "\"" + item.pilot_id + "\";"
            str += "\"" + item.copilot_id + "\";"
            str += "\"" + F.addSlashes(igcListModelItem.trackHash) + "\";"
            str += "\"" + igcListModelItem.speed + "\";"
            str += "\"" + igcListModelItem.startTime + "\";"
            str += "\"" + igcListModelItem.category + "\";"
            str += "\"" + F.replaceDoubleQuotes(igcListModelItem.wptScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(igcListModelItem.speedSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(igcListModelItem.spaceSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(igcListModelItem.altitudeSectionsScoreDetails) + "\";"
            str += "\"" + F.addSlashes(igcListModelItem.fileName) + "\";"
            str += "\"" + F.addSlashes(igcListModelItem.score) + "\";"
            str += "\"" + F.replaceDoubleQuotes(igcListModelItem.score_json) + "\";"
            str += "\"" + item.markersScore + "\";"
            str += "\"" + item.photosScore + "\";"
            str += "\"" + item.startTimeDifference + "\";"
            str += "\"" + item.circlingCount + "\";"
            str += "\"" + item.circlingScore + "\";"
            str += "\"" + item.oppositeCount + "\";"
            str += "\"" + item.oppositeScore + "\";"


            str += "\n";


        }

        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvResultsFile), str);
    }

    function writeCSV() {

        var str = "";

        for (var i = 0; i < igcFilesModel.count; i++) {
            var item = igcFilesModel.get(i)
            if (item.contestant < 0 ) {
                console.log("Error (writeCSV): " +JSON.stringify(item))
            }

            var ctnt = contestantsListModel.get(item.contestant)

            contestantsListModel.setProperty(item.contestant, "filename", item.fileName);
            str += "\"" + ctnt.fullName + "\";"
            str += "\"" + item.fileName + "\";"

            str += item.score;
            str += "\n";
        }
        str += ""


        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvFile), str);



        str = "";
        // polozka i = 0 je vyhrazena pro pouziti "prazdne polozky" v comboboxu; misto toho by mela jit hlavicka
        for (var i = 1; i < contestantsListModel.count; i++) {
            var item = contestantsListModel.get(i);

            var line = "\"" + F.addSlashes(item.name)
                    +"\";\""+ F.addSlashes(item.category)
                    +"\";\""+ F.addSlashes(item.name + "_" + item.category)//F.addSlashes(item.fullName)
                    +"\";\""+ F.addSlashes(item.startTime)
                    +"\";\""+ F.addSlashes(item.filename)
                    +"\";\""+ F.addSlashes(item.speed)
                    +"\";\""+ F.addSlashes(item.aircraft_type)
                    +"\";\""+ F.addSlashes(item.aircraft_registration)
                    +"\";\""+ F.addSlashes(item.crew_id)
                    +"\";\""+ F.addSlashes(item.pilot_id)
                    +"\";\""+ F.addSlashes(item.copilot_id)
                    +"\";\""+ F.addSlashes(""/*item.pilotAvatarBase64*/)
                    +"\";\""+ F.addSlashes(""/*item.copilotAvatarBase64*/) + "\""

            str += line + "\n";
        }
        file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), str);

    }

    function getPtByPid(pid, points) {
        for (var i = 0; i < points.length; i++) {
            var item = points[i]
            if (item.pid == pid) {
                return item;
            }
        }
    }

    function getPolyByCid(cid, poly) {
        for (var i = 0; i < poly.length; i++) {
            var item = poly[i];
            if (item.cid == cid) {
                return item;
            }
        }
    }

    function storeTrackSettings(filename) {
        var str = "";
        var trks = tracks.tracks
        var points = tracks.points;
        var polys = tracks.poly;
        for (var i = 0; i < trks.length; i++) {
            var trk = trks[i]
            var category_name = F.addSlashes(trk.name)
            str += "\"" + category_name + "\";";
            str += "\"" + trk.alt_penalty + "\";";
            str += "\"" + trk.gyre_penalty + "\";";
            str += "\"" + trk.marker_max_score + "\";";
            str += "\"" + trk.oposite_direction_penalty + "\";";
            str += "\"" + trk.out_of_sector_penalty + "\";";
            str += "\"" + trk.photos_max_score + "\";";
            str += "\"" + trk.speed_penalty + "\";";
            str += "\"" + trk.tg_max_score + "\";";
            str += "\"" + trk.tg_penalty + "\";";
            str += "\"" + trk.tg_tolerance + "\";";
            str += "\"" + trk.time_window_penalty + "\";";
            str += "\"" + trk.time_window_size + "\";";
            str += "\"" + trk.tp_max_score + "\";";
            str += "\"" + trk.speed_tolerance + "\";";
            str += "\"" + trk.sg_max_score + "\";";
            str += "\"" + ((trk.preparation_time !== undefined) ? trk.preparation_time : 0) + "\";";

            //            str += "\n";
            //            str += "\"" + category_name + "___PART2" +"\";";

            var conns = trk.conn;


            for (var j = 0; (j < conns.length); j++) {
                var c = conns[j];

                var pt = getPtByPid(c.pid, points)

                //                console.log(JSON.stringify(pt))
                str += "\"" + ((c.flags < 0) ? trk.default_flags : c.flags ) + "\";";
                str += "\"" + ((c.angle < 0) ? c.computed_angle : c.angle) + "\";";
                str += "\"" + ((c.distance < 0) ? c.computed_distance : c.distance) + "\";";
                str += "\"" + ((c.addTime < 0) ? trk.default_addTime : c.addTime) + "\";";
                str += "\"" + ((c.radius < 0) ? trk.default_radius : c.radius) + "\";";
                str += "\"" + ((c.alt_max < 0) ? trk.default_alt_max : c.alt_max) + "\";";
                str += "\"" + ((c.alt_min < 0) ? trk.default_alt_min : c.alt_min) + "\";";
                str += "\"" + ((c.speed_max < 0) ? trk.default_speed_max : c.speed_max) + "\";";
                str += "\"" + ((c.speed_min < 0) ? trk.default_speed_min : c.speed_min) + "\";";
                str += "\"" + F.addSlashes(pt.name) + "\";";
            }



            var section_speed_start_pid = -1;
            var section_alt_start_pid = -1;
            var section_space_start_pid = -1;
            var sections = [];

            for (var j = 0; j < conns.length; j++) {
                var c = conns[j];

                var flags = ((c.flags < 0) ? trk.default_flags : c.flags );
                var section_speed_start = F.getFlagsByIndex(7, flags)
                var section_speed_end   = F.getFlagsByIndex(8, flags)
                var section_alt_start   = F.getFlagsByIndex(9, flags)
                var section_alt_end     = F.getFlagsByIndex(10, flags)
                var section_space_start = F.getFlagsByIndex(11, flags)
                var section_space_end   = F.getFlagsByIndex(12, flags)

                if (section_speed_end && (section_speed_start_pid >= 0)) {
                    var item = {
                        "start": section_speed_start_pid,
                        "end": c.pid,
                        "type":
                        //% "speed"
                        qsTrId("section-type-speed")
                    }
                    sections.push(item);
                    section_speed_start_pid = -1;
                }

                if (section_alt_end && (section_alt_start_pid >= 0)) {
                    var item = {
                        "start": section_alt_start_pid,
                        "end": c.pid,
                        "type":
                        //% "altitude"
                        qsTrId("section-type-altitude")
                    }
                    sections.push(item);
                    section_alt_start_pid = -1;
                }

                if (section_space_end && (section_space_start_pid >= 0)) {
                    var item = {
                        "start": section_space_start_pid,
                        "end": c.pid,
                        "type":
                        //% "space"
                        qsTrId("section-type-space")
                    }
                    sections.push(item);
                    section_space_start_pid = -1;
                }

                if (section_speed_start) {
                    section_speed_start_pid = c.pid;
                }
                if (section_alt_start) {
                    section_alt_start_pid = c.pid;
                }
                if (section_space_start) {
                    section_space_start_pid = c.pid;
                }


            }

            str += "\n";
            str += "\"" + category_name + "___sections" +"\";";


            for (var j = 0; j < sections.length; j++) {
                var section = sections[j];
                var pt_start = getPtByPid(section.start, points)
                var pt_end = getPtByPid(section.end, points)

                str += "\"" + section.type + "\";\"" + section.start + "\";\"" + F.addSlashes(pt_start.name) + "\";\"" + section.end + "\";\"" + F.addSlashes(pt_end.name) + "\";"
            }


            var poly = trk.poly;

            str += "\n";
            str += "\"" + category_name + "___polygons" +"\";";
            for (var j = 0; j < poly.length; j++) {
                var poly_info = poly[j];
                var poly_data = getPolyByCid(poly_info.cid, polys);
                str += "\"" +  poly_data.name +"\";"
                str += "\"" + poly_info.score +"\";"
            }


            str += "\n";

        }
        str += ""

        file_reader.write(Qt.resolvedUrl(filename), str);

    }


    function exportKml(filename) {
        var str;
        str="<?xml version=\"1.0\" encoding=\"UTF-8\"?> <!-- Generator: LAA Editor--> <kml xmlns='http://earth.google.com/kml/2.1'><Document><Folder><name>"+F.basename(filename)+"</name><open>1</open>";


        var points = tracks.points;

        if (points.length > 0) {
            var item = points[0]
            str += "<LookAt><longitude>"+item.lon+"</longitude> <latitude>"+item.lat+"</latitude> <altitude>0</altitude><range>3000,000000000000000000</range> <tilt>45</tilt> <heading>0</heading> </LookAt>"
        }
        for (var i = 0; i < points.length; i++) {
            var item = points[i];
            str += "<Placemark>
  <name>"+item.name+"</name>
  <Point>
    <extrude>0</extrude>
    <altitudeMode>clampToGround</altitudeMode>
    <coordinates>"+item.lon+","+item.lat+"</coordinates>
  </Point>
</Placemark>"


        }

        var poly = tracks.poly;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];
            var coordStr = "";
            var color = item.color;
            if (color.length === 6) {
                color = "FF" + color;
            }

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                coordStr += polyPoint.lon + "," + polyPoint.lat + "
"
            }

            str += "<Placemark>
  <name>"+item.name+"</name>
  <Style>
    <LineStyle>
      <color>"+color+"</color>
      <width> 4 </width>
    </LineStyle>
  </Style>
  <LinearRing>
    <extrude>0</extrude>
    <tessellate>0</tessellate>
    <coordinates>"+coordStr+"</coordinates>
  </LinearRing>
</Placemark>
"

        }

        var poly = map.polygonCache;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];
            var coordStr = "";
            var color = item.color;
            if (color.length === 6) {
                color = "FF" + color;
            }

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                coordStr += polyPoint.lon + "," + polyPoint.lat + "
"
            }

            str += "<Placemark>
  <name>"+item.name+"</name>
  <Style>
    <LineStyle>
      <color>"+color+"</color>
      <width> 4 </width>
    </LineStyle>
  </Style>
  <LinearRing>
    <extrude>0</extrude>
    <tessellate>0</tessellate>
    <coordinates>"+coordStr+"</coordinates>
  </LinearRing>
</Placemark>
"

        }


        coordStr = "";
        for (i = 0; i < igc.count; i++) {
            var igcItem = igc.get(i);
            coordStr += igcItem.lon + "," + igcItem.lat + "
";
        }

        str += "<Placemark>
  <name>Flight log</name>
  <Style>
    <LineStyle>
      <color>ff00ff00</color>
      <width> 4 </width>
    </LineStyle>
  </Style>
  <LinearRing>
    <extrude>0</extrude>
    <tessellate>0</tessellate>
    <coordinates>"+coordStr+"</coordinates>
  </LinearRing>
</Placemark>
"


        str += "</Folder></Document></kml>";


        file_reader.write(Qt.resolvedUrl(filename), str);



    }

    function exportGpx(filename) {
        console.log("export gpx: " + filename)
        var str ="";
        str += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<gpx
  version=\"1.0\"
  creator=\"LAA Editor - http://www.laa.cz\"
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xmlns=\"http://www.topografix.com/GPX/1/0\"
  xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd\">
"
        var points = tracks.points;

        for (var i = 0; i < points.length; i++) {
            var item = points[i];
            str += "<wpt lat=\""+item.lat+"\" lon=\""+item.lon+"\">
  <ele>0.000000</ele>
  <name>"+item.name+"</name>
  <cmt>"+item.name+"</cmt>
  <desc>"+item.name+"</desc>
</wpt>
"
        }


        var poly = tracks.poly;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];

            str += "<trk><name>"+item.name+"</name><trkseg>"


            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                str +="<trkpt lat=\"" + polyPoint.lat + "\" lon=\""+polyPoint.lon+"\">
  <ele>0</ele>
  <time>1970-01-01T00:00:01Z</time>
</trkpt>"
            }
            str += "</trkseg></trk>"
        }

        var poly = map.polygonCache;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];
            str += "<trk><name>"+item.name+"</name><trkseg>"

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                str +="<trkpt lat=\"" + polyPoint.lat + "\" lon=\""+polyPoint.lon+"\">
  <ele>0</ele>
  <time>1970-01-01T00:00:01Z</time>
</trkpt>"
            }
            str += "</trkseg></trk>"

        }

        str += "<trk><name>Flight log</name><trkseg>"

        var igcdate = igc.date.getTime()

        for (i = 0; i < igc.count; i++) {
            var igcItem = igc.get(i);
            var igcTime = new Date(F.timeToUnix(igcItem.time)*1000 + igcdate)
            str +="<trkpt lat=\"" + igcItem.lat + "\" lon=\""+igcItem.lon+"\">
  <ele>"+igcItem.alt+"</ele>
  <time> " + igcTime.toISOString() + "</time>
</trkpt>";



        }

        str += "</trkseg></trk>"
        str += "</gpx>"

        file_reader.write(Qt.resolvedUrl(filename), str);

    }


    function evaluate_all_data() {
        igcFilesTable.currentRow = -1;
        igcFilesTable.selection.clear();
        for (var i = 0; i < igcFilesModel.count; i++) {
            igcFilesModel.setProperty(i, "score", "");
        }
        evaluateTimer.running = true;
    }

    function compareSeventhColumn(a, b) {

        if (parseInt(a[7]) === parseInt(b[7])) {
            return 0;
        }
        else {
            return (parseInt(a[7]) > parseInt(b[7])) ? -1 : 1;
        }
    }

    function getContinuousResults() {

        var igcItem;
        var contestant;
        var index;

        var resArr = ['R-AL1', 'R-AL2', 'S-AL1', 'S-AL2', 'R-WL1', 'R-WL2', 'S-WL1', 'S-WL2', 'CUSTOM1', 'CUSTOM2', 'CUSTOM3', 'CUSTOM4'];

        /// nefunguje PROC???
        //for (var key in resArr) {
        //    resArr[key] = [];
        //}

        // humus - viz vyse
        resArr['R-AL1'] = [];
        resArr['R-AL2'] = [];
        resArr['S-AL1'] = [];
        resArr['S-AL2'] = [];
        resArr['R-WL1'] = [];
        resArr['R-WL2'] = [];
        resArr['S-WL1'] = [];
        resArr['S-WL2'] = [];
        resArr['CUSTOM1'] = [];
        resArr['CUSTOM2'] = [];
        resArr['CUSTOM3'] = [];
        resArr['CUSTOM4'] = [];

        for (var i = 0; i < igcFilesModel.count; i++) {

            igcItem = igcFilesModel.get(i);
            contestant = contestantsListModel.get(igcItem.contestant);

            if (resArr.indexOf(igcItem.category) !== -1) {

                resArr[igcItem.category].push([contestant.name,
                                               igcItem.category,
                                               contestant.startTime,
                                               String(contestant.speed),
                                               contestant.aircraft_registration,
                                               contestant.aircraft_type,
                                               String(igcItem.scorePoints),
                                               String(igcItem.scorePoints1000)]);
                //(parseInt(igcItem.scorePoints) < 0 ? "" : String(igcItem.scorePoints)),
                //(parseInt(igcItem.scorePoints1000) < 0 ? "" : String(igcItem.scorePoints1000))])
            }

        }

        for (var key in resArr) {

            /// nefunguje PROC???
            //resArr[key].sort(compareSeventhColumn) // score points to 1000

            // humus - viz vyse
            resArr['R-AL1'].sort(compareSeventhColumn);
            resArr['R-AL2'].sort(compareSeventhColumn);
            resArr['S-AL1'].sort(compareSeventhColumn);
            resArr['S-AL2'].sort(compareSeventhColumn);
            resArr['R-WL1'].sort(compareSeventhColumn);
            resArr['R-WL2'].sort(compareSeventhColumn);
            resArr['S-WL1'].sort(compareSeventhColumn);
            resArr['S-WL2'].sort(compareSeventhColumn);
            resArr['CUSTOM1'].sort(compareSeventhColumn);
            resArr['CUSTOM2'].sort(compareSeventhColumn);
            resArr['CUSTOM3'].sort(compareSeventhColumn);
            resArr['CUSTOM4'].sort(compareSeventhColumn);
        }

        return resArr;
    }


    function updateContestantInCategoryCounters(category, incrementVal) {

        switch(category) {
        case "R-AL1":
            _RAL1_count = incrementVal ? (++_RAL1_count) :  Math.max((--_RAL1_count), 0)
            break;
        case "R-AL2":
            _RAL2_count = incrementVal ? (++_RAL2_count) :  Math.max((--_RAL2_count), 0)
            break;
        case "S-AL1":
            _SAL1_count = incrementVal ? (++_SAL1_count) :  Math.max((--_SAL1_count), 0)
            break;
        case "S-AL2":
            _SAL2_count = incrementVal ? (++_SAL2_count) :  Math.max((--_SAL2_count), 0)
            break;
        case "R-WL1":
            _RWL1_count = incrementVal ? (++_RWL1_count) :  Math.max((--_RWL1_count), 0)
            break;
        case "R-WL2":
            _RWL2_count = incrementVal ? (++_RWL2_count) :  Math.max((--_RWL2_count), 0)
            break;
        case "S-WL1":
            _SWL1_count = incrementVal ? (++_SWL1_count) :  Math.max((--_SWL1_count), 0)
            break;
        case "S-WL2":
            _SWL2_count = incrementVal ? (++_SWL2_count) :  Math.max((--_SWL2_count), 0)
            break;
        case "CUSTOM1":
            _CUSTOM1_count = incrementVal ? (++_CUSTOM1_count) :  Math.max((--_CUSTOM1_count), 0)
            break;
        case "CUSTOM2":
            _CUSTOM2_count = incrementVal ? (++_CUSTOM2_count) :  Math.max((--_CUSTOM2_count), 0)
            break;
        case "CUSTOM3":
            _CUSTOM3_count = incrementVal ? (++_CUSTOM3_count) :  Math.max((--_CUSTOM3_count), 0)
            break;
        case "CUSTOM4":
            _CUSTOM4_count = incrementVal ? (++_CUSTOM4_count) :  Math.max((--_CUSTOM4_count), 0)
            break;

        default:
            console.log("invalid category: " + category + " in func: updateContestantInCategoryCounters")
            break;
        }
    }


    function initCategoryCounters() {

        _RAL1_count = 0;
        _RAL2_count = 0;
        _SAL1_count = 0;
        _SAL2_count = 0;
        _RWL1_count = 0;
        _RWL2_count = 0;
        _SWL1_count = 0;
        _SWL2_count = 0;
        _CUSTOM1_count = 0;
        _CUSTOM2_count = 0;
        _CUSTOM3_count = 0;
        _CUSTOM4_count = 0;

    }

    Timer {
        id: evaluateTimer
        // evaluate all via timer;
        interval: 500;
        repeat: true;
        running: false;
        onTriggered: {

            if (igcFilesModel.count <= 0) {
                running = false;
                return;
            }

            var current = -1;
            igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

            // select first item of list
            if (current < 0) {
                current = 0
                igcFilesTable.selection.clear();
                igcFilesTable.selection.select(current)
                igcFilesTable.currentRow = current;
                return;
            }

            var item = igcFilesModel.get(current);


            if ((item.contestant === 0) || (item.score !== ""))  { // if ((no contestent selected) or (already computed))
                if (current+1 == igcFilesModel.count) { // finsihed
                    running = false;

                    // create results if flag is set
                    if (generateResultsFlag) {

                        generateResultsFlag = false;

                        igcFilesTable.currentRow = -1;
                        igcFilesTable.selection.clear();

                        resultsTimer.running = true;
                    }


                } else { // go to next
                    igcFilesTable.selection.clear();
                    igcFilesTable.selection.select(current+1)
                    igcFilesTable.currentRow = current+1;
                }
            }
        }
    }

    Timer {
        id: resultsTimer
        // evaluate all via timer;
        interval: 500;
        repeat: true;
        running: false;

        onTriggered: {

            if (igcFilesModel.count <= 0) {
                running = false;

                // category results
                generateContinuousResults();

                // save changes to CSV
                writeScoreManulaValToCSV();

                // tucek and tucek-settings CSV
                writeCSV();

                return;
            }

            var current = -1;
            var item;
            var contestant;

            igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

            // select first item of list
            if (current < 0) {

                current = 0;
                igcFilesTable.selection.clear();
                igcFilesTable.selection.select(current);
                igcFilesTable.currentRow = current;

                // load contestant and igc row
                item = igcFilesModel.get(current);
                contestant = contestantsListModel.get(item.contestant);

                // create contestant html file
                results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
                                                            JSON.stringify(contestant),
                                                            JSON.stringify(item),
                                                            competitionConfiguretion.competitionName,
                                                            competitionConfiguretion.getCompetitionTypeString(parseInt(competitionConfiguretion.competitionType)),
                                                            competitionConfiguretion.competitionDirector,
                                                            competitionConfiguretion.competitionDirectorAvatar,
                                                            competitionConfiguretion.competitionArbitr,
                                                            competitionConfiguretion.competitionArbitrAvatar,
                                                            competitionConfiguretion.competitionDate);
            }
            else {

                // load contestant and igc row
                item = igcFilesModel.get(current);
                contestant = contestantsListModel.get(item.contestant);

                if (item.contestant === 0 || file_reader.file_exists(pathConfiguration.resultsFolder + "/"+ contestant.name + "_" + contestant.category + ".html"))  { //if results created or no results for this igc row
                    if (current+1 == igcFilesModel.count) { // finsihed

                        running = false;

                        // category results
                        generateContinuousResults();

                        // save changes to CSV
                        writeScoreManulaValToCSV();

                        // tucek and tucek-settings CSV
                        writeCSV();

                    } else { // go to next
                        igcFilesTable.selection.clear();
                        igcFilesTable.selection.select(current+1)
                        igcFilesTable.currentRow = current+1;


                        // load contestant and igc row
                        item = igcFilesModel.get(current + 1);
                        contestant = contestantsListModel.get(igcFilesModel.get(current + 1).contestant);

                        // create contestant html file
                        results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
                                                                    JSON.stringify(contestant),
                                                                    JSON.stringify(item),
                                                                    competitionConfiguretion.competitionName,
                                                                    competitionConfiguretion.getCompetitionTypeString(parseInt(competitionConfiguretion.competitionType)),
                                                                    competitionConfiguretion.competitionDirector,
                                                                    competitionConfiguretion.competitionDirectorAvatar,
                                                                    competitionConfiguretion.competitionArbitr,
                                                                    competitionConfiguretion.competitionArbitrAvatar,
                                                                    competitionConfiguretion.competitionDate);
                    }
                }
            }
        }
    }

    MessageDialog {
        id: errorMessage;
        icon: StandardIcon.Critical;
    }

    MessageDialog {
        id: contestnatsNotFoundMessage;
        icon: StandardIcon.Critical;

        standardButtons: StandardButton.Yes | StandardButton.Cancel

        onButtonClicked: {

            if (clickedButton == StandardButton.Yes) {

                visible = false;
                pathConfiguration.close();
                selectCompetitionOnlineDialog.show();
            }
            else {
                visible = false;
                pathConfiguration.close();
            }
        }
    }

    AboutDialog {
        id: aboutDialog
    }


    /// automaticke prirazeni logeru a jeho vyhodnoceni

    Timer {
        interval: 500;
        repeat: true;
        running: !evaluateTimer.running;
        onTriggered: {
            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.assignFile))) {
                var cnt = file_reader.read(Qt.resolvedUrl(pathConfiguration.assignFile));
                var assign = CSVJS.parseCSV(String(cnt))
                for (var line = 0; line < assign.length; line++) {
                    if (assign[line].length < 2) {
                        continue;
                    }

                    var filename = ''
                    if (assign[line].length >= 5) {
                        filename = assign[line][4]
                    }

                    var assignFullName = assign[line][2]; // choose first line, third item
                    if (assignFullName === "") {
                        continue;
                    }


                    var contestant_index = 0;

                    for (var i = 0; i < contestantsListModel.count; i++) {
                        var contestant = contestantsListModel.get(i);
                        if (contestant.fullName === assignFullName) {
                            contestant_index = i;
                        }
                    }
                    if (contestant_index <= 0) {
                        continue;
                    }

                    var igc_index = -1;

                    if (filename === "") {
                        for (var i = 0; i < igcFilesModel.count; i++) {
                            var item = igcFilesModel.get(i);
                            if (item.contestant === 0) {
                                igc_index = i;
                                break;
                            }
                        }
                    } else {
                        for (var i = 0; i < igcFilesModel.count; i++) {
                            var item = igcFilesModel.get(i);
                            if (item.fileName === filename) {
                                igc_index = i;
                                break;
                            }

                        }
                    }

                    if (igc_index < 0) {
                        continue;
                    }

                    console.log(igc_index + "   " + contestant_index);

                    igcFilesModel.setProperty(igc_index, "contestant", contestant_index)
                    igcFilesTable.selection.clear();
                    igcFilesTable.currentRow = igc_index;
                    igcFilesTable.selection.select(igc_index);


                }

                //                file_reader.write(Qt.resolvedUrl(pathConfiguration.assignFile), '');
                file_reader.delete_file(Qt.resolvedUrl(pathConfiguration.assignFile));


            }
        }
    }

    ConfigFile {
        id: config
    }


}
