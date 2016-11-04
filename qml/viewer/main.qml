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

    // Tohohle bychom se meli zbavit, humus
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

    onVisibleChanged: {

        if(visible) {
            startUpMessage.open();  // clean or reload prev settings
            //pathConfiguration.ok();
        }
    }

    menuBar: MenuBar {
        id: menuToolBar
        Menu {
            //% "&File"
            title: qsTrId("main-file-menu")

            MenuItem {
                //% "&Settings"
                text: qsTrId("main-file-menu-settings")
                onTriggered: {
                    pathConfiguration.show()
                }
                shortcut: "Ctrl+E"
            }
            MenuItem {
                //% "&Refresh application"
                text: qsTrId("main-file-menu-refresh-application")
                enabled: (pathConfiguration.selectedCompetition != "")
                onTriggered: {
                    selectCompetitionOnlineDialog.show();
                    selectCompetitionOnlineDialog.refreshApplications();
                    //reloadContestants(Qt.resolvedUrl(pathConfiguration.contestantsFile));
                    //refreshContestantsDialog.visible = true;
                }
                shortcut: "F5"//"Ctrl+W"
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
                shortcut: "Ctrl+C"
            }
            MenuItem {
                id: mainViewMenuCompetitionPropertyStatusBar
                //% "Competition property"
                text: qsTrId("main-view-menu-comp-property-sb")
                checkable: true;
                checked: true;
                shortcut: "Ctrl+P"
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

        onRefreshDataDownloaded: {

            //file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), csvString);

            //importDataDialog.listModel.clear();
            //initCategoryCounters();

            reloadContestants(csvString);
            selectCompetitionOnlineDialog.close();
            refreshContestantsDialog.show();

            //loadContestants(Qt.resolvedUrl(pathConfiguration.contestantsFile));
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

    RefreshContestantsDialog {

        id: refreshContestantsDialog

        onOk: {

            joinContestantsListModels();
            loadPrevResults();

            unmodifiedContestants.clear();
            updatedContestants.clear();
            addedContestants.clear();
            removedContestants.clear();

            // sort list model by startTime
            sortListModelByStartTime();

            // load prev results
            loadPrevResults();
        }

        onCancel: {

            unmodifiedContestants.clear();
            updatedContestants.clear();
            addedContestants.clear();
            removedContestants.clear();
        }

        // join
        function joinContestantsListModels() {

            contestantsListModel.clear();

            var i = 0;
            var item;

            for(i = 0; i < unmodifiedContestants.count; i++) {
                item = unmodifiedContestants.get(i);

                if (item.selected)
                    contestantsListModel.append(item);
            }

            for(i = 0; i < removedContestants.count; i++) {
                item = removedContestants.get(i);

                if (item.selected)
                    contestantsListModel.append(item);
            }

            for(i = 0; i < addedContestants.count; i++) {
                item = addedContestants.get(i);

                if (item.selected)
                    contestantsListModel.append(item);
            }

            for(i = 0; i < updatedContestants.count; i++) {
                item = updatedContestants.get(i);

                if (item.selected) {

                    if(item.nameSelector) item.name = item.newName;
                    if(item.speedSelector) item.speed = item.newSpeed;
                    if(item.categorySelector) item.category = item.newCategory;
                    if(item.startTimeSelector) item.startTime = item.newStartTime;
                    if(item.planeTypeSelector) item.aircraft_type = item.newAircraft_type;
                    if(item.planeRegSelector) item.aircraft_registration = item.newAircraft_registration;

                    contestantsListModel.append(item);
                }
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
                igcFolderModel.folder = pathConfiguration.tabView.pathTabAlias.igcDirectory;

                recalculateContestantsScoreOrder();

                storeTrackSettings(pathConfiguration.tsFile);
                map.requestUpdate();
            }
        }
    }


    function getContestantIndexByProperty(name, category, speed, planeType, planeRegistration) {

        for (var i = 0; i < contestantsListModel.count; i++) {

            var item = contestantsListModel.get(i);

            if(item.name === name && item.category === category && item.speed === speed && item.aircraft_type === planeType && item.aircraft_registration === planeRegistration) {
                return i;
            }
        }
        return 0;
    }

    CreateContestantDialog {

        id: createContestantDialog

        onOk: {

            // select new or updated contestant
            var index = getContestantIndexByProperty(name, category, speed, planeType, planeRegistration);

            contestantsTable.selection.clear();
            if (contestantsListModel.count > 0) {

                contestantsTable.selection.select(index);
                contestantsTable.currentRow = index;
            }
        }
    }

    CppWorker {

        id: cppWorker;
    }

    PathConfiguration {
        id: pathConfiguration;
        onOk: {

            // save downloaded applications
            if (contestantsDownloadedString !== "") {

                file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), contestantsDownloadedString);
            }

            // clear contestant in categories counters
            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile ))) {
                tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(pathConfiguration.trackFile )))
            } else {

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
                errorMessage.text = qsTrId("path-configuration-error-contestantsFile-not-found").arg(pathConfiguration.contestantsFile);
                errorMessage.open();
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

    IGCChooseDialog {
        id: igcChooseDialog
        datamodel: igcFolderModel
        cm: contestantsListModel
        onChoosenFilename: {

            contestantsListModel.changeLisModel(row, "filename", filename);
            contestantsListModel.changeLisModel(row, "classify", filename === "" ? -1 : contestantsListModel.get(row).prevResultsClassify);

            contestantsTable.selectRow(row);
        }
    }

    Menu {
        id: recalculateScoreMenu;

        property int selectedRow: -1

        MenuItem {
            //% "Recalculate"
            text: qsTrId("scorelist-table-menu-recalculate-score")
            onTriggered: { contestantsTable.recalculateResults(recalculateScoreMenu.selectedRow); }
        }

        MenuItem {
            //% "Generate contestant results"
            text: qsTrId("scorelist-table-menu-generate-contestant-results")
            onTriggered: { contestantsTable.generateResults(recalculateScoreMenu.selectedRow); }
        }
    }

    Menu {
        id: createContestantMenu;

        property bool menuVisible: false

        MenuItem {
            //% "Append contestant"
            text: qsTrId("scorelist-table-menu-append-contestant")

            onTriggered: {
                createContestantDialog.contestantsListModelRow = contestantsListModel.count;
                createContestantDialog.show();
            }
        }
    }

    Menu {
        id: updateContestantMenu;

        property int row: -1
        property bool menuVisible: false

        signal showMenu();

        onShowMenu: {

            if (row < 0) return;

            // dont popUp menu if igc file not exist - otherwise problem with focus when error dialog is opened
            var filePath = pathConfiguration.igcDirectory + "/" + contestantsListModel.get(row).filename;
            if (file_reader.file_exists(filePath)) {
                popup();
            }
        }

        onAboutToShow: {
            menuVisible = true;
        }
        onAboutToHide: {
            menuVisible = false;
        }

        MenuItem {
            //% "Edit contestant"
            text: qsTrId("scorelist-table-menu-edit-contestant")

            onTriggered: {
                createContestantDialog.contestantsListModelRow = updateContestantMenu.row;
                createContestantDialog.show();
            }
        }

        MenuItem {
            //% "Append contestant"
            text: qsTrId("scorelist-table-menu-append-contestant")

            onTriggered: {
                createContestantDialog.contestantsListModelRow = contestantsListModel.count;
                createContestantDialog.show();
            }
        }

        MenuItem {
            //% "Remove contestant"
            text: qsTrId("scorelist-table-menu-remove-contestant")

            onTriggered: {

                var conte = contestantsListModel.get(updateContestantMenu.row);

                // deselect row
                contestantsTable.selection.clear();

                // update category counters
                updateContestantInCategoryCounters(conte.category, false);

                // remove item from listmodel
                contestantsListModel.remove(updateContestantMenu.row, 1);

                // save results into CSV
                writeCSV();
                recalculateScoresTo1000();
                writeScoreManulaValToCSV();
            }
        }
    }

    ListModel {

        id: competitionClassModel

        ListElement { text: "-"}    // proc to tu je???
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

    ListModel {
        id: scoreListClassifyListModel

        ListElement { //% "yes"
            classify: qsTrId("scorelist-table-classify-yes") }
        ListElement { //% "no"
            classify: qsTrId("scorelist-table-classify-no") }
    }


    FolderListModel {
        id: igcFolderModel
        nameFilters: ["*.igc", "*.IGC"]
        showDirs: false
    }

    ListModel {
        id: contestantsListModel

        signal changeLisModel(int row, string role, variant value);

        onChangeLisModel: {

               //console.log("row: " + row + " role: " + role + " value: " + value + " count: " + contestantsListModel.count)

               if (row >= contestantsListModel.count || row < 0) {
                   console.log("WUT? row role value " +row + " " +role + " " +value)
                   return;
               }

               var prevRow = contestantsTable.selection.count === 1 ? contestantsTable.currentRow : -1;
               var prevItem = contestantsListModel.get(row);
               var prevCategory = prevItem.category;
               var prevName = prevItem.name;

               contestantsListModel.setProperty(row, role, value)
               var contestant = contestantsListModel.get(row);

               // init classify combobox for contestant
               if (parseInt(contestant.classify) === -1) {
                    contestantsListModel.setProperty(row, "classify", contestant.filename === "" ? -1 : contestant.prevResultsClassify);
               }

                if (role === "category") {

                    // change full name and reload item
                    contestantsListModel.setProperty(row, "fullName", contestant.name + "_" + contestant.category);
                    contestant = contestantsListModel.get(row);
                }
                if (role === "filename" || role === "speed" || role === "startTime" || role === "category") {

                    // load contestant category
                    for (var t = 0; t < tracks.tracks.length; t++) {

                        if (tracks.tracks[t].name === contestant.category)
                            trItem = tracks.tracks[t]
                    }

                // recalculate manual values score / markers, photos, ...
                if (contestant.filename !== "") recalculateContestnatManualScoreValues(row);

                    // reload update ctnt
                    contestant = contestantsListModel.get(row);

                    // no results for this values
                    if (contestant.filename === "" || !resultsValid(contestant.speed,
                                                                    contestant.startTime,
                                                                    contestant.category,
                                                                    contestant.filename,
                                                                    MD5.MD5(JSON.stringify(trItem)),
                                                                    contestant.prevResultsSpeed,
                                                                    contestant.prevResultsStartTime,
                                                                    contestant.prevResultsCategory,
                                                                    contestant.prevResultsFilename,
                                                                    contestant.prevResultsTrackHas)) {

                            contestantsListModel.setProperty(row, "score", "");        //compute new score
                            contestantsListModel.setProperty(row, "scorePoints", -1);
                            contestantsListModel.setProperty(row, "scorePoints1000", -1);
                            contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
                            contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
                            contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
                            contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
                            contestantsListModel.setProperty(row, "score_json", "");
                            contestantsListModel.setProperty(row, "trackHash", "");
                    }
                    // load prev results
                    else {

                        contestantsListModel.setProperty(row, "trackHash", contestant.prevResultsTrackHas);
                        contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
                        contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
                        contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
                        contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
                        contestantsListModel.setProperty(row, "score_json", contestant.prevResultsScoreJson)
                        contestantsListModel.setProperty(row, "score", contestant.prevResultsScore)
                        contestantsListModel.setProperty(row, "scorePoints", contestant.prevResultsScorePoints);
                    }
                }

                // change continuous results models
                if (role === "category") {

                    // decrease prev category counter
                    if (prevCategory !== "-" && value !== prevCategory) {
                        updateContestantInCategoryCounters(prevCategory, false);
                    }

                    // increase actual category counter
                    updateContestantInCategoryCounters(value, true);
                }

                if (role === "startTime") sortListModelByStartTime();

                // select row
                if (prevRow === row) {

                    contestantsTable.selection.clear();

                    for (var i = 0; i < contestantsListModel.count; i++) {
                        var ctIt = contestantsListModel.get(i);

                        // find and select current item (after sort)
                        if (ctIt.name === prevName && prevName !== undefined) {
                            row = i;
                            break;
                        }
                    }

                    contestantsTable.selection.select(row);
                    contestantsTable.currentRow = row;
                }

                // save results into CSV
                writeCSV();
                recalculateScoresTo1000();
                writeScoreManulaValToCSV();
        }
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
            var row = contestantsTable.currentRow;

            contestantsListModel.setProperty(row, "markersOk", curentContestant.markersOk);
            contestantsListModel.setProperty(row, "markersNok", curentContestant.markersNok);
            contestantsListModel.setProperty(row, "markersFalse", curentContestant.markersFalse);
            contestantsListModel.setProperty(row, "markersScore", curentContestant.markersScore);
            contestantsListModel.setProperty(row, "photosOk", curentContestant.photosOk);
            contestantsListModel.setProperty(row, "photosNok", curentContestant.photosNok);
            contestantsListModel.setProperty(row, "photosFalse", curentContestant.photosFalse);
            contestantsListModel.setProperty(row, "photosScore", curentContestant.photosScore);
            contestantsListModel.setProperty(row, "startTimeMeasured", curentContestant.startTimeMeasured);
            contestantsListModel.setProperty(row, "startTimeDifference", curentContestant.startTimeDifference);
            contestantsListModel.setProperty(row, "startTimeScore", curentContestant.startTimeScore);
            contestantsListModel.setProperty(row, "landingScore", curentContestant.landingScore);
            contestantsListModel.setProperty(row, "circlingCount", curentContestant.circlingCount);
            contestantsListModel.setProperty(row, "circlingScore", curentContestant.circlingScore);
            contestantsListModel.setProperty(row, "oppositeCount", curentContestant.oppositeCount);
            contestantsListModel.setProperty(row, "oppositeScore", curentContestant.oppositeScore);
            contestantsListModel.setProperty(row, "otherPoints", curentContestant.otherPoints);
            contestantsListModel.setProperty(row, "otherPointsNote", curentContestant.otherPointsNote);
            contestantsListModel.setProperty(row, "otherPenalty", curentContestant.otherPenalty);
            contestantsListModel.setProperty(row, "otherPenaltyNote", curentContestant.otherPenaltyNote);

            // reload current contestant
            ctnt = contestantsListModel.get(row);

            // load and save modified score lists
            contestantsListModel.setProperty(row, "wptScoreDetails", resultsWindow.currentWptScoreString);

            contestantsListModel.setProperty(row, "speedSectionsScoreDetails", resultsWindow.currentSpeedSectionsScoreString);
            contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", resultsWindow.currentAltitudeSectionsScoreString);
            contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", resultsWindow.currentSpaceSectionsScoreString);

            // recalculate score
            var score = getTotalScore(row);
            contestantsListModel.setProperty(row, "scorePoints", score);
            recalculateScoresTo1000();

            // save changes into CSV
            writeScoreManulaValToCSV();
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

            signal selectRow(int row);
            signal generateResults(int row);
            signal recalculateResults(int row);

            onRecalculateResults: {

                contestantsListModel.setProperty(row, "score", "");        //compute new score
                contestantsListModel.setProperty(row, "scorePoints", -1);
                contestantsListModel.setProperty(row, "scorePoints1000", -1);

                contestantsTable.selectRow(row);
            }

            onGenerateResults: {

                contestantsTable.selection.clear();
                contestantsTable.selection.select(row);
                contestantsTable.currentRow = row;

                var contestant = contestantsListModel.get(row);

                // create contestant html file
                results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
                                                                            JSON.stringify(contestant),
                                                                            pathConfiguration.competitionName,
                                                                            pathConfiguration.getCompetitionTypeString(parseInt(pathConfiguration.competitionType)),
                                                                            pathConfiguration.competitionDirector,
                                                                            pathConfiguration.competitionDirectorAvatar,
                                                                            pathConfiguration.competitionArbitr,
                                                                            pathConfiguration.competitionArbitrAvatar,
                                                                            pathConfiguration.competitionDate);
            }

            onSelectRow: {

                contestantsTable.selection.clear();
                contestantsTable.selection.select(row);
                contestantsTable.currentRow = row;
            }

            itemDelegate: ContestantsDelegate {

                id: contestantsTableDelegate

                onSelectRow: {

                    contestantsTable.selectRow(row);
                }

                onChangeModel: {

                    contestantsListModel.changeLisModel(row, role, value);
                }

                onShowResults: {

                    // load contestant property
                    ctnt = contestantsListModel.get(row);

                    // TODO - prasarna aby byla kopie a ne stejny objekt
                    resultsWindow.curentContestant = JSON.parse(JSON.stringify(ctnt));

                    // load contestant score list
                    resultsWindow.wptScore = ctnt.wptScoreDetails;

                    // load sections string
                    resultsWindow.speedSections = ctnt.speedSectionsScoreDetails;
                    resultsWindow.altSections = ctnt.altitudeSectionsScoreDetails;
                    resultsWindow.spaceSections = ctnt.spaceSectionsScoreDetails;

                    // load cattegory property
                    var arr = tracks.tracks;
                    var currentTrck;

                    var found = false;
                    resultsWindow.time_window_penalty = 0;
                    resultsWindow.time_window_size = 0;
                    resultsWindow.photos_max_score = 0;
                    resultsWindow.oposite_direction_penalty = 0;
                    resultsWindow.marker_max_score = 0;
                    resultsWindow.gyre_penalty = 0;

                    for (var i = 0; i < arr.length; i++) {
                        currentTrck = arr[i];

                        if (currentTrck.name === ctnt.category) {

                            resultsWindow.time_window_penalty = currentTrck.time_window_penalty; //penalty percent
                            resultsWindow.time_window_size = currentTrck.time_window_size;
                            resultsWindow.photos_max_score = currentTrck.photos_max_score;
                            resultsWindow.oposite_direction_penalty = currentTrck.oposite_direction_penalty; //penalty percent
                            resultsWindow.marker_max_score = currentTrck.marker_max_score;
                            resultsWindow.gyre_penalty = currentTrck.gyre_penalty; //penalty percent
                            break;
                        }
                    }

                    // select row
                    contestantsTable.selectRow(row);

                    resultsWindow.show();

                }
            }


            rowDelegate: Rectangle {
                height: 30;
                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {

                        var row = isNaN(parseInt(styleData.row)) ? -1 : parseInt(styleData.row);

                        // create new contestant
                        if (mouse.button === Qt.RightButton) {

                            createContestantMenu.popup();
                        }
                        else {
                            if (row >= 0 && row < contestantsListModel.count) {
                                contestantsTable.selectRow(row);
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                selection.selectionChanged.connect(rowSelected);
            }

            function rowSelected() {

                //  console.log("row selected")

                if (contestantsListModel.count <= 0) {
                    return;
                }

                var current = -1;

                contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

                if (current < 0) {
                    return;
                }

                ctnt = contestantsListModel.get(current)

                var arr = tracks.tracks;

                var found = false;
                for (var i = 0; i < arr.length; i++) {
                    trItem = arr[i];

                    if (trItem.name === ctnt.category) {
                        map.filterCupCategory = i;
                        map.filterCupData = 2;
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    map.filterCupData = 3
                    console.log("ctnt.category \"" + ctnt.category + "\" not found in track!")
                }

                //                console.log("setFilter" + ctnt.startTime)
                tool_bar.startTime = ctnt.startTime

                var filePath = pathConfiguration.igcDirectory + "/" + ctnt.filename;
                if (!file_reader.file_exists(filePath)) {
                    //% "File \"%1\" not found"
                    errorMessage.text = qsTrId("contestant-table-row-selected-file-not-found").arg(filePath)
                    errorMessage.open();
                }

                // remove suffix file:///
                igc.load( filePath.substring(8), ctnt.startTime)
                map.requestUpdate()
                altChart.igcUpdate();
            }

            TableViewColumn {
                //% "Contestant"
                title: qsTrId("filelist-table-contestants")
                role: "name"
            }

            TableViewColumn {
                //% "File name"
                title: qsTrId("filelist-table-filename")
                role: "filename";
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

            Rectangle { // disable
                color: "#ffffff";
                opacity: 0.7;
                anchors.fill: parent;
                visible: evaluateTimer.running || resultsTimer.running;
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {

                        if (evaluateTimer.running) {

                            console.log("onClick is disabled when evaluateTimer.running");
                            evaluateTimer.running = false;
                        }
                        else if (resultsTimer.running) {

                            console.log("onClick is disabled when resultsTimer.running");
                            resultsTimer.running = false;
                        }
                    }
                }
            }
        }

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

                    if (!updateContestantMenu.menuVisible) {
                        computeScore(tpi, polys)
                    }
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
                contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )
                if (current < 0) {
                    return;
                }

                var con = contestantsListModel.get(current);
                if (con.filename === "") {
                    printMapWindow.visible = false;
                    return;
                }

                imageSaver.save(printMap, Qt.resolvedUrl(pathConfiguration.resultsFolder+"/"+con.fullName+".png"))
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

                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: pathConfiguration.competitionName }
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-type") + ": " + pathConfiguration.competitionTypeText}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-director") + ": " +  pathConfiguration.competitionDirector}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-arbitr") + ": " +  pathConfiguration.competitionArbitr.join(", ")}
                NativeText {/* width: applicationWindow.width/statusBarCompetitionProperty.columns; */text: qsTrId("html-results-competition-date") + ": " +  pathConfiguration.competitionDate}
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
    function resultsValid(currentSpeed, currentStartTime, currentCategory, currentIgcFilename, currentTrackHash,
                          prevSpeed, prevStartTime, prevCategory, prevIgcFilename, prevTrackHash) {

        /*console.log("resultsValid: " + currentSpeed + "/" + prevSpeed + "   " +
                                       currentStartTime  + "/" + prevStartTime + "   " +
                                       currentCategory  + "/" +  prevCategory + "   " +
                                       currentIgcFileName  + "/" +  prevIgcFileName + "   " +
                                       currentTrackHash  + "/" + prevTrackHash)
                                       */

        return (currentStartTime === prevStartTime &&
                parseInt(currentSpeed) === parseInt(prevSpeed) &&
                currentCategory === prevCategory &&
                currentIgcFilename === prevIgcFilename &&
                currentTrackHash === prevTrackHash);

    }

    // Sort list model by start time
    function sortListModelByStartTime() {

        for (var i = 0; i < contestantsListModel.count - 1; i++) {
            for (var j = 0; j < contestantsListModel.count - i - 1; j++) {

                var item_j = contestantsListModel.get(j)
                var item_j1 = contestantsListModel.get(j + 1)

                var item_j_timeVal = item_j.startTime === "" || item_j.startTime === "00:00:00" ? F.timeToUnix("23:59:59") + 1 : F.timeToUnix(item_j.startTime);
                var item_j1_timeVal = item_j1.startTime === "" || item_j1.startTime === "00:00:00" ? F.timeToUnix("23:59:59") + 1 : F.timeToUnix(item_j1.startTime);

                if(item_j_timeVal > item_j1_timeVal){

                    contestantsListModel.move(j, j + 1, 1);
                }
            }
        }
    }

    // function return contestant template struct
    function createBlankUserObject() {

        var user = {
            "name": "",
            "category": "",
            "currentCategory": "",
            "fullName": "" + "_" + "",
            "startTime": "",
            "currentStartTime": "",
            "filename": "",
            "speed": -1,
            "currentSpeed": -1,
            "aircraft_type": "",
            "aircraft_registration": "",
            "crew_id": "",
            "pilot_id": "",
            "copilot_id": "",
            "pilotAvatarBase64": "",
            "copilotAvatarBase64": "",
            "markersOk": 0,
            "markersNok": 0,
            "markersFalse": 0,
            "markersScore": 0,
            "photosOk": 0,
            "photosNok": 0,
            "photosFalse": 0,
            "photosScore": 0,
            "startTimeMeasured": "",
            "startTimeDifference": "",
            "startTimeScore": 0,
            "landingScore": 0,
            "circlingCount": 0,
            "circlingScore": 0,
            "oppositeCount": 0,
            "oppositeScore": 0,
            "otherPoints": 0,
            "otherPointsNote": "",
            "otherPenalty": 0,
            "otherPenaltyNote": "",
            "prevResultsSpeed": -1,
            "prevResultsStartTime": "",
            "prevResultsCategory": "",
            "prevResultsWPT": "",
            "prevResultsSpeedSec": "",
            "prevResultsAltSec": "",
            "prevResultsSpaceSec": "",
            "prevResultsTrackHas": "",
            "prevResultsFilename": "",
            "prevResultsScorePoints": -1,
            "prevResultsScore": "",
            "prevResultsScoreJson": "",
            "prevResultsClassify": 0,

            // items from igc files model
            "filePath": "",
            "score": "",
            "score_json": "",
            "scorePoints" : -1,
            "scorePoints1000" : -1,
            "classify" : -1,
            "wptScoreDetails" : "",
            "trackHash": "",
            "speedSectionsScoreDetails" : "",
            "spaceSectionsScoreDetails" : "",
            "altitudeSectionsScoreDetails" : "",
            "classOrder": -1,

            "newName": "",
            "newCategory": "",
            "newStartTime": "",
            "newSpeed": -1,
            "newAircraft_type": "",
            "newAircraft_registration": "",

            "selected": 1,
            "nameSelector": 1,
            "speedSelector": 1,
            "categorySelector": 1,
            "startTimeSelector": 1,
            "planeTypeSelector": 1,
            "planeRegSelector": 1,

        }

        return user;
    }


    // Load contestants from CSV
    function loadContestants(filename) {

        contestantsTable.selection.clear();

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
            data = CSVJS.parseCSV(String(f_data));
        }


        contestantsListModel.clear()

        for (var i = 0; i < data.length; i++) {

            var item = data[i];
            var itemName = item[0]
            var j;

            // CSV soubor ma alespon 3 Sloupce
            if ((item.length > 2) && (itemName.length > 0)) {


                // Find contestant by id in prev results (first row is the header)
                for (j = 1; j < resultsCSV.length; j++) {

                    if (parseInt(resultsCSV[j][28]) === parseInt(item[9])) {
                        index = j;
                        break;
                    }
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

                // create blank user
                var new_contestant = createBlankUserObject();

                // fill user params
                new_contestant.name = itemName;
                new_contestant.category = item[1];
                new_contestant.fullName = item[2];
                new_contestant.startTime = item[3];
                new_contestant.filename = (csvFileFromViewer && item[4] === "" ? resultsCSV[j][38] : item[4]);
                new_contestant.speed = parseInt(item[5]);
                new_contestant.currentCategory = (currentContValuesIndex === -1 ? "" : currentConteCategories[currentContValuesIndex]);
                new_contestant.currentStartTime = (currentContValuesIndex === -1 ? "" : currentConteStartTimes[currentContValuesIndex]);
                new_contestant.currentSpeed = (currentContValuesIndex === -1 ? -1 : currentConteSpeed[currentContValuesIndex]);
                new_contestant.aircraft_type = item[6];
                new_contestant.aircraft_registration = item[7];
                new_contestant.crew_id = item[8];
                new_contestant.pilot_id = item[9];
                new_contestant.copilot_id = item[10];
                new_contestant.pilotAvatarBase64 = (item.length >= 13 ? (item[11]) : "");
                new_contestant.copilotAvatarBase64 = (item.length >= 13 ? (item[12]) : "");
                new_contestant.markersOk = (csvFileFromOffice ? parseInt(resultsCSV[j][1]) : 0);
                new_contestant.markersNok = (csvFileFromOffice ? parseInt(resultsCSV[j][2]) : 0);
                new_contestant.markersFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][3]) : 0);
                new_contestant.markersScore = (csvFileFromViewer ? parseInt(resultsCSV[j][41]) : 0);
                new_contestant.photosOk = (csvFileFromOffice ? parseInt(resultsCSV[j][4]) : 0);
                new_contestant.photosNok = (csvFileFromOffice ? parseInt(resultsCSV[j][5]) : 0);
                new_contestant.photosFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][6]) : 0);
                new_contestant.photosScore = (csvFileFromViewer ? parseInt(resultsCSV[j][42]) : 0);
                new_contestant.startTimeMeasured = (csvFileFromOffice ? resultsCSV[j][11] : "");
                new_contestant.startTimeDifference = (csvFileFromOffice ? resultsCSV[j][43] : "");
                new_contestant.startTimeScore = (csvFileFromOffice ? parseInt(resultsCSV[j][12]) * -1 : 0);
                new_contestant.landingScore = (csvFileFromOffice ? parseInt(resultsCSV[j][7]) : 0);

                new_contestant.circlingCount = (csvFileFromViewer ? parseInt(resultsCSV[j][44]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][13])));
                new_contestant.circlingScore = (csvFileFromViewer ? parseInt(resultsCSV[j][45]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][14] * -1)));
                new_contestant.oppositeCount = (csvFileFromViewer ? parseInt(resultsCSV[j][46]) : 0);
                new_contestant.oppositeScore = (csvFileFromViewer ? parseInt(resultsCSV[j][47]) : 0);

                new_contestant.otherPoints = (csvFileFromOffice ? parseInt(resultsCSV[j][8]) : 0);
                new_contestant.otherPointsNote = (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[0]) : "");
                new_contestant.otherPenalty = (csvFileFromOffice ? parseInt(resultsCSV[j][15]) : 0);
                new_contestant.otherPenaltyNote = (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[1]) : "");
                new_contestant.prevResultsSpeed = (csvFileFromViewer ? parseInt(resultsCSV[j][31]) : -1);
                new_contestant.prevResultsStartTime = (csvFileFromViewer ? resultsCSV[j][32] : "");
                new_contestant.prevResultsCategory = (csvFileFromViewer ? resultsCSV[j][33] : "");
                new_contestant.prevResultsWPT = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][34]) : "");
                new_contestant.prevResultsSpeedSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][35]) : "");
                new_contestant.prevResultsAltSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][37]) : "");
                new_contestant.prevResultsSpaceSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][36]) : "");
                new_contestant.prevResultsTrackHas = (csvFileFromViewer ? resultsCSV[j][30] : "");
                new_contestant.prevResultsFilename = (csvFileFromViewer ? resultsCSV[j][38] : "");
                new_contestant.prevResultsScorePoints = (csvFileFromOffice ? parseInt(resultsCSV[j][17]) : -1);
                new_contestant.prevResultsScore = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][39]) : "");
                new_contestant.prevResultsScoreJson = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][40]) : "");
                new_contestant.prevResultsClassify = (csvFileFromOffice ? (resultsCSV[j][19] === "yes" ? 0 : 1) : 0);

                // append into list model
                contestantsListModel.append(new_contestant);
            }
        }

        // sort list model by startTime
        sortListModelByStartTime();
    }

    ListModel {
        id: updatedContestants

        property int selected: 0
        property bool selectedAll: false
        property bool readOnly: false // import dialog - editable/noneditable delegate

        onCountChanged: {
            selected = getSelectedCrewsCount(updatedContestants);
            selectedAll = selected === count
        }
        onDataChanged: {

            selected = getSelectedCrewsCount(updatedContestants);
            selectedAll = selected === count
        }
    }

    ListModel {
        id: unmodifiedContestants

        property int selected: 0
        property bool selectedAll: false
        property bool readOnly: true // import dialog - editable/noneditable delegate

        onCountChanged: {
            selected = getSelectedCrewsCount(unmodifiedContestants);
            selectedAll = selected === count
        }
        onDataChanged: {

            selected = getSelectedCrewsCount(unmodifiedContestants);
            selectedAll = selected === count
        }
    }

    ListModel {
        id: removedContestants

        property int selected: 0
        property bool selectedAll: false
        property bool readOnly: true // import dialog - editable/noneditable delegate

        onCountChanged: {
            selected = getSelectedCrewsCount(removedContestants);
            selectedAll = selected === count
        }
        onDataChanged: {

            selected = getSelectedCrewsCount(removedContestants);
            selectedAll = selected === count
        }
    }

    ListModel {
        id: addedContestants

        property int selected: 0
        property bool selectedAll: false
        property bool readOnly: true // import dialog - editable/noneditable delegate

        onCountChanged: {
            selected = getSelectedCrewsCount(addedContestants);
            selectedAll = selected === count
        }
        onDataChanged: {

            selected = getSelectedCrewsCount(addedContestants);
            selectedAll = selected === count
        }
    }

    ListModel {
        id: currentContestantsLocalCopy
    }

    function getSelectedCrewsCount(model) {

        var s = 0;
        for(var i = 0; i < model.count; i++) {
            if (model.get(i).selected)
                s++;
        }

        return s;
    }

    // Load contestants from CSV
    function reloadContestants(f_data) {

        contestantsTable.selection.clear();

        // copy current contestnats listmodel into local cache
        currentContestantsLocalCopy.clear();
        for(var i = 0; i < contestantsListModel.count; i++) {
            currentContestantsLocalCopy.append(contestantsListModel.get(i))
        }

        // clear import models
        updatedContestants.clear();
        unmodifiedContestants.clear();
        removedContestants.clear();
        addedContestants.clear();

        //var f_data = file_reader.read(filename);
        var data = [];
        var resCSV = [];

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
            data = CSVJS.parseCSV(String(f_data));
        }


        // iterate through new data
        // exists in new and current > remove from both, add to updated/unmodified crew
        // exists only in new        > remove from new, add to removed crew
        // exists only in current    > rest of the current on the end of this loop, add to added
        while (data.length > 0) {

            var item = data[0];
            var itemName = item[0]
            var index = -1;

            // CSV soubor ma alespon 3 Sloupce
            if ((item.length > 2) && (itemName.length > 0)) {

                // exists in current model?
                for(var i = 0; i < currentContestantsLocalCopy.count; i++) {

                    if(parseInt(currentContestantsLocalCopy.get(i).crew_id) === parseInt(item[8])) {
                        index = i;
                        break;
                    }
                }

                // this crew is new
                if (index === -1) {

                    // create blank user
                    var new_contestant = createBlankUserObject();

                    // fill user params
                    new_contestant.name = itemName;
                    new_contestant.category = item[1];
                    new_contestant.fullName = item[2];
                    new_contestant.startTime = item[3];
                    new_contestant.filename = item[4];
                    new_contestant.speed = parseInt(item[5]);
                    new_contestant.currentCategory = "";
                    new_contestant.currentStartTime = "";
                    new_contestant.currentSpeed = -1;
                    new_contestant.aircraft_type = item[6];
                    new_contestant.aircraft_registration = item[7];
                    new_contestant.crew_id = item[8];
                    new_contestant.pilot_id = item[9];
                    new_contestant.copilot_id = item[10];
                    new_contestant.pilotAvatarBase64 = (item.length >= 13 ? (item[11]) : "");
                    new_contestant.copilotAvatarBase64 = (item.length >= 13 ? (item[12]) : "");

                    // append into list model
                    removedContestants.append(new_contestant);
                }
                // updated crew
                else {

                    var currentCrew = currentContestantsLocalCopy.get(index);

                    // save new values
                    currentCrew.newName = itemName;
                    currentCrew.newCategory = item[1];
                    currentCrew.newStartTime = item[3];
                    currentCrew.newSpeed = parseInt(item[5]);
                    currentCrew.newAircraft_type = item[6];
                    currentCrew.newAircraft_registration = item[7];
                    currentCrew.pilot_id = item[9];
                    currentCrew.copilot_id = item[10];

                    // add modified crew into updated list model
                    if (currentCrew.name !== currentCrew.newName ||
                        currentCrew.category !== currentCrew.newCategory ||
                        currentCrew.startTime !== currentCrew.newStartTime ||
                        currentCrew.speed !== currentCrew.newSpeed ||
                        currentCrew.aircraft_type !== currentCrew.newAircraft_type ||
                        currentCrew.aircraft_registration !== currentCrew.newAircraft_registration) {

                        updatedContestants.append(currentCrew);
                    }
                    // add unmodified crew into not modified list model
                    else {

                        unmodifiedContestants.append(currentCrew);
                    }

                    currentContestantsLocalCopy.remove(i); // remove ct from current list model
                }

                data.shift();                   // remove first item
            }
        }

        // these crews exists only in current listmodel
        for (var i = 0; i < currentContestantsLocalCopy.count; i++) {

            addedContestants.append(currentContestantsLocalCopy.get(i));
            currentContestantsLocalCopy.remove(i); // remove ct from current list model
        }
    }


    // function iterate through results file and load valid results
    function loadPrevResults() {

        // load results.csv
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

        // Iterate through old results
        for (var j = 1; j < resultsCSV.length; j++) {

            var pilotID_resCSV = isNaN(parseInt(resultsCSV[j][28])) ? -1 : parseInt(resultsCSV[j][28]);
            var pilotName_resCSV = resultsCSV[j][0];
            var curCnt;
            var i;

            // Find contestant for this result
            for (i = 0; i < contestantsListModel.count; i++) {

                curCnt = contestantsListModel.get(i);

                if(pilotID_resCSV !== -1) { // search by id
                    if (pilotID_resCSV === parseInt(curCnt.pilot_id)) {
                        index = j;
                        break;
                    }
                }
                else { // locally added crew - search by name (id should by -1)

                    if (pilotName_resCSV === curCnt.name && pilotID_resCSV === -1) {
                        index = j;
                        break;
                    }
                }
            }

            // contestant found?
            if(index !== -1) {

                // load contestant category
                for (var t = 0; t < tracks.tracks.length; t++) {

                    if (tracks.tracks[t].name === curCnt.category)
                        trItem = tracks.tracks[t]
                }

                // check previous results state
                var csvFileFromOffice = resultsCSV[j] !== undefined && resultsCSV[j].length >= 30; // CSV from office has only 30 columns;
                var csvFileFromViewer = resultsCSV[j] !== undefined && resultsCSV[j].length >= 48; // CSV from viewer has more then 48 columns;

                curCnt.prevResultsSpeed = (csvFileFromViewer ? parseInt(resultsCSV[j][31]) : -1);
                curCnt.prevResultsStartTime = (csvFileFromViewer ? resultsCSV[j][32] : "");
                curCnt.prevResultsCategory = (csvFileFromViewer ? resultsCSV[j][33] : "");
                curCnt.prevResultsFilename = (csvFileFromViewer ? resultsCSV[j][38] : "");
                curCnt.prevResultsTrackHas = (csvFileFromViewer ? resultsCSV[j][30] : "");

                // check results validity due to the contestant values
                if (resultsValid(curCnt.speed, curCnt.startTime, curCnt.category, curCnt.filename, MD5.MD5(JSON.stringify(trItem)),
                                 curCnt.prevResultsSpeed, curCnt.prevResultsStartTime, curCnt.prevResultsCategory, curCnt.prevResultsFilename, curCnt.prevResultsTrackHas)) {

                    curCnt.markersOk = (csvFileFromOffice ? parseInt(resultsCSV[j][1]) : 0);
                    curCnt.markersNok = (csvFileFromOffice ? parseInt(resultsCSV[j][2]) : 0);
                    curCnt.markersFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][3]) : 0);
                    curCnt.markersScore = (csvFileFromViewer ? parseInt(resultsCSV[j][41]) : 0);
                    curCnt.photosOk = (csvFileFromOffice ? parseInt(resultsCSV[j][4]) : 0);
                    curCnt.photosNok = (csvFileFromOffice ? parseInt(resultsCSV[j][5]) : 0);
                    curCnt.photosFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][6]) : 0);
                    curCnt.photosScore = (csvFileFromViewer ? parseInt(resultsCSV[j][42]) : 0);
                    curCnt.startTimeMeasured = (csvFileFromOffice ? resultsCSV[j][11] : "");
                    curCnt.startTimeDifference = (csvFileFromOffice ? resultsCSV[j][43] : "");
                    curCnt.startTimeScore = (csvFileFromOffice ? parseInt(resultsCSV[j][12]) * -1 : 0);
                    curCnt.landingScore = (csvFileFromOffice ? parseInt(resultsCSV[j][7]) : 0);

                    curCnt.circlingCount = (csvFileFromViewer ? parseInt(resultsCSV[j][44]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][13])));
                    curCnt.circlingScore = (csvFileFromViewer ? parseInt(resultsCSV[j][45]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][14] * -1)));
                    curCnt.oppositeCount = (csvFileFromViewer ? parseInt(resultsCSV[j][46]) : 0);
                    curCnt.oppositeScore = (csvFileFromViewer ? parseInt(resultsCSV[j][47]) : 0);

                    curCnt.otherPoints = (csvFileFromOffice ? parseInt(resultsCSV[j][8]) : 0);
                    curCnt.otherPointsNote = (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[0]) : "");
                    curCnt.otherPenalty = (csvFileFromOffice ? parseInt(resultsCSV[j][15]) : 0);
                    curCnt.otherPenaltyNote = (csvFileFromOffice ? String((resultsCSV[j][20]).split("/&/")[1]) : "");
                    curCnt.prevResultsSpeed = (csvFileFromViewer ? parseInt(resultsCSV[j][31]) : -1);
                    curCnt.prevResultsStartTime = (csvFileFromViewer ? resultsCSV[j][32] : "");
                    curCnt.prevResultsCategory = (csvFileFromViewer ? resultsCSV[j][33] : "");
                    curCnt.prevResultsWPT = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][34]) : "");
                    curCnt.prevResultsSpeedSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][35]) : "");
                    curCnt.prevResultsAltSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][37]) : "");
                    curCnt.prevResultsSpaceSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][36]) : "");
                    curCnt.prevResultsTrackHas = (csvFileFromViewer ? resultsCSV[j][30] : "");
                    curCnt.prevResultsFilename = (csvFileFromViewer ? resultsCSV[j][38] : "");
                    curCnt.prevResultsScorePoints = (csvFileFromOffice ? parseInt(resultsCSV[j][17]) : -1);
                    curCnt.prevResultsScore = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][39]) : "");
                    curCnt.prevResultsScoreJson = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][40]) : "");
                    curCnt.prevResultsClassify = (csvFileFromOffice ? (resultsCSV[j][19] === "yes" ? 0 : 1) : 0);

                    // save changes
                    contestantsListModel.set(i, curCnt);
                }
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
                if (!resultsValid(curCnt.speed, curCnt.startTime, curCnt.category, curCnt.filename, MD5.MD5(JSON.stringify(trItem)),
                                  curCnt.prevResultsSpeed, curCnt.prevResultsStartTime, curCnt.prevResultsCategory, curCnt.prevResultsFilename, curCnt.prevResultsTrackHas)) {

                    contestantsListModel.setProperty(i, "markersScore", 0);
                    contestantsListModel.setProperty(i, "photosScore", 0);
                    contestantsListModel.setProperty(i, "circlingScore", 0);
                    contestantsListModel.setProperty(i, "oppositeScore", 0);
                    contestantsListModel.setProperty(i, "startTimeScore", 0);
                    contestantsListModel.setProperty(i, "prevResultsSpeed", -1);
                    contestantsListModel.setProperty(i, "prevResultsStartTime", "");
                    contestantsListModel.setProperty(i, "prevResultsCategory", "");
                    contestantsListModel.setProperty(i, "prevResultsTrackHas", "");
                    contestantsListModel.setProperty(i, "prevResultsFilename", "");
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
        var resultsFilename = "res";

        var recSize = 8;

        var reStringArr = [];
        for (var key in res) {
            reStringArr.push(JSON.stringify(res[key]));
        }

        // HTML
        results_creator.createContinuousResultsHTML(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + resultsFilename,
                                                            reStringArr,
                                                            recSize,
                                                            pathConfiguration.competitionName,
                                                            pathConfiguration.getCompetitionTypeString(pathConfiguration.competitionType),
                                                            pathConfiguration.competitionDirector,
                                                            pathConfiguration.competitionDirectorAvatar,
                                                            pathConfiguration.competitionArbitr,
                                                            pathConfiguration.competitionArbitrAvatar,
                                                            pathConfiguration.competitionDate);

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

        file_reader.write(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + resultsFilename + ".csv"), csvString);
    }


    // DEBUG func
    function listProperty(item)
    {
        for (var p in item)
            console.log(p + ": " + item[p]);
    }

    function getAltitudeAndSpaceSectionsPenaltyPoints(igcRow, totalPoints) {

        var ctItem = contestantsListModel.get(igcRow);
        var item;
        var i;
        var arr = [];

        // altitude
        if (ctItem.altitudeSectionsScoreDetails !== "") {

            altSectionsScoreListManualValuesCache.clear();
            arr = ctItem.altitudeSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                altSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            arr = [];

            for (i = 0; i < altSectionsScoreListManualValuesCache.count; i++) {
                item = altSectionsScoreListManualValuesCache.get(i)
                item.altSecScore = getAltSecScore(item.manualAltMinEntriesCount, item.altMinEntriesCount, item.manualAltMaxEntriesCount, item.altMaxEntriesCount, item.penaltyPercent, totalPoints);

                arr.push(JSON.stringify(item));
            }

            contestantsListModel.setProperty(igcRow, "altitudeSectionsScoreDetails", arr.join("; "));
            altSectionsScoreListManualValuesCache.clear();
        }

        // space
        if (ctItem.spaceSectionsScoreDetails !== "") {

            spaceSectionsScoreListManualValuesCache.clear();
            arr = ctItem.spaceSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                spaceSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            arr = [];

            for (i = 0; i < spaceSectionsScoreListManualValuesCache.count; i++) {
                item = spaceSectionsScoreListManualValuesCache.get(i)
                item.spaceSecScore = getSpaceSecScore(item.manualEntries_out, item.entries_out, item.penaltyPercent, totalPoints);

                arr.push(JSON.stringify(item));
            }

            contestantsListModel.setProperty(igcRow, "spaceSectionsScoreDetails", arr.join("; "));
            spaceSectionsScoreListManualValuesCache.clear();
        }
    }

    // get points sum from sections and gates
    function getScorePointsSum(row) {

        var sum = 0;
        var p;
        var modelItem;

        var contestant = contestantsListModel.get(row);

        if (contestant === undefined) return 0;

        // get score points from gates
        if (contestant.wptScoreDetails !== "") {

            wptNewScoreListManualValuesCache.clear();
            var arr = contestant.wptScoreDetails.split("; ")

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
        if (contestant.speedSectionsScoreDetails !== "") {

            speedSectionsScoreListManualValuesCache.clear();
            arr = contestant.speedSectionsScoreDetails.split("; ")
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
    function getTotalScore(row) {

        var contestant = contestantsListModel.get(row);

        // get score points sum
        var scorePoints = getScorePointsSum(row);

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
        if (contestant.altitudeSectionsScoreDetails !== "") {

            altSectionsScoreListManualValuesCache.clear();
            arr = contestant.altitudeSectionsScoreDetails.split("; ")
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
        if (contestant.spaceSectionsScoreDetails !== "") {

            spaceSectionsScoreListManualValuesCache.clear();
            arr = contestant.spaceSectionsScoreDetails.split("; ")
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
    function recalculateContestnatManualScoreValues(row) {

        ctnt = contestantsListModel.get(row);

        //calc contestant manual values score - markers, photos,..
        ctnt.markersScore = getMarkersScore(ctnt.markersOk, ctnt.markersNok, ctnt.markersFalse, trItem.marker_max_score);
        ctnt.photosScore = getPhotosScore(ctnt.photosOk, ctnt.photosNok, ctnt.photosFalse, trItem.photos_max_score);

        var totalPointsScore = getScorePointsSum(row);

        ctnt.startTimeScore = getTakeOffScore(ctnt.startTimeDifference, trItem.time_window_size, trItem.time_window_penalty, totalPointsScore);
        ctnt.circlingScore = getGyreScore(ctnt.circlingCount, trItem.gyre_penalty, totalPointsScore);
        ctnt.oppositeScore = getOppositeDirScore(ctnt.oppositeCount, trItem.oposite_direction_penalty, totalPointsScore);

        getAltitudeAndSpaceSectionsPenaltyPoints(row, totalPointsScore);

        // save changes into contestnat list model
        contestantsListModel.setProperty(row, "markersScore", ctnt.markersScore);
        contestantsListModel.setProperty(row, "photosScore", ctnt.photosScore);
        contestantsListModel.setProperty(row, "startTimeScore", ctnt.startTimeScore);
        contestantsListModel.setProperty(row, "circlingScore", ctnt.circlingScore);
        contestantsListModel.setProperty(row, "oppositeScore", ctnt.oppositeScore);

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

        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i)

            if (maxPointsArr[item.category] < item.scorePoints && !item.classify) {
                maxPointsArr[item.category] = item.scorePoints;
            }
        }


        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i)

            // classify set as NO
            if (item.classify) {
                contestantsListModel.setProperty(i, "scorePoints1000", -1);
                continue;
            }

            if (item.scorePoints >= 0) {
                contestantsListModel.setProperty(i, "scorePoints1000", Math.round(item.scorePoints/maxPointsArr[item.category] * 1000));
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

        var item;
        var i;

        // clear score array
        initScorePointsArrray();

        // push score points
        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i);

            if (item.scorePoints1000 >= 0)
                pushIfNotExistScorePoints(item.category, item.scorePoints1000);
        }

        // sort arrays
        for (var key in categoriesScorePoints) {
            categoriesScorePoints[key].sort(function(a,b) { return b - a; });
        }

        // get order
        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i);

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

            if (item[refRole1] === refRoleVal1 && item[refRole2] === refRoleVal2) {

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

            if (item[refRole] === refVal) {
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

        var item = contestantsListModel.get(current)

        // no igc assigned
        if (item.filename === "") return;

        if ((item.score !== undefined) && (item.score !== "")) { // pokud je vypocitane, tak nepocitame znovu
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

        var wptString = [];
        contestantsListModel.setProperty(current, "trackHash", "");
        contestantsListModel.setProperty(current, "wptScoreDetails", "");
        contestantsListModel.setProperty(current, "speedSectionsScoreDetails", "");
        contestantsListModel.setProperty(current, "spaceSectionsScoreDetails", "");
        contestantsListModel.setProperty(current, "altitudeSectionsScoreDetails", "");

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

        contestantsListModel.setProperty(current, "trackHash", MD5.MD5(JSON.stringify(trItem)));
        contestantsListModel.setProperty(current, "wptScoreDetails", wptString.join("; "));
        contestantsListModel.setProperty(current, "speedSectionsScoreDetails", JSON.stringify(new_section_speed_array));
        contestantsListModel.setProperty(current, "spaceSectionsScoreDetails", JSON.stringify(new_section_space_array));
        contestantsListModel.setProperty(current, "altitudeSectionsScoreDetails", JSON.stringify(new_section_alt_array));

        contestantsListModel.setProperty(current, "score_json", JSON.stringify(dataArr))
        contestantsListModel.setProperty(current, "score", str)

        //calc contestant manual values score - markers, photos,..
        recalculateContestnatManualScoreValues(current);

        var score = getTotalScore(current);

        contestantsListModel.setProperty(current, "scorePoints", score);
        recalculateScoresTo1000();

        // save changes to CSV
        writeScoreManulaValToCSV();
        writeCSV()

        console.timeEnd("computeScore")
        return str;
    }

    function writeScoreManulaValToCSV() {

        if (contestantsTable.currentRow < 0)
            return;

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
        //var tg_time_manual = [];
        //var tp_hit_manual = [];
        //var sg_hit_manual = [];
        //var alt_manual = [];

        var i;
        var j;
        var ct;
        var item;

        // Find classify field in igc for current contestant
        for (j = 0; j < contestantsListModel.count; j++) {

             // contestant item
            ct = contestantsListModel.get(j);

            //console.log(item.name)
            //console.log(item.prevResultsWPT)
            //console.log(item.prevResultsSpeedSec)
            //console.log(item.prevResultsSpaceSec)
            //console.log(item.prevResultsAltSec)

            // load manual values into list models
            loadStringIntoListModel(wptNewScoreListManualValuesCache, ct.prevResultsWPT, "; ");
            loadStringIntoListModel(speedSectionsScoreListManualValuesCache, ct.prevResultsSpeedSec, "; ");
            loadStringIntoListModel(spaceSectionsScoreListManualValuesCache, ct.prevResultsSpaceSec, "; ");
            loadStringIntoListModel(altSectionsScoreListManualValuesCache, ct.prevResultsAltSec, "; ");

            // Calc wpt points sum
            for (i = 0; i < wptNewScoreListManualValuesCache.count; i++) {
                item = wptNewScoreListManualValuesCache.get(i);

                tgScoreSum += item.tg_score === -1 ? 0 : item.tg_score;
                tpScoreSum += item.tp_score === -1 ? 0 : item.tp_score;
                sgScoreSum += item.sg_score === -1 ? 0 : item.sg_score;
                altPenaltySum += item.alt_score === -1 ? 0 : item.alt_score;

                // TODO nevim k cemu to je?
                //tg_time_manual.push(item.tg_time_manual);
                //tp_hit_manual.push(item.tp_hit_manual);
                //sg_hit_manual.push(item.sg_hit_manual);
                //alt_manual.push(item.alt_manual);
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

            str += "\"" + F.addSlashes(ct.name) + "\";"

            str += "\"" + ct.markersOk + "\";"
            str += "\"" + ct.markersNok + "\";"
            str += "\"" + ct.markersFalse + "\";"

            str += "\"" + ct.photosOk + "\";"
            str += "\"" + ct.photosNok + "\";"
            str += "\"" + ct.photosFalse + "\";"

            str += "\"" + ct.landingScore + "\";"

            str += "\"" + ct.otherPoints + "\";"
            str += "\"" + 0 + "\";"

            str += "\"" + ct.startTime + "\";"
            str += "\"" + ct.startTimeMeasured + "\";"
            str += "\"" + Math.abs(ct.startTimeScore) + "\";"

            str += "\"" + (ct.circlingCount + ct.oppositeCount) + "\";"
            str += "\"" + Math.abs(ct.oppositeScore + ct.circlingScore) + "\";"

            str += "\"" + ct.otherPenalty + "\";"
            str += "\"" + 0 + "\";"

            str += "\"" + Math.max(ct.scorePoints, 0) + "\";"
            str += "\"" + Math.max(ct.scorePoints1000, 0) + "\";"

            var classify = ct.classify === 0 ? "yes" : "no";

            str += "\"" + classify + "\";"   //index 20

            str += "\"" + F.addSlashes(ct.otherPointsNote) + "/&/" + F.addSlashes(ct.otherPenaltyNote) + "\";" //note delimeter

            str += "\"" + tgScoreSum + "\";"
            str += "\"" + tpScoreSum + "\";"
            str += "\"" + sgScoreSum + "\";"
            str += "\"" + altPenaltySum + "\";"
            str += "\"" + speedSecScoreSum + "\";"
            str += "\"" + altSecScoreSum + "\";"
            str += "\"" + spaceSecScoreSum + "\";"
            str += "\"" + ct.pilot_id + "\";"
            str += "\"" + ct.copilot_id + "\";"
            str += "\"" + F.addSlashes(ct.trackHash) + "\";"
            str += "\"" + ct.speed + "\";"
            str += "\"" + ct.startTime + "\";"
            str += "\"" + ct.category + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.wptScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.speedSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.spaceSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.altitudeSectionsScoreDetails) + "\";"
            str += "\"" + F.addSlashes(ct.filename) + "\";"
            str += "\"" + F.addSlashes(ct.score) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.score_json) + "\";"
            str += "\"" + ct.markersScore + "\";"
            str += "\"" + ct.photosScore + "\";"
            str += "\"" + ct.startTimeDifference + "\";"
            str += "\"" + ct.circlingCount + "\";"
            str += "\"" + ct.circlingScore + "\";"
            str += "\"" + ct.oppositeCount + "\";"
            str += "\"" + ct.oppositeScore + "\";"

            str += "\n";
        }

        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvResultsFile), str);
    }

    function writeCSV() {

        var str = "";

        for (var i = 0; i < contestantsListModel.count; i++) {

            var ctnt = contestantsListModel.get(i)

            str += "\"" + ctnt.fullName + "\";"
            str += "\"" + ctnt.filename + "\";"

            str += ctnt.score;
            str += "\n";
        }
        str += ""


        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvFile), str);

        str = "";
        // polozka i = 0 je vyhrazena pro pouziti "prazdne polozky" v comboboxu; misto toho by mela jit hlavicka
        for (var i = 0; i < contestantsListModel.count; i++) {
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
        contestantsTable.currentRow = -1;
        contestantsTable.selection.clear();
        for (var i = 0; i < contestantsTable.count; i++) {
            contestantsTable.setProperty(i, "score", "");
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

        for (var i = 0; i < contestantsListModel.count; i++) {

            contestant = contestantsListModel.get(i);

            if (resArr.indexOf(contestant.category) !== -1) {

                resArr[contestant.category].push([contestant.name,
                                               contestant.category,
                                               contestant.startTime,
                                               String(contestant.speed),
                                               contestant.aircraft_registration,
                                               contestant.aircraft_type,
                                               String(contestant.scorePoints),
                                               String(contestant.scorePoints1000)]);
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

            if (contestantsListModel.count <= 0) {
                running = false;
                return;
            }

            var current = -1;
            contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

            // select first item of list
            if (current < 0) {
                current = 0
                contestantsTable.selection.clear();
                contestantsTable.selection.select(current)
                contestantsTable.currentRow = current;
                return;
            }

            var item = contestantsListModel.get(current);


            if ((item.filename === "") || (item.score !== ""))  { // if ((no contestent selected) or (already computed))
                if (current+1 == contestantsListModel.count) { // finsihed
                    running = false;

                    // create results if flag is set
                    if (generateResultsFlag) {

                        generateResultsFlag = false;

                        contestantsTable.currentRow = -1;
                        contestantsTable.selection.clear();

                        resultsTimer.running = true;
                    }


                } else { // go to next
                    contestantsTable.selection.clear();
                    contestantsTable.selection.select(current+1)
                    contestantsTable.currentRow = current+1;
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

            if (contestantsTable.count <= 0) {
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
//            var item;
            var contestant;

            contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

            // select first item of list
            if (current < 0) {

                current = 0;
                contestantsTable.selection.clear();
                contestantsTable.selection.select(current);
                contestantsTable.currentRow = current;

                // load contestant
                contestant = contestantsListModel.get(current);

                // create contestant html file
                results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
                                                            JSON.stringify(contestant),
                                                            pathConfiguration.competitionName,
                                                            pathConfiguration.getCompetitionTypeString(parseInt(pathConfiguration.competitionType)),
                                                            pathConfiguration.competitionDirector,
                                                            pathConfiguration.competitionDirectorAvatar,
                                                            pathConfiguration.competitionArbitr,
                                                            pathConfiguration.competitionArbitrAvatar,
                                                            pathConfiguration.competitionDate);
            }
            else {

                // load contestant
                contestant = contestantsListModel.get(current);
                console.log("current "  + current + " / " + contestantsListModel.count)

                if (contestant.filename === "" || file_reader.file_exists(pathConfiguration.resultsFolder + "/"+ contestant.name + "_" + contestant.category + ".html"))  { //if results created or no results for this igc row
                    if (current + 1 == contestantsListModel.count) { // finsihed
                        running = false;

                        // category results
                        generateContinuousResults();

                        // save changes to CSV
                        writeScoreManulaValToCSV();

                        // tucek and tucek-settings CSV
                        writeCSV();

                    } else { // go to next
                        contestantsTable.selection.clear();
                        contestantsTable.selection.select(current+1)
                        contestantsTable.currentRow = current+1;

                        // load contestant
                        contestant = contestantsListModel.get(current + 1);

                        // create contestant html file
                        results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + contestant.name + "_" + contestant.category),
                                                                    JSON.stringify(contestant),
                                                                    pathConfiguration.competitionName,
                                                                    pathConfiguration.getCompetitionTypeString(parseInt(pathConfiguration.competitionType)),
                                                                    pathConfiguration.competitionDirector,
                                                                    pathConfiguration.competitionDirectorAvatar,
                                                                    pathConfiguration.competitionArbitr,
                                                                    pathConfiguration.competitionArbitrAvatar,
                                                                    pathConfiguration.competitionDate);
                    }
                }
            }
        }
    }

    MessageDialog {
        id: errorMessage;
        icon: StandardIcon.Critical;
        modality: "ApplicationModal"
    }

    MessageDialog {
        id: startUpMessage;
        icon: StandardIcon.Question;
        modality: "ApplicationModal"
        standardButtons: StandardButton.Yes | StandardButton.No

        //% "Recovery settings"
        title: qsTrId("start-up-message-dialog-title");

        //% "Do you want to load previous enviroment settings?"
        text: qsTrId("start-up-message-dialog-text");

        // Try to load prev settings from DB
        onYes: {

            // load last competition settings
            // try to load prev settings from database
            if (config.get("competitionName", "") === "") {

                // nothing in DB, load defaults
                pathConfiguration.competitionName = pathConfiguration.competitionName_default;
                pathConfiguration.competitionType = pathConfiguration.competitionType_default;
                pathConfiguration.competitionDirector = pathConfiguration.competitionDirector_default;
                pathConfiguration.competitionArbitr = pathConfiguration.competitionArbitr_default;
                pathConfiguration.competitionDate = pathConfiguration.competitionDate_default;
                pathConfiguration.competitionDirectorAvatar = pathConfiguration.competitionDirectorAvatar_default;
                pathConfiguration.competitionArbitrAvatar = pathConfiguration.competitionArbitrAvatar_default;
            }
            else {

                // set values from DB
                pathConfiguration.competitionName = config.get("competitionName", pathConfiguration.competitionName_default);
                pathConfiguration.competitionType = config.get("competitionType", pathConfiguration.competitionType_default);
                pathConfiguration.competitionDirector = config.get("competitionDirector", pathConfiguration.competitionDirector_default);
                pathConfiguration.competitionArbitr = JSON.parse(config.get("competitionArbitr", pathConfiguration.competitionArbitr_default));
                pathConfiguration.competitionDate = config.get("competitionDate", pathConfiguration.competitionDate_default);
                pathConfiguration.competitionDirectorAvatar = JSON.parse(config.get("competitionDirectorAvatar", pathConfiguration.competitionDirectorAvatar_default));
                pathConfiguration.competitionArbitrAvatar = JSON.parse(config.get("competitionArbitrAvatar", pathConfiguration.competitionArbitrAvatar_default));
            }

            // init tmp var
            pathConfiguration.contestantsDownloadedString = "";

            // try to load last path settings
            var igcPrevCheckBox = 0;
            var trackPrevCheckBox = 0;
            var resultsFolderPrevCheckBox = 0;
            var onlineOfflinePrevCheckBox = 0;

            pathConfiguration.igcDirectory_user_defined = config.get("igcDirectory_user_defined", "");
            pathConfiguration.resultsFolder_user_defined = config.get("resultsFolder_user_defined", "");
            pathConfiguration.trackFile_user_defined = config.get("trackFile_user_defined", "");
            pathConfiguration.selectedCompetition = config.get("onlineOffline_user_defined", "");
            selectCompetitionOnlineDialog.selectedCompetitionId = config.get("selectedCompetitionId", 0);
            selectCompetitionOnlineDialog.selectedCompetition = pathConfiguration.selectedCompetition;

            if (pathConfiguration.igcDirectory_user_defined !== "") {
                igcPrevCheckBox = 1;    // set combobox to user defined
            }

            if (pathConfiguration.trackFile_user_defined !== "") {
                trackPrevCheckBox = 1;  // set combobox to user defined
            }

            if (pathConfiguration.resultsFolder_user_defined !== "") {
                resultsFolderPrevCheckBox = 1;  // set combobox to user defined
            }

            if (pathConfiguration.selectedCompetition !== "") {
                onlineOfflinePrevCheckBox = 1;  // set combobox to user defined
            }

            pathConfiguration.trackCheckBox = trackPrevCheckBox;
            pathConfiguration.igcFolderCheckBox = igcPrevCheckBox;
            pathConfiguration.resultsFolderCheckBox = resultsFolderPrevCheckBox;
            pathConfiguration.onlineOfflineCheckBox = onlineOfflinePrevCheckBox;

            // dialog will be automatically confirmed after show and synchronization
            pathConfiguration.autoConfirmFlag = true;
            pathConfiguration.show(); // call onVisibleChanged functions
        }

        // Discard prev settings
        onNo: {

            //competition settings - load defaults
            pathConfiguration.competitionName = pathConfiguration.competitionName_default;
            pathConfiguration.competitionType = pathConfiguration.competitionType_default;
            pathConfiguration.competitionDirector = pathConfiguration.competitionDirector_default;
            pathConfiguration.competitionArbitr = pathConfiguration.competitionArbitr_default;
            pathConfiguration.competitionDate = pathConfiguration.competitionDate_default;
            pathConfiguration.competitionDirectorAvatar = pathConfiguration.competitionDirectorAvatar_default;
            pathConfiguration.competitionArbitrAvatar = pathConfiguration.competitionArbitrAvatar_default;

            // init tmp var
            pathConfiguration.contestantsDownloadedString = "";

            //path settings - load defaults
            pathConfiguration.selectedCompetition = "";
            pathConfiguration.trackCheckBox = 0;
            pathConfiguration.igcFolderCheckBox = 0;
            pathConfiguration.resultsFolderCheckBox = 0;
            pathConfiguration.onlineOfflineCheckBox = 0; // switch to offline state

            // dialog will NOT be automatically confirmed
            pathConfiguration.autoConfirmFlag = false;
            pathConfiguration.show();
        }
    }

    MessageDialog {
        id: contestnatsNotFoundMessage;
        icon: StandardIcon.Critical;

        standardButtons: StandardButton.Yes | StandardButton.Cancel

        onButtonClicked: {

            if (clickedButton == StandardButton.Yes) {

                close();
                pathConfiguration.close();
                selectCompetitionOnlineDialog.show();
            }
            else {
                close();
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
                            if (item.filename === filename) {
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
