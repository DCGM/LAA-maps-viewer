import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.2
import cz.mlich 1.0
import "functions.js" as F
import "csv.js" as CSVJS
import "md5.js" as MD5


ApplicationWindow {
    id: applicationWindow
    //% "Trajectory viewer"
    title: qsTrId("application-window-title")
    width: 1280
    height: 660 // FIXME 860

    property bool debug: false;

    property variant tracks;
    property variant trItem;
    property variant ctnt;

    property variant tracksVbtTimes;
    property variant tracksPrepTimes;

    property variant maxPointsArr;

    property int minContestantInCategory: 3

    property variant categoriesScorePoints: [];

    property int utc_offset_sec: 0


    UploaderDialog {
        id: uploaderDialog
    }

    ResultsUploader {
        id: resultsUploaderComponent
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

                    workingTimer.action = "refreshContestant";
                    workingTimer.running = true;
                }
                shortcut: "F5"//"Ctrl+W"
            }
            MenuItem {
                //% "E&xit"
                text: qsTrId("main-file-menu-exit")
                onTriggered: Qt.quit();
                shortcut: "Alt+F4"
            }
        }

        Menu {
            id: resultsMenu
            //% "&Results"
            title: qsTrId("main-results-menu")

            onAboutToShow: {

                resultsFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + qsTrId("file-name-ontinuous-results") + ".html"));
                startListExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + qsTrId("start-list-filename") + ".html"));
            }

            property bool resultsFileExist: false;
            property bool startListExist: false;

            MenuItem {
                //% "Evaluate all"
                text: qsTrId("main-results-menu-evaluate-all");
                onTriggered: {

                    contestantsTable.selection.clear(); // clear selection - start on first row
                    evaluate_all_data();
                }
                enabled: (contestantsListModel.count > 0)
                shortcut: "Ctrl+R"
            }

            MenuItem {
                //% "Export result&s"
                text: qsTrId("main-results-menu-export-final-results");
                onTriggered: exportFinalResults();
                enabled: (contestantsListModel.count > 0)
                shortcut: "Ctrl+X"
            }

            MenuItem {
                //% "&Show results"
                text: qsTrId("main-results-menu-show-results")
                onTriggered: showResults();
                enabled: resultsMenu.resultsFileExist
                shortcut: "Ctrl+P"
            }

            MenuItem {
                //% "Show start &list"
                text: qsTrId("main-results-menu-show-start-list")
                onTriggered: showStartList();
                enabled: resultsMenu.startListExist
                shortcut: "Ctrl+S"
            }
        }

        Menu {
            //% "&Map"
            title: qsTrId("main-map-menu")
            ExclusiveGroup {
                id: mapTypeExclusive
            }

            MenuItem {
                id: mapNone
                //% "&None"
                text: qsTrId("main-map-menu-none")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-none");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = "";
                        map.url_subdomains = [];
                    }
                }

                shortcut: "Ctrl+1"
            }
            MenuItem {
                id: mapLocal
                //% "&Local"
                text: qsTrId("main-map-menu-local")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    console.log("Cached OSM")
                    config.set("v2_mapTypeExclusive", "main-map-menu-local");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = "../../../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                        map.url_subdomains = [];
                    }
                }

                shortcut: "Ctrl+2"

            }
            MenuItem {
                id: mapOsm
                //% "&OSM Mapnik"
                text: qsTrId("main-map-menu-osm")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-osm");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = "http://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
                        map.url_subdomains = ['a','b', 'c'];
                    }
                }

                shortcut: "Ctrl+3"

            }
            MenuItem {
                id: mapGoogleRoadmap
                //% "Google &Roadmap"
                text: qsTrId("main-map-menu-google-roadmap")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-google-roadmap");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = "http://%(s)d.google.com/vt/lyrs=m@248407269&hl=x-local&x=%(x)d&y=%(y)d&z=%(zoom)d&s=Galileo"
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                    }
                }

                shortcut: "Ctrl+4"

            }

            MenuItem {
                id: mapGoogleTerrain
                //% "Google &Terrain"
                text: qsTrId("main-map-menu-google-terrain")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-google-terrain");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = "http://%(s)d.google.com/vt/lyrs=t,r&x=%(x)d&y=%(y)d&z=%(zoom)d"
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                    }
                }

                shortcut: "Ctrl+5"
            }

            MenuItem {
                id: mapGoogleSatelite
                //% "Google &Satellite"
                text: qsTrId("main-map-menu-google-satellite")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-google-satellite");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.url = 'http://%(s)d.google.com/vt/lyrs=s&x=%(x)d&y=%(y)d&z=%(zoom)d';
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                    }
                }

                shortcut: "Ctrl+6"
            }
            MenuItem {
                id: mapCustom
                //% "Custom tile layer"
                text: qsTrId("main-map-menu-custom-tile-layer")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    config.set("v2_mapTypeExclusive", "main-map-menu-custom-tile-layer");
                }

                onCheckedChanged: {
                    if (checked) {
                        mapurl_dialog.open();
                        map.url_subdomains = [];
                    }
                }

                shortcut: "Ctrl+7"
            }

            ExclusiveGroup {
                id: mapTypeSecondaryExclusive
            }

            MenuItem {
                id: airspaceOff
                //% "Airspace Off"
                text: qsTrId("main-map-menu-airspace-off")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                checked: true;
                onTriggered: {
                    config.set("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-off");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.airspaceUrl = ""
                        map.mapAirspaceVisible = false;
                    }
                }
            }

            MenuItem {
                id: airspaceProsoar
                //% "Airspace (prosoar.de)"
                text: qsTrId("main-map-menu-airspace-prosoar")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    config.set("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-prosoar");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.airspaceUrl = "http://prosoar.de/airspace/%(zoom)d/%(x)d/%(y)d.png"
                        map.mapAirspaceVisible = true;
                    }
                }
            }

            MenuItem {
                id: airspaceLocal
                //% "Airspace (local)"
                text: qsTrId("main-map-menu-airspace-local")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    config.set("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-local");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.airspaceUrl = "../../../../Maps/airspace/tiles/%(zoom)d/%(x)d/%(y)d.png"
                        map.mapAirspaceVisible = true;
                    }
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
                //% "&Zoom to track"
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
                //% "&Contestants"
                text: qsTrId("main-view-menu-contestants")
                checkable: true;
                //checked: true;
                shortcut: "Ctrl+T"

                onTriggered: {
                    config.set("v2_mainViewMenuTables_checked", checked ? "yes" : "no");
                }
            }

            MenuItem {
                id: mainViewMenuAltChart
                //% "&Altitude profile"
                text: qsTrId("main-view-menu-altchart")
                checkable: true;
                //checked: false;
                shortcut: "Ctrl+A"

                onTriggered: {
                    config.set("v2_mainViewMenuAltChart_checked", checked ? "yes" : "no");
                }
            }

            MenuItem {
                id: mainViewMenuCategoryCountersStatusBar
                //% "Contestant &counters"
                text: qsTrId("main-view-menu-category-counters-sb")
                checkable: true;
                //checked: true;
                shortcut: "Ctrl+C"

                onTriggered: {
                    config.set("v2_mainViewMenuCategoryCountersStatusBar_checked", checked ? "yes" : "no");
                }
            }
            MenuItem {
                id: mainViewMenuCompetitionPropertyStatusBar
                //% "Competition &details"
                text: qsTrId("main-view-menu-comp-property-sb")
                checkable: true;
                //checked: true;
                shortcut: "Ctrl+D"

                onTriggered: {
                    config.set("v2_mainViewMenuCompetitionPropertyStatusBar_checked", checked ? "yes" : "no");
                }
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

            reloadContestants(csvString);
            selectCompetitionOnlineDialog.close();
            refreshContestantsDialog.show();
        }

        onCompetitionSelected: {

            resultsUploaderComponent.uploadResults(selectCompetitionOnlineDialog.selectedCompetitionId);
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

            // do it through the timer
            workingTimer.action = "refreshDialogOnOk";
            workingTimer.running = true;
        }

        onCancel: {

            unmodifiedContestants.clear();
            updatedContestants.clear();
            addedContestants.clear();
            removedContestants.clear();
        }
    }

    function joinContestantsListModels() {

        contestantsListModel.clear();

        var i = 0;
        var item;

        for(i = 0; i < unmodifiedContestants.count; i++) {
            item = unmodifiedContestants.get(i);

            if (item.selected) {
                contestantsListModel.append(item);
            }
        }

        for(i = 0; i < removedContestants.count; i++) {
            item = removedContestants.get(i);

            if (item.selected) {
                contestantsListModel.append(item);
            }
        }

        for(i = 0; i < addedContestants.count; i++) {
            item = addedContestants.get(i);

            if (item.selected) {
                contestantsListModel.append(item);
            }
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

    function getContestantIndexByProperty(name, category, speed, planeType, planeRegistration) {

        for (var i = 0; i < contestantsListModel.count; i++) {

            var item = contestantsListModel.get(i);

            if(item.name === name && item.category === category && item.speed === speed && item.aircraft_type === planeType && item.aircraft_registration === planeRegistration) {
                return i;
            }
        }
        return 0;
    }

    CppWorker {

        id: cppWorker;
    }

    PathConfiguration {
        id: pathConfiguration;
        onOk: {

            // do it through the timer
            workingTimer.action = "pathOnOk";
            workingTimer.running = true;
        }
        onCancel: {
            pathConfiguration.contestantsDownloadedString = "";
        }
    }

    IGCChooseDialog {
        id: igcChooseDialog
        datamodel: igcFolderModel
        cm: contestantsListModel
        onChoosenFilename: {

            contestantsListModel.changeLisModel(crow, "filename", filename);

            contestantsTable.selectRow(crow);

            visible = false;
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
            onTriggered: { contestantsTable.generateResults(recalculateScoreMenu.selectedRow, true); }
        }
    }

    Menu {
        id: createContestantMenu;

        property bool menuVisible: false

        MenuItem {
            //% "Create crew"
            text: qsTrId("scorelist-table-menu-append-contestant")

            onTriggered: {
                // new crew
                resultsDetailComponent.curentContestant = createBlankUserObject();
                resultsDetailComponent.crew_row_index = -1;
                resultsDetailComponent.visible = true;

            }
        }
    }

    Menu {
        id: updateContestantMenu;

        property int row: -1
        property bool menuVisible: false

        signal showMenu();
        signal openFormForEdit();

        onOpenFormForEdit: {
            contestantsTableShowResultsDialog(updateContestantMenu.row);
        }

        onShowMenu: {

            if (row < 0) return;

            popup();
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
                updateContestantMenu.openFormForEdit();
            }
        }

        MenuItem {
            //% "Create crew"
            text: qsTrId("scorelist-table-menu-append-contestant")

            onTriggered: {
                // new crew
                resultsDetailComponent.curentContestant = createBlankUserObject();
                resultsDetailComponent.crew_row_index = -1;
                resultsDetailComponent.visible = true;
            }
        }

        MenuItem {
            //% "Remove contestant"
            text: qsTrId("scorelist-table-menu-remove-contestant")

            onTriggered: {

                var conte = contestantsListModel.get(updateContestantMenu.row);

                // deselect row
                contestantsTable.selection.clear();

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

        function getName(i) {
            if ((i >= 0) && (i < count)) {
                var item = competitionClassModel.get(i);
                if (item.text !== undefined) {
                    return item.text
                }
            }

            return '-';
        }

        function categoryToIndex(name) {
            for (var i = 0; i < count; i++) {
                var item = get(i);
                if (item.text === name) {
                    return i;
                }
            }
            return 0;
        }

    }

    ListModel {
        id: scoreListClassifyListModel

        ListElement { //% "yes"
            classify: qsTrId("scorelist-table-classify-yes") }
        ListElement { //% "no"
            classify: qsTrId("scorelist-table-classify-no") }


        function classifyToIndex(name) {
            for (var i = 0; i < count; i++) {
                var item = get(i);
                if (item.text === name) {
                    return i;
                }
            }
            return 0;
        }

        function getName(i) {
            if ((i >= 0) && (i < count)) {
                var item = scoreListClassifyListModel.get(i)
                if (item.classify !== undefined) {
                    return item.classify;
                }
            }

            return '-';
        }


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
            var prevName = prevItem.name;

            contestantsListModel.setProperty(row, role, value)
            var contestant = contestantsListModel.get(row);

            // init classify combobox for contestant
            if (parseInt(contestant.classify) === -1) {
                contestantsListModel.setProperty(row, "classify", contestant.prevResultsClassify);
            }

            if (role === "category") {

                // change full name and reload item
                contestantsListModel.setProperty(row, "fullName", F.getContestantResultFileName(contestant.name, contestant.category));
                contestant = contestantsListModel.get(row);
            }
            if (role === "filename" || role === "speed" || role === "startTime" || role === "category") {

                trItem = [];

                // load contestant category
                if (tracks !== undefined && tracks.tracks !== undefined) {

                    for (var t = 0; t < tracks.tracks.length; t++) {

                        if (tracks.tracks[t].name === contestant.category)
                            trItem = tracks.tracks[t]
                    }
                }

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
                    //contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
                    //contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
                    //contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
                    //contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
                    contestantsListModel.setProperty(row, "score_json", "");
                    contestantsListModel.setProperty(row, "trackHash", "");
                }
                // load prev results
                else {

                    contestantsListModel.setProperty(row, "markersScore", contestant.prevResultsMarkersScore);
                    contestantsListModel.setProperty(row, "photosScore", contestant.prevResultsPhotosScore);
                    contestantsListModel.setProperty(row, "startTimeDifference", contestant.prevResultsStartTimeDifference);
                    contestantsListModel.setProperty(row, "startTimeScore", contestant.prevResultsStartTimeScore);
                    //contestantsListModel.setProperty(row, "circlingScore", contestant.prevResultsCirclingScore);
                    contestantsListModel.setProperty(row, "oppositeScore", contestant.prevResultsOppositeScore);
                    contestantsListModel.setProperty(row, "tgScoreSum", contestant.prevResultsTgScoreSum);
                    contestantsListModel.setProperty(row, "tpScoreSum", contestant.prevResultsTpScoreSum);
                    contestantsListModel.setProperty(row, "sgScoreSum", contestant.prevResultsSgScoreSum);
                    contestantsListModel.setProperty(row, "altLimitsScoreSum", contestant.prevResultsAltLimitsScoreSum);
                    contestantsListModel.setProperty(row, "speedSecScoreSum", contestant.prevResultsSpeedSecScoreSum);
                    contestantsListModel.setProperty(row, "altSecScoreSum", contestant.prevResultsAltSecScoreSum);
                    contestantsListModel.setProperty(row, "spaceSecScoreSum", contestant.prevResultsSpaceSecScoreSum);
                    contestantsListModel.setProperty(row, "markersOk", contestant.prevResultsMarkersOk);
                    contestantsListModel.setProperty(row, "markersNok", contestant.prevResultsMarkersNok);
                    contestantsListModel.setProperty(row, "markersFalse", contestant.prevResultsMarkersFalse);
                    contestantsListModel.setProperty(row, "photosOk", contestant.prevResultsPhotosOk);
                    contestantsListModel.setProperty(row, "photosNok", contestant.prevResultsPhotosNok);
                    contestantsListModel.setProperty(row, "photosFalse", contestant.prevResultsPhotosFalse);
                    contestantsListModel.setProperty(row, "startTimeMeasured", contestant.prevResultsStartTimeMeasured);
                    contestantsListModel.setProperty(row, "landingScore", contestant.prevResultsLandingScore);
                    //contestantsListModel.setProperty(row, "circlingCount", contestant.prevResultsCirclingCount);
                    contestantsListModel.setProperty(row, "oppositeCount", contestant.prevResultsOppositeCount);
                    contestantsListModel.setProperty(row, "otherPoints", contestant.prevResultsOtherPoints);
                    contestantsListModel.setProperty(row, "otherPenalty", contestant.prevResultsOtherPenalty);
                    contestantsListModel.setProperty(row, "pointNote", contestant.prevResultsPointNote);

                    contestantsListModel.setProperty(row, "trackHash", contestant.prevResultsTrackHas);
                    contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
                    contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
                    contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
                    contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
                    contestantsListModel.setProperty(row, "score_json", contestant.prevResultsScoreJson)
                    contestantsListModel.setProperty(row, "score", contestant.prevResultsScore)
                    contestantsListModel.setProperty(row, "scorePoints", contestant.prevResultsScorePoints);
                }

                // recalculate manual values score / markers, photos, ...
                if (contestant.filename !== "") {
                    recalculateContestnatManualScoreValues(row);

                    var score = getTotalScore(row);

                    contestantsListModel.setProperty(row, "scorePoints", score);
                    recalculateScoresTo1000();
                }

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

            // gen new results sheet
            genResultsDetailTimer.showOnFinished = false;   // dont open results automatically
            genResultsDetailTimer.running = true;
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

    SplitView {
        id: splitView
        anchors.fill: parent;
        orientation: Qt.Horizontal

        SplitView {
            id: splitViewIgcResults
            width: 1110;
            height: parent.height
            orientation: Qt.Vertical
            visible: mainViewMenuTables.checked

            ///// IGC file list
            TableView {
                id: contestantsTable;
                model: contestantsListModel;
                width: parent.width;
                Layout.fillHeight: true;
                clip: true;
                //visible: !resultsDetailComponent.visible

                signal selectRow(int row);
                signal generateResults(int row, bool showOnFinished);
                signal recalculateResults(int row);

                onRecalculateResults: {

                    contestantsListModel.setProperty(row, "score", "");        //compute new score
                    contestantsListModel.setProperty(row, "scorePoints", -1);
                    contestantsListModel.setProperty(row, "scorePoints1000", -1);

                    contestantsTable.selectRow(row);
                }

                onGenerateResults: {

                    if (contestantsTable.currentRow !== row) {  // dont select if already selected

                        contestantsTable.selection.clear();
                        contestantsTable.selection.select(row);
                        contestantsTable.currentRow = row;
                    }

                    var contestant = contestantsListModel.get(row);

                    // create contestant html file
                    results_creator.createContestantResultsHTML((pathConfiguration.resultsFolder + "/" + F.getContestantResultFileName(contestant.name, contestant.category)),
                                                                JSON.stringify(contestant),
                                                                pathConfiguration.competitionName,
                                                                pathConfiguration.getCompetitionTypeString(parseInt(pathConfiguration.competitionType)),
                                                                pathConfiguration.competitionDirector,
                                                                pathConfiguration.competitionDirectorAvatar,
                                                                pathConfiguration.competitionArbitr,
                                                                pathConfiguration.competitionArbitrAvatar,
                                                                pathConfiguration.competitionDate,
                                                                pathConfiguration.competitionRound,
                                                                pathConfiguration.competitionGroupName,
                                                                applicationWindow.utc_offset_sec);

                    // open results
                    if (showOnFinished) {
                        Qt.openUrlExternally(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + F.getContestantResultFileName(contestant.name, contestant.category) + ".html"));
                    }
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

                    onShowContestnatEditForm: {
                        console.log("onShowContestnatEditForm")

                        updateContestantMenu.openFormForEdit();
                    }

                }


                rowDelegate: Rectangle {
                    id: rowRectangle
                    height: 30;
                    color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                    MouseArea {
                        anchors.fill: rowRectangle;
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: {

                            var row = isNaN(parseInt(styleData.row)) ? -1 : parseInt(styleData.row);

                            // create new contestant
                            if (mouse.button === Qt.RightButton) {

                                createContestantMenu.popup();
                            } else {
                                if ((row >= 0) && (row < contestantsListModel.count)) {
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

                    if (contestantsListModel.count <= 0) {
                        return;
                    }

                    var current = -1;

                    contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

                    if (current < 0) {
                        return;
                    }

                    ctnt = contestantsListModel.get(current)

                    console.log("selected row " +current + ": " + ctnt.name);

                    var arr = [];
                    if (tracks !== undefined && tracks.tracks !== undefined) {
                        arr = tracks.tracks;
                    }

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
                    else {

                        //                console.log("setFilter" + ctnt.startTime)
                        tool_bar.startTime = ctnt.startTime;

                        var filePath = pathConfiguration.igcDirectory + "/" + ctnt.filename;
                        if (file_reader.file_exists(Qt.resolvedUrl(filePath))) {
                            igc.load( file_reader.toLocal(Qt.resolvedUrl(filePath)), ctnt.startTime);
                        } else {
                            console.log(ctnt.name + "igc file " + ctnt.filename + " doesn't exists")
                            igc.clear();
                        }

                    }

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
                    //% "StartTime"
                    title: qsTrId("filelist-table-start-time")
                    role: "startTime"
                    width: 100
                }
                TableViewColumn {
                    //% "Speed"
                    title: qsTrId("filelist-table-speed")
                    role: "speed"
                    width: 60
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

                ResultsDetailComponent {

                    id: resultsDetailComponent
                    anchors.fill: parent
                    visible: false

                    function saveValuesFromDialogModel() {

                        // copy manual values into list models
                        var row = resultsDetailComponent.crew_row_index;
                        if (row != -1) { // edit crew details

                            contestantsListModel.setProperty(row, "name", curentContestant.name);
                            contestantsListModel.setProperty(row, "category", curentContestant.category);
                            contestantsListModel.setProperty(row, "speed", parseInt("0"+curentContestant.speed, 10));
                            contestantsListModel.setProperty(row, "startTime", curentContestant.startTime) ;
                            contestantsListModel.setProperty(row, "aircraft_registration", curentContestant.aircraft_registration);
                            contestantsListModel.setProperty(row, "aircraft_type", curentContestant.aircraft_type);
                            contestantsListModel.setProperty(row, "fullName", curentContestant.name + "_" + curentContestant.category);
                            contestantsListModel.setProperty(row, "classify", curentContestant.classify);

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
                            //contestantsListModel.setProperty(row, "circlingCount", curentContestant.circlingCount);
                            //contestantsListModel.setProperty(row, "circlingScore", curentContestant.circlingScore);
                            contestantsListModel.setProperty(row, "oppositeCount", curentContestant.oppositeCount);
                            contestantsListModel.setProperty(row, "oppositeScore", curentContestant.oppositeScore);
                            contestantsListModel.setProperty(row, "otherPoints", curentContestant.otherPoints);
                            contestantsListModel.setProperty(row, "otherPenalty", curentContestant.otherPenalty);
                            contestantsListModel.setProperty(row, "pointNote", curentContestant.pointNote);

                            // reload current contestant
                            ctnt = contestantsListModel.get(row);

                            // load and save modified score lists
                            contestantsListModel.setProperty(row, "wptScoreDetails", curentContestant.wptScoreDetails);
                            contestantsListModel.setProperty(row, "speedSectionsScoreDetails", curentContestant.speedSectionsScoreDetails);
                            contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", curentContestant.altitudeSectionsScoreDetails);
                            contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", curentContestant.spaceSectionsScoreDetails);

                            // set current values as prev results - used as cache when recomputing score
                            saveCurrentResultValues(row, ctnt);

                        } else { // add new crew

                            // create blank user
                            var new_contestant = createBlankUserObject();

                            // fill user params
                            new_contestant.name = curentContestant.name;
                            new_contestant.category = curentContestant.category;
                            new_contestant.speed = parseInt("0"+curentContestant.speed, 10);
                            new_contestant.startTime = curentContestant.startTime
                            new_contestant.aircraft_registration = curentContestant.aircraft_registration;
                            new_contestant.aircraft_type = curentContestant.aircraft_type;
                            new_contestant.fullName = curentContestant.name + "_" + curentContestant.category;
                            new_contestant.classify = curentContestant.classify;

                            new_contestant.markersOk = curentContestant.markersOk;
                            new_contestant.markersNok = curentContestant.markersNok;
                            new_contestant.markersFalse = curentContestant.markersFalse;
                            new_contestant.markersScore = curentContestant.markersScore;
                            new_contestant.photosOk = curentContestant.photosOk;
                            new_contestant.photosNok = curentContestant.photosNok;
                            new_contestant.photosFalse = curentContestant.photosFalse;
                            new_contestant.photosScore = curentContestant.photosScore;
                            new_contestant.startTimeMeasured = curentContestant.startTimeMeasured;
                            new_contestant.startTimeDifference = curentContestant.startTimeDifference;
                            new_contestant.startTimeScore = curentContestant.startTimeScore;
                            new_contestant.landingScore = curentContestant.landingScore;

                            //new_contestant.circlingCount = curentContestant.circlingCount;
                            //new_contestant.circlingScore = curentContestant.circlingScore;
                            new_contestant.oppositeCount = curentContestant.oppositeCount;
                            new_contestant.oppositeScore = curentContestant.oppositeScore;
                            new_contestant.otherPoints = curentContestant.otherPoints;
                            new_contestant.otherPenalty = curentContestant.otherPenalty;
                            new_contestant.pointNote = curentContestant.pointNote;


                            new_contestant.wptScoreDetails = curentContestant.wptScoreDetails;
                            new_contestant.speedSectionsScoreDetails = curentContestant.speedSectionsScoreDetails;
                            new_contestant.altitudeSectionsScoreDetails = curentContestant.altitudeSectionsScoreDetails;
                            new_contestant.spaceSectionsScoreDetails = curentContestant.spaceSectionsScoreDetails;

//                            saveCurrentResultValues(row, ctnt); // FIXME?

                            // append into list model
                            contestantsListModel.append(new_contestant);

//                            // used instead of the append due to some post processing (call some on change method)
//                            contestantsListModel.changeLisModel(contestantsListModel.count - 1, "category", curentContestant.category);
//                            contestantsListModel.changeLisModel(contestantsListModel.count - 1, "speed", parseInt("0"+curentContestant.speed, 10));
//                            contestantsListModel.changeLisModel(contestantsListModel.count - 1, "startTime", curentContestant.startTime);


                        }

                        // recalculate score
                        var score = getTotalScore(row);
                        contestantsListModel.setProperty(row, "scorePoints", score);
                        recalculateScoresTo1000();

                        // save changes into CSV
                        writeScoreManulaValToCSV();

                    }

                    onOk: {

                        saveValuesFromDialogModel();

                        // gen new results sheet
                        genResultsDetailTimer.showOnFinished = false;   // dont open results automatically
                        genResultsDetailTimer.running = true;
                    }

                    onOkAndView: {

                        saveValuesFromDialogModel();

                        // gen new results sheet
                        genResultsDetailTimer.showOnFinished = true;   // open results automatically
                        genResultsDetailTimer.running = true;
                    }

                    onCancel: {
                    }
                }

                Rectangle { // disable
                    id: workingStatusRectangle
                    color: "#ffffff";
                    opacity: 0.7;
                    anchors.fill: parent;
                    visible: evaluateTimer.running ||
                             computingTimer.running ||
                             workingTimer.running ||
                             resultsExporterTimer.running  ||
                             pathConfiguration.visible ||
                             selectCompetitionOnlineDialog.visible ||
                             refreshContestantsDialog.visible ||
                             startUpMessage.visible ||
                             uploaderDialog.visible ||
                             igcChooseDialog.visible;

                    BusyIndicator {
                        id: busyIndicator
                        running: evaluateTimer.running ||
                                 computingTimer.running ||
                                 workingTimer.running ||
                                 resultsExporterTimer.running;

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    NativeText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: busyIndicator.bottom
                        anchors.topMargin: 30
                        font.pixelSize: 15
                        visible: busyIndicator.visible
                        text: mText

                        property string mText: "";

                        onVisibleChanged: {

                            if (visible) {

                                if (computingTimer.running || evaluateTimer.running) {
                                    //% "Computing..."
                                    mText = qsTrId("computing-status-title")
                                }
                                else if(resultsExporterTimer.running) {
                                    //% "Generating results..."
                                    mText = qsTrId("generating-results-status-title")
                                }
                                else if(workingTimer.running) {

                                    switch (workingTimer.action) {

                                    case ("pathOnOk"):
                                        //% "Recovering application settings..."
                                        mText = qsTrId("recovering-settings-status-title")
                                        break;

                                    case ("refreshDialogOnOk"):
                                    case ("refreshContestant"):
                                        //% "Loading..."
                                        mText = qsTrId("loading-status-title")
                                        break;

                                    default:
                                        //% "Working..."
                                        mText =  qsTrId("working-status-title")
                                    }
                                }
                                else {
                                    //% "Working..."
                                    mText =  qsTrId("working-status-title")
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent;
                        onClicked: {

                            if (evaluateTimer.running) {
                                console.log("onClick is disabled when evaluateTimer.running");
                                evaluateTimer.running = false;
                            }
                            if (resultsExporterTimer.running) {
                                console.log("onClick is disabled when resultsExporterTimer.running");
                                resultsExporterTimer.stop();
                            }
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
                    console.log("onTpiComputedData")
                    if (!updateContestantMenu.menuVisible && !resultsExporterTimer.running) {
                        //computeScore(tpi, polys)
                        computingTimer.tpi = tpi;
                        computingTimer.polys = polys;

                        computingTimer.running = true;
                    }
                }

                // navigation icons
                ColumnLayout {

                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 16
                    anchors.bottomMargin: 16
                    spacing: 0

                    Item {
                        width: 25
                        height: 25
                        visible: parent.visible

                        ShadowElement { // just for effect
                            anchors.fill: centerButton
                            source: centerButton
                        }

                        Rectangle {
                            id: centerButton
                            anchors.fill: parent;
                            radius: 3

                            MyImage {
                                source: "./data/ic_my_location_black_24dp/ic_my_location_black_24dp/web/ic_my_location_black_24dp_1x.png"
                                onMouse_clicked: map.pointsInBounds();
                            }
                        }
                    }

                    Rectangle { // spacer
                        color: "transparent"
                        height: 4
                    }

                    Item {
                        width: 25
                        height: 50

                        ShadowElement { // just for effect
                            anchors.fill: zoomButtons
                            source: zoomButtons
                        }

                        Rectangle {
                            id: zoomButtons
                            anchors.fill: parent;
                            radius: 3

                            ColumnLayout {

                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    Layout.fillWidth: true;
                                    Layout.preferredHeight: parent.height/2;
                                    radius: 3

                                    MyImage {
                                        source: "./data/ic_add_black_24dp/ic_add_black_24dp/web/ic_add_black_24dp_1x.png"
                                        onMouse_clicked: map.zoomIn();
                                    }
                                }

                                HorizontalDelimeter {
                                    Layout.fillWidth: true;
                                    Layout.margins: 2;
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter;

                                }

                                Rectangle {
                                    Layout.fillWidth: true;
                                    Layout.preferredHeight: parent.height/2;
                                    radius: 3

                                    MyImage {
                                        source: "./data/ic_remove_black_24dp/ic_remove_black_24dp/web/ic_remove_black_24dp_1x.png"
                                        onMouse_clicked: map.zoomOut();
                                    }
                                }
                            }
                        }
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


    function contestantsTableShowResultsDialog(row) {

        if (tracks === undefined) {
            //% "Track file is missing"
            errorMessage.text = qsTrId("contestantsTableShowResultsDialog-missing-track");
            errorMessage.open();
            return;
        }

        // load cattegory property
        var currentTrck;
        var found = false;
        var arr = tracks.tracks;
        var ctntCategory = contestantsListModel.get(row).category

        for (var i = 0; i < arr.length; i++) {
            currentTrck = arr[i];

            if (currentTrck.name === ctntCategory) {

                contestantsListModel.setProperty(row, "time_window_penalty", parseInt(currentTrck.time_window_penalty));
                contestantsListModel.setProperty(row, "time_window_size", parseInt(currentTrck.time_window_size));
                contestantsListModel.setProperty(row, "photos_max_score", parseInt(currentTrck.photos_max_score));
                contestantsListModel.setProperty(row, "oposite_direction_penalty", parseInt(currentTrck.oposite_direction_penalty));
                contestantsListModel.setProperty(row, "marker_max_score", parseInt(currentTrck.marker_max_score));
                contestantsListModel.setProperty(row, "gyre_penalty", parseInt(currentTrck.gyre_penalty));
                found = true;
                break;
            }
        }

        if (!found) {
            console.log("onShowResults " + "unable to get category property for: " + ctntCategory)

            contestantsListModel.setProperty(row, "time_window_penalty", 0);
            contestantsListModel.setProperty(row, "time_window_size", 0);
            contestantsListModel.setProperty(row, "photos_max_score", 0);
            contestantsListModel.setProperty(row, "oposite_direction_penalty", 0);
            contestantsListModel.setProperty(row, "marker_max_score", 0);
            contestantsListModel.setProperty(row, "gyre_penalty", 0);
        }

        // load contestant property
        ctnt = contestantsListModel.get(row);

        // TODO - prasarna aby byla kopie a ne stejny objekt
        resultsDetailComponent.curentContestant = createBlankUserObject();
        resultsDetailComponent.curentContestant = JSON.parse(JSON.stringify(ctnt));
        resultsDetailComponent.crew_row_index = row;


        var previous = -1;
        contestantsTable.selection.forEach( function(rowIndex) { previous = rowIndex; } )

        // select row
        if (previous !== row) {
            contestantsTable.selectRow(row);
        }

        resultsDetailComponent.visible = true;

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

    Timer {
        id: genResultsDetailTimer
        running: false;
        interval: 1;

        property bool showOnFinished: false

        onTriggered: {

            genResultsDetailTimer.running = false;

            var current = -1;
            contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )
            if (current < 0) {
                return;
            }

            contestantsTable.generateResults(current, showOnFinished);

            showOnFinished = false;
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
                    text: F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(map.currentPositionTime), applicationWindow.utc_offset_sec));
                    visible: (map.currentPositionTime !== "")
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
                    text: qsTrId("toolbar-start-time").arg(F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(tool_bar.startTime), applicationWindow.utc_offset_sec)));
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

                spacing: 40

                NativeText {text: pathConfiguration.competitionName }
                NativeText {text: qsTrId("html-results-competition-type") + ": " + pathConfiguration.competitionTypeText}
                NativeText {text: qsTrId("html-results-competition-director") + ": " +  pathConfiguration.competitionDirector}
                NativeText {text: qsTrId("html-results-competition-arbitr") + ": " +  pathConfiguration.competitionArbitr.join(", ")}
                NativeText {text: qsTrId("html-results-competition-date") + ": " +  pathConfiguration.competitionDate}
            }

            ListModel {
                id:statusBarCategoryCountersModel
            }


            Row {
                id: statusBarCategoryCounters
                visible: mainViewMenuCategoryCountersStatusBar.checked;
                spacing: 20

                Repeater {
                    model:  statusBarCategoryCountersModel;
                    height: 30
                    anchors.fill: parent;
                    NativeText {
                        text: name + ": " + number_of_contestants
                        color:
                            (number_of_contestants < applicationWindow.minContestantInCategory && number_of_contestants > 0) ? "red" : "black"
                    }
                }

            }
        }
    }

    function exportFinalResults() {

        if (applicationWindow.debug) {
            selectCompetitionOnlineDialog.openForExportResultsPurpose();
            return;
        }

        // offline - show competition list and select/confirm destination competition
        if (pathConfiguration.selectedCompetition == "" || isNaN(parseInt(selectCompetitionOnlineDialog.selectedCompetitionId))) {

            selectCompetitionOnlineDialog.openForExportResultsPurpose();
        }
        // online - init upload
        else {
            resultsUploaderComponent.uploadResults(selectCompetitionOnlineDialog.selectedCompetitionId);
        }
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

                var item_j_timeVal = item_j.startTime === "" || item_j.startTime === "00:00:00" ? 0 /*F.timeToUnix("23:59:59") + 1*/ : F.timeToUnix(item_j.startTime);
                var item_j1_timeVal = item_j1.startTime === "" || item_j1.startTime === "00:00:00" ? 0 /*F.timeToUnix("23:59:59") + 1*/ : F.timeToUnix(item_j1.startTime);

                // swap values && zero times to the end of list
                if ((item_j_timeVal > item_j1_timeVal && item_j1_timeVal !== 0 ) || item_j_timeVal === 0){

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
            "marker_max_score": 0,
            "photosOk": 0,
            "photosNok": 0,
            "photosFalse": 0,
            "photosScore": 0,
            "photos_max_score": 0,
            "startTimeMeasured": "",
            "startTimeDifference": "",
            "startTimeScore": 0,
            "landingScore": 0,
            "circlingCount": 0,
            "circlingScore": 0,
            "oppositeCount": 0,
            "oppositeScore": 0,
            "otherPoints": 0,
            //            "otherPointsNote": "",
            "otherPenalty": 0,
            //            "otherPenaltyNote": "",
            "pointNote": "",

            "time_window_penalty": 0,
            "time_window_size": 0,
            "oposite_direction_penalty": 0,
            "gyre_penalty": 0,

            "prevResultsMarkersScore": 0,
            "prevResultsPhotosScore": 0,
            "prevResultsStartTimeDifference": "",
            "prevResultsStartTimeScore": 0,
            "prevResultsCirclingScore": 0,
            "prevResultsOppositeScore": 0,
            "prevResultsTgScoreSum": -1,
            "prevResultsTpScoreSum": -1,
            "prevResultsSgScoreSum": -1,
            "prevResultsAltLimitsScoreSum": -1,
            "prevResultsSpeedSecScoreSum": -1,
            "prevResultsAltSecScoreSum": -1,
            "prevResultsSpaceSecScoreSum": -1,
            "prevResultsMarkersOk": 0,
            "prevResultsMarkersNok": 0,
            "prevResultsMarkersFalse": 0,
            "prevResultsPhotosOk": 0,
            "prevResultsPhotosNok": 0,
            "prevResultsPhotosFalse": 0,
            "prevResultsStartTimeMeasured": "",
            "prevResultsLandingScore": 0,
            "prevResultsCirclingCount": 0,
            "prevResultsOppositeCount": 0,
            "prevResultsOtherPoints": 0,
            "prevResultsOtherPenalty": 0,
            "prevResultsPointNote": "",
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

            "tgScoreSum": 0,
            "sgScoreSum": 0,
            "tpScoreSum": 0,
            "altLimitsScoreSum": 0,
            "speedSecScoreSum": 0,
            "spaceSecScoreSum": 0,
            "altSecScoreSum": 0,

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

    function loadContestants(filename) {

        contestantsTable.selection.clear();

        var f_data = file_reader.read(Qt.resolvedUrl(filename));
        var data = [];
        var resCSV = [];
        var i;

        // parse CSV, fast cpp variant or slow JS
        if (String(f_data).indexOf(cppWorker.csv_join_parse_delimeter_property) == -1) {

            resCSV = cppWorker.parseCSV(String(f_data));
            for (i = 0; i < resCSV.length; i++) {

                var resItem = resCSV[i];
                data.push(resItem.split(cppWorker.csv_join_parse_delimeter_property))
            }
        }
        else {
            console.log("have to use slow variant of CSV parser for contestant \n")
            data = CSVJS.parseCSV(String(f_data));
        }

        contestantsListModel.clear()

        for (i = 0; i < data.length; i++) {

            var item = data[i];
            var itemName = item[0]
            var j;

            // CSV soubor ma alespon 3 Sloupce
            if ((item.length > 2) && (itemName.length > 0)) {

                // check previous results validity
                var csvFileFromOffice = false;
                var csvFileFromViewer = false;

                // create blank user
                var new_contestant = createBlankUserObject();

                // fill user params
                new_contestant.name = itemName;
                new_contestant.category = item[1];
                new_contestant.fullName = item[2];
                new_contestant.startTime = (item[3] === "null" || item[3] === null) ? "00:00:00" : item[3];
                new_contestant.filename = (csvFileFromViewer && item[4] === "" ? resultsCSV[j][38] : item[4]);
                new_contestant.speed = parseInt("0"+item[5], 10);
                new_contestant.aircraft_type = item[6];
                new_contestant.aircraft_registration = item[7];
                new_contestant.crew_id = item[8];
                new_contestant.pilot_id = item[9];
                new_contestant.copilot_id = item[10];
                new_contestant.pilotAvatarBase64 = (item.length >= 13 ? (item[11]) : "");
                new_contestant.copilotAvatarBase64 = (item.length >= 13 ? (item[12]) : "");

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
                    new_contestant.speed = parseInt("0"+item[5],10);
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
                    currentCrew.newSpeed = parseInt("0"+item[5], 10);
                    currentCrew.newAircraft_type = item[6];
                    currentCrew.newAircraft_registration = item[7];
                    currentCrew.pilot_id = item[9];
                    currentCrew.copilot_id = item[10];

                    // add modified crew into updated list model
                    if (currentCrew.name !== currentCrew.newName ||
                            currentCrew.category !== currentCrew.newCategory ||
                            currentCrew.startTime !== (F.strTimeValidator(currentCrew.newStartTime) === -1 ? F.addTimeStrFormat(0) : currentCrew.newStartTime) ||
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

        if (tracks === undefined) {
            return;
        }

        // load results.csv
        var resultsCSV = [];
        var resCSV = [];
        var index = -1;
        var i;

        // try to load manual data
        if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.csvResultsFile))) {
            var cnt = file_reader.read(Qt.resolvedUrl(pathConfiguration.csvResultsFile));

            // parse CSV, fast cpp variant or slow JS
            if (String(cnt).indexOf(cppWorker.csv_join_parse_delimeter_property) == -1) {

                resCSV = cppWorker.parseCSV(String(cnt));
                for (i = 0; i < resCSV.length; i++) {

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

            index = -1;

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

                curCnt.prevResultsSpeed = (csvFileFromViewer ? parseInt("0"+resultsCSV[j][31], 10) : -1);
                curCnt.prevResultsStartTime = (csvFileFromViewer ? resultsCSV[j][32] : "");
                curCnt.prevResultsCategory = (csvFileFromViewer ? resultsCSV[j][33] : "");
                curCnt.prevResultsFilename = (csvFileFromViewer ? resultsCSV[j][38] : "");
                curCnt.prevResultsTrackHas = (csvFileFromViewer ? resultsCSV[j][30] : "");

                curCnt.filename = (csvFileFromViewer && curCnt.filename === "" ? resultsCSV[j][38] : curCnt.filename);

                // manual values
                curCnt.prevResultsMarkersOk = (csvFileFromOffice ? parseInt(resultsCSV[j][1]) : 0);
                curCnt.prevResultsMarkersNok = (csvFileFromOffice ? parseInt(resultsCSV[j][2]) : 0);
                curCnt.prevResultsMarkersFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][3]) : 0);
                curCnt.prevResultsPhotosOk = (csvFileFromOffice ? parseInt(resultsCSV[j][4]) : 0);
                curCnt.prevResultsPhotosNok = (csvFileFromOffice ? parseInt(resultsCSV[j][5]) : 0);
                curCnt.prevResultsPhotosFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][6]) : 0);
                curCnt.prevResultsStartTimeMeasured = (csvFileFromOffice ? resultsCSV[j][11] : "");
                curCnt.prevResultsLandingScore = (csvFileFromOffice ? parseInt(resultsCSV[j][7]) : 0);
                //curCnt.prevResultsCirclingCount = (csvFileFromViewer ? parseInt(resultsCSV[j][44]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][13])));
                curCnt.prevResultsOppositeCount = (csvFileFromViewer ? parseInt(resultsCSV[j][46]) : 0);
                curCnt.prevResultsOtherPoints = (csvFileFromOffice ? parseInt(resultsCSV[j][8]) : 0);
                curCnt.prevResultsOtherPenalty = (csvFileFromOffice ? parseInt(resultsCSV[j][15]) : 0);
                curCnt.prevResultsPointNote = (csvFileFromOffice ? String(resultsCSV[j][20]) : "");

                curCnt.prevResultsWPT = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][34]) : "");
                curCnt.prevResultsSpeedSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][35]) : "");
                curCnt.prevResultsAltSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][37]) : "");
                curCnt.prevResultsSpaceSec = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][36]) : "");

                // check results validity due to the contestant values
                if (resultsValid(curCnt.speed, curCnt.startTime, curCnt.category, curCnt.filename, MD5.MD5(JSON.stringify(trItem)),
                                 curCnt.prevResultsSpeed, curCnt.prevResultsStartTime, curCnt.prevResultsCategory, curCnt.prevResultsFilename, curCnt.prevResultsTrackHas)) {

                    curCnt.prevResultsMarkersScore = (csvFileFromViewer ? parseInt(resultsCSV[j][41]) : 0);
                    curCnt.prevResultsPhotosScore = (csvFileFromViewer ? parseInt(resultsCSV[j][42]) : 0);
                    curCnt.prevResultsStartTimeDifference = (csvFileFromOffice ? resultsCSV[j][43] : "");
                    curCnt.prevResultsStartTimeScore = (csvFileFromOffice ? parseInt(resultsCSV[j][12]) : 0);
                    //curCnt.prevResultsCirclingScore = (csvFileFromViewer ? parseInt(resultsCSV[j][45]) : (!csvFileFromOffice ? 0 : parseInt(resultsCSV[j][14] * -1)));
                    curCnt.prevResultsOppositeScore = (csvFileFromViewer ? parseInt(resultsCSV[j][47]) : 0);
                    curCnt.prevResultsTgScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][21]) : -1);
                    curCnt.prevResultsTpScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][22]) : -1);
                    curCnt.prevResultsSgScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][23]) : -1);
                    curCnt.prevResultsAltLimitsScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][24]) : -1);
                    curCnt.prevResultsSpeedSecScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][25]) : -1);
                    curCnt.prevResultsAltSecScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][26]) : -1);
                    curCnt.prevResultsSpaceSecScoreSum = (csvFileFromViewer ? parseInt(resultsCSV[j][27]) : -1);

                    curCnt.prevResultsSpeed = (csvFileFromViewer ? parseInt("0"+resultsCSV[j][31], 10) : -1);
                    curCnt.prevResultsStartTime = (csvFileFromViewer ? resultsCSV[j][32] : "");
                    curCnt.prevResultsCategory = (csvFileFromViewer ? resultsCSV[j][33] : "");
                    curCnt.prevResultsTrackHas = (csvFileFromViewer ? resultsCSV[j][30] : "");
                    curCnt.prevResultsFilename = (csvFileFromViewer ? resultsCSV[j][38] : "");
                    curCnt.prevResultsScorePoints = (csvFileFromOffice ? parseInt(resultsCSV[j][17]) : -1);
                    curCnt.prevResultsScore = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][39]) : "");
                    curCnt.prevResultsScoreJson = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][40]) : "");
                    curCnt.prevResultsClassify = (csvFileFromOffice ? (resultsCSV[j][19] === "yes" ? 0 : 1) : 0);
                }

                // save changes
                contestantsListModel.set(i, curCnt);
            }
        }
    }

    // function show results in local web viewer
    function showResults() {

        Qt.openUrlExternally(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + qsTrId("file-name-ontinuous-results") + ".html"));
    }


    // generate results for each category
    function generateContinuousResults() {

        var res = getContinuousResults();

        var csvString = "";

        //% "Continuous results"
        var resultsFilename = qsTrId("file-name-ontinuous-results");

        // BE CAREFULL WITH THIS SHIT
        var recSize = 21;

        var reStringArr = [];

        statusBarCategoryCountersModel.clear();
        // add Category names first
        for (var key in res) {
            reStringArr.push(key);
            var number_of_contestants_val = res[key].length;
            if (number_of_contestants_val > 0) {
                statusBarCategoryCountersModel.append({name: key, number_of_contestants: number_of_contestants_val})
            }
        }

        // add data as stringlist
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
                                                    pathConfiguration.competitionDate,
                                                    pathConfiguration.competitionRound,
                                                    pathConfiguration.competitionGroupName);

        // CSV and local listmodels
        var catArray = [];
        var item;

        //        console.log("generateContinuousResults: " + JSON.stringify(res))

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

    function showStartList() {

        Qt.openUrlExternally(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + qsTrId("start-list-filename") + ".html"));
    }

    function createStartList() {

        var date = [];
        var item;
        var startTimeSec;

        for (var i = 0; i < contestantsListModel.count; i++) {

            item = contestantsListModel.get(i);

            startTimeSec = F.timeToUnix(item.startTime);

            date.push(JSON.stringify({ "name": item.name,
                                         "category": item.category,
                                         "speed": item.speed,
                                         "startTimePrepTime": (tracksPrepTimes === undefined ? item.startTime : F.addTimeStrFormat(startTimeSec - parseInt(tracksPrepTimes[item.category] === undefined ? 0 : tracksPrepTimes[item.category]))),
                                         "startTime": item.startTime,
                                         "startTimeVBT": (tracksVbtTimes === undefined ? item.startTime : F.addTimeStrFormat(startTimeSec + parseInt(tracksVbtTimes[item.category] === undefined ? 0 : tracksVbtTimes[item.category]))),
                                         "aircraft_type": item.aircraft_type,
                                         "aircraft_registration": item.aircraft_registration,
                                         "startTimeMeasured": "",
                                         "landing": "",
                                         "photo": ""
                                     }));
        }

        //% "Start list"
        var filename = qsTrId("start-list-filename");

        // HTML
        results_creator.createStartListHTML(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + filename, date, pathConfiguration.competitionName, applicationWindow.utc_offset_sec);
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
    function getScorePointsSum(contestant) {

        var sum = 0;
        var p;
        var modelItem;

        var tgScoreSum = 0;
        var sgScoreSum = 0;
        var tpScoreSum = 0;
        var speedSecScoreSum = 0;
        var altLimitsScoreSum = 0;
        var i;

        if (contestant === undefined) return 0;

        // get score points from gates
        if (contestant.wptScoreDetails !== "") {

            wptNewScoreListManualValuesCache.clear();
            var arr = contestant.wptScoreDetails.split("; ")

            for (i = 0; i < arr.length; i++) {
                wptNewScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (p = 0; p < wptNewScoreListManualValuesCache.count; p++) {
                modelItem = wptNewScoreListManualValuesCache.get(p);

                tgScoreSum += Math.max(modelItem.tg_score, 0);
                sgScoreSum += Math.max(modelItem.sg_score, 0);
                tpScoreSum += Math.max(modelItem.tp_score, 0);

                altLimitsScoreSum += (modelItem.alt_score === -1 ? 0 : modelItem.alt_score);

            }
        }

        // get score points from speed sec
        if (contestant.speedSectionsScoreDetails !== "") {

            speedSectionsScoreListManualValuesCache.clear();
            arr = contestant.speedSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                speedSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (p = 0; p < speedSectionsScoreListManualValuesCache.count; p++) {
                speedSecScoreSum += Math.max(speedSectionsScoreListManualValuesCache.get(p).speedSecScore, 0);
            }
        }

        //contestantsListModel.setProperty(row, "tgScoreSum", tgScoreSum);
        //contestantsListModel.setProperty(row, "sgScoreSum", sgScoreSum);
        //contestantsListModel.setProperty(row, "tpScoreSum", tpScoreSum);
        //contestantsListModel.setProperty(row, "altLimitsScoreSum", altLimitsScoreSum);
        //contestantsListModel.setProperty(row, "speedSecScoreSum", speedSecScoreSum);

        contestant.tgScoreSum = tgScoreSum;
        contestant.sgScoreSum = sgScoreSum;
        contestant.tpScoreSum = tpScoreSum;
        contestant.altLimitsScoreSum = altLimitsScoreSum;
        contestant.speedSecScoreSum = speedSecScoreSum;

        sum = tgScoreSum +
                sgScoreSum +
                tpScoreSum +
                altLimitsScoreSum +
                speedSecScoreSum +
                contestant.markersScore +
                contestant.photosScore +
                contestant.landingScore +
                contestant.otherPoints -
                contestant.otherPenalty;

        wptNewScoreListManualValuesCache.clear();
        speedSectionsScoreListManualValuesCache.clear();

        var res = {
            "sum": sum,
            "tgScoreSum": tgScoreSum,
            "sgScoreSum": sgScoreSum,
            "tpScoreSum": tpScoreSum,
            "altLimitsScoreSum": altLimitsScoreSum,
            "speedSecScoreSum": speedSecScoreSum
        }

        return res;
    }

    // get total score points fur contestant and current igc item
    function getTotalScore(row) {

        var contestant = contestantsListModel.get(row);

        // get score points sum
        var res = getScorePointsSum(contestant)
        contestantsListModel.setProperty(row, "tgScoreSum", res.tgScoreSum);
        contestantsListModel.setProperty(row, "sgScoreSum", res.sgScoreSum);
        contestantsListModel.setProperty(row, "tpScoreSum", res.tpScoreSum);
        contestantsListModel.setProperty(row, "altLimitsScoreSum", res.altLimitsScoreSum);
        contestantsListModel.setProperty(row, "speedSecScoreSum", res.speedSecScoreSum);
        var scorePoints = res.sum;

        // get penalty percent points
        var penaltyPercentPointsSum = contestant.startTimeScore + contestant.circlingScore + contestant.oppositeScore;

        // get penalty percent points from sections
        var altSecPenaltySum = 0;
        var spaceSecPenaltySum = 0;
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
                altSecPenaltySum += item.altSecScore;
            }
            altSectionsScoreListManualValuesCache.clear();
        }
        contestantsListModel.setProperty(row, "altSecScoreSum", altSecPenaltySum);

        // space sec
        if (contestant.spaceSectionsScoreDetails !== "") {

            spaceSectionsScoreListManualValuesCache.clear();
            arr = contestant.spaceSectionsScoreDetails.split("; ")
            for (i = 0; i < arr.length; i++) {
                spaceSectionsScoreListManualValuesCache.append(JSON.parse(arr[i]))
            }

            for (i = 0; i < spaceSectionsScoreListManualValuesCache.count; i++) {
                item = spaceSectionsScoreListManualValuesCache.get(i)
                spaceSecPenaltySum += item.spaceSecScore;
            }
            spaceSectionsScoreListManualValuesCache.clear();
        }
        contestantsListModel.setProperty(row, "spaceSecScoreSum", spaceSecPenaltySum);

        return Math.max((scorePoints + penaltyPercentPointsSum + altSecPenaltySum + spaceSecPenaltySum), 0);
    }

    // recalculate score points for manual values - markers, photos, indirection flight,...
    function recalculateContestnatManualScoreValues(row) {

        ctnt = contestantsListModel.get(row);

        //calc contestant manual values score - markers, photos,..
        ctnt.markersScore = getMarkersScore(ctnt.markersOk, ctnt.markersNok, ctnt.markersFalse, trItem.marker_max_score);
        ctnt.photosScore = getPhotosScore(ctnt.photosOk, ctnt.photosNok, ctnt.photosFalse, trItem.photos_max_score);

        var res = getScorePointsSum(ctnt)

        contestantsListModel.setProperty(row, "tgScoreSum", res.tgScoreSum);
        contestantsListModel.setProperty(row, "sgScoreSum", res.sgScoreSum);
        contestantsListModel.setProperty(row, "tpScoreSum", res.tpScoreSum);
        contestantsListModel.setProperty(row, "altLimitsScoreSum", res.altLimitsScoreSum);
        contestantsListModel.setProperty(row, "speedSecScoreSum", res.speedSecScoreSum);
        var totalPointsScore = res.sum;

        ctnt.startTimeScore = getTakeOffScore(ctnt.startTimeDifference, trItem.time_window_size, trItem.time_window_penalty, totalPointsScore);
        //ctnt.circlingScore = getGyreScore(ctnt.circlingCount, trItem.gyre_penalty, totalPointsScore);
        ctnt.oppositeScore = getOppositeDirScore(ctnt.oppositeCount, trItem.oposite_direction_penalty, totalPointsScore);

        getAltitudeAndSpaceSectionsPenaltyPoints(row, totalPointsScore);

        // save changes into contestnat list model
        contestantsListModel.setProperty(row, "marker_max_score", parseInt(trItem.marker_max_score));
        contestantsListModel.setProperty(row, "photos_max_score", parseInt(trItem.photos_max_score));
        contestantsListModel.setProperty(row, "time_window_penalty", parseInt(trItem.time_window_penalty));
        contestantsListModel.setProperty(row, "time_window_size", parseInt(trItem.time_window_size));
        contestantsListModel.setProperty(row, "oposite_direction_penalty", parseInt(trItem.oposite_direction_penalty));
        contestantsListModel.setProperty(row, "gyre_penalty", parseInt(trItem.gyre_penalty));

        contestantsListModel.setProperty(row, "markersScore", ctnt.markersScore);
        contestantsListModel.setProperty(row, "photosScore", ctnt.photosScore);
        contestantsListModel.setProperty(row, "startTimeScore", ctnt.startTimeScore);
        //contestantsListModel.setProperty(row, "circlingScore", ctnt.circlingScore);
        contestantsListModel.setProperty(row, "oppositeScore", ctnt.oppositeScore);

    }

    // recalculate score points to 1000
    function recalculateScoresTo1000() {

        if (tracks === undefined) {
            return;
        }

        var i, item;
        maxPointsArr = {};

        var trtr = tracks.tracks
        for (i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            maxPointsArr[category_name] = 1;
        }

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

        // gen continuous results
        generateContinuousResults();

        // gen start list
        createStartList();
    }

    function initScorePointsArrray () {

        categoriesScorePoints = {};

        if (tracks === undefined) {
            return;
        }

        var trtr = tracks.tracks
        for (var i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            categoriesScorePoints[category_name] = [];
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

        var gatePointSum = Math.max(tg_score, 0) + Math.max(tp_score, 0) + Math.max(sg_score, 0);

        scoreData["tg_score"] = tg_score;
        scoreData["tp_score"] = tp_score;
        scoreData["sg_score"] = sg_score;
        scoreData["alt_score"] = ((alt_score === -1) ? -1 : (Math.abs(alt_score) > gatePointSum) ? gatePointSum * -1 : alt_score); // min points for each gate is 0

        return scoreData;
    }

    function getMinAltScore(altManual, altAuto, altMin, altPenalty) {

        return (altManual < 0 ? ((altAuto < altMin) ? ((altMin - altAuto) *  altPenalty ) * -1: 0) : ((altManual < altMin) ? (altMin - altManual) *  altPenalty * -1 : 0));
    }

    function getMaxAltScore(altManual, altAuto, altMax, altPenalty) {

        return (altManual < 0 ? ((altAuto > altMax) ? (altAuto - altMax) *  altPenalty * -1 : 0) : ((altManual > altMax) ? (altManual - altMax) *  altPenalty * -1: 0));
    }


    function getAltScore(altManual, altAuto, altMin, altMax, flags, altPenalty) {

        if (altManual < 0 && altAuto < 0)
            return -1;

        return Math.round(parseFloat(
                              (flags & (0x1 << 3)) && (flags & (0x1 << 4)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) + getMaxAltScore(altManual, altAuto, altMax, altPenalty) : (
                                                                                 (flags & (0x1 << 3)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) : (
                                                                                                            (flags & (0x1 << 4)) ? getMaxAltScore(altManual, altAuto, altMax, altPenalty) :
                                                                                                                                   -1))))
    }

    function getSGScore(sgManualVal, sgHitAuto, sgMaxScore) {

        return Math.round(parseFloat(sgManualVal < 0 ? sgHitAuto * sgMaxScore : sgManualVal * sgMaxScore));
    }

    function getTPScore(tpManualVal, tpHitAuto, tpMaxScore) {

        return Math.round(parseFloat(tpManualVal < 0 ? (tpHitAuto * tpMaxScore) : (tpManualVal * tpMaxScore)));
    }

    function getTGScore(tgTimeDifference, tgMaxScore, tgPenalty, tgTolerance) {

        return Math.round(parseFloat((tgTimeDifference > tgTolerance) ? Math.max(tgMaxScore - (tgTimeDifference - tgTolerance) * tgPenalty, 0) : tgMaxScore));
    }

    function getSpeedSectionScore(speedDiff, speedTolerance, speedMaxScore, speedPenalty) {

        return Math.round(parseFloat(Math.max(speedDiff > speedTolerance ? (speedMaxScore - (speedDiff - speedTolerance) * speedPenalty) : speedMaxScore, 0)));
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

        var score = Math.round(totalPointsScore/100 * gyre_penalty * circlingCountValue);

        if (totalPointsScore < 0) return 0; // unable to calc penalty percent from negative sum

        return (score === 0 ? 0 : score * -1);
    }

    function getOppositeDirScore(oppositeCountValue, oposite_direction_penalty, totalPointsScore) {

        var score = Math.round(totalPointsScore/100 * oposite_direction_penalty * oppositeCountValue);

        if (totalPointsScore < 0) return 0; // unable to calc penalty percent from negative sum

        return (score === 0 ? 0 : score * -1);
    }

    function getAltSecScore(manualAltMinEntriesCount, altMinEntriesCount, manualAltMaxEntriesCount, altMaxEntriesCount, altPenaltyPercent, totalPointsScore) {

        if (totalPointsScore < 0) return 0; // unable to calc penalty percent from negative sum

        var minCount = manualAltMinEntriesCount < 0 ? altMinEntriesCount : manualAltMinEntriesCount;
        var maxCount = manualAltMaxEntriesCount < 0 ? altMaxEntriesCount : manualAltMaxEntriesCount;

        return Math.round(((minCount + maxCount) * altPenaltyPercent * totalPointsScore/100) * -1);
    }

    function getSpaceSecScore(manualEntries_out, entries_out, spacePenaltyPercent, totalPointsScore) {

        if (totalPointsScore < 0) return 0; // unable to calc penalty percent from negative sum

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

        var imagePath = Qt.resolvedUrl(pathConfiguration.resultsFolder+"/"+item.fullName+".png");

        if ((item.score !== undefined) && (item.score !== "") && file_reader.file_exists(imagePath)) { // pokud je vypocitane, tak nepocitame znovu
            return;
        }

        if (tpiData.length > 0) {
            printMapWindow.makeImage();
        } else {
            console.log("tpiData.length <= 0")
        }

        // load manual values into list models - used when compute score
        loadStringIntoListModel(wptNewScoreListManualValuesCache, ctnt.prevResultsWPT, "; ");
        loadStringIntoListModel(speedSectionsScoreListManualValuesCache, ctnt.prevResultsSpeedSec, "; ");
        loadStringIntoListModel(spaceSectionsScoreListManualValuesCache, ctnt.prevResultsSpaceSec, "; ");
        loadStringIntoListModel(altSectionsScoreListManualValuesCache, ctnt.prevResultsAltSec, "; ");

        // load manual values from prev results cache
        contestantsListModel.setProperty(current, "markersOk", item.prevResultsMarkersOk);
        contestantsListModel.setProperty(current, "markersNok", item.prevResultsMarkersNok);
        contestantsListModel.setProperty(current, "markersFalse", item.prevResultsMarkersFalse);
        contestantsListModel.setProperty(current, "photosOk", item.prevResultsPhotosOk);
        contestantsListModel.setProperty(current, "photosNok", item.prevResultsPhotosNok);
        contestantsListModel.setProperty(current, "photosFalse", item.prevResultsPhotosFalse);
        contestantsListModel.setProperty(current, "startTimeMeasured", item.prevResultsStartTimeMeasured);
        contestantsListModel.setProperty(current, "landingScore", item.prevResultsLandingScore);
        //contestantsListModel.setProperty(current, "circlingCount", item.prevResultsCirclingCount);
        contestantsListModel.setProperty(current, "oppositeCount", item.prevResultsOppositeCount);
        contestantsListModel.setProperty(current, "otherPoints", item.prevResultsOtherPoints);
        contestantsListModel.setProperty(current, "otherPenalty", item.prevResultsOtherPenalty);
        contestantsListModel.setProperty(current, "pointNote", item.prevResultsPointNote);
        contestantsListModel.setProperty(current, "classify", item.prevResultsClassify);

        // calc new start time difference
        var sec = F.strTimeValidator(item.prevResultsStartTimeMeasured);
        var time;
        if (sec >= 0) { // valid time

            var refVal = F.timeToUnix(item.startTime);
            var diff = Math.abs(refVal - sec);

            contestantsListModel.setProperty(current, "startTimeDifference", F.addTimeStrFormat(diff));
        }

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

                        var already_intersected = (F.timeToUnix(tpiData[j].time) > 0); // measure only first intersection

                        if (angle_ok && !already_intersected) {
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
                                    section_speed_array[k].speed = Math.round(speed * 3.6); // m/s to km/h
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
                                        if ((point.lat === prevPoint.lat)&& (point.lon === prevPoint.lon)) {
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
                if (section.start === item.tid) {
                    speed = section.speed;
                    if (section.measure || (section.time_start === 0)) {
                        speed = '';
                    }
                }
            }

            for (var j = 0; j < section_alt_array_length; j++) {
                section = section_alt_array[j]
                if (section.start === item.tid) {
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
                if (section.start === item.tid) {
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

        var trHash = MD5.MD5(JSON.stringify(trItem));
        contestantsListModel.setProperty(current, "trackHash", trHash);
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

        var contestant = contestantsListModel.get(current);

        // save current results property
        contestantsListModel.setProperty(current, "prevResultsSpeed", contestant.speed);
        contestantsListModel.setProperty(current, "prevResultsStartTime", contestant.startTime);
        contestantsListModel.setProperty(current, "prevResultsCategory", contestant.category);
        contestantsListModel.setProperty(current, "prevResultsFilename", contestant.filename);
        contestantsListModel.setProperty(current, "prevResultsTrackHas", trHash);

        // set current values as prev results - used as cache when recomputing score
        saveCurrentResultValues(current, contestant);

        // save changes to CSV
        writeScoreManulaValToCSV();
        writeCSV()

        // gen new results sheet
        genResultsDetailTimer.showOnFinished = false;   // dont open results automatically
        genResultsDetailTimer.running = true;

        console.timeEnd("computeScore")
        return str;
    }

    function saveCurrentResultValues(ctntIndex, contestant) {

        contestantsListModel.setProperty(ctntIndex, "prevResultsWPT", contestant.wptScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsSpeedSec", contestant.speedSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsSpaceSec", contestant.spaceSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsAltSec", contestant.altitudeSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersOk", contestant.markersOk);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersNok", contestant.markersNok);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersFalse", contestant.markersFalse);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosOk", contestant.photosOk);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosNok", contestant.photosNok);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosFalse", contestant.photosFalse);
        contestantsListModel.setProperty(ctntIndex, "prevResultsStartTimeMeasured", contestant.startTimeMeasured);
        contestantsListModel.setProperty(ctntIndex, "prevResultsLandingScore", contestant.landingScore);
        //contestantsListModel.setProperty(ctntIndex, "circlingCount", item.prevResultsCirclingCount);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOppositeCount", contestant.oppositeCount);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOtherPoints", contestant.otherPoints);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOtherPenalty", contestant.otherPenalty);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPointNote", contestant.pointNote);
        contestantsListModel.setProperty(ctntIndex, "prevResultsClassify", contestant.classify);

    }

    function writeScoreManulaValToCSV() {

        if (contestantsTable.currentRow < 0)
            return;

        //header - from office
        var str = "\"Jmeno\";\"Znaky – ok\";\"Znaky – spatne\";\"Znaky – falesne\";\"Foto – ok\";\"Foto – spatne\";\"Foto – falesne\";\"Presnost pristani\";\"Ostatni – body\";\"Ostatni – procenta\";\"Cas startu – startovka\";\"Cas startu – zmereno\";\"Cas startu – penalizace body\";\"Krouzeni, protismerny let – pocet\";\"Krouzeni, protismerny let – penalizace body\";\"Ostatni penalizace – body\";\"Ostatni penalizace – procenta\";\"Body\";\"Body na 1000\";\"Klasifikovan\";\"Poznamka\";\"Casove brany\";\"Otocne body\";\"Prostorove brany\";\"Vyskove omezeni  penalizace\";\"Rychlostni useky\";\"Vyskove useky penalizace proc\";\"Prostorove useky penalizace proc\";\"Pilot ID\";\"Copilot ID\"";
        str += "\n";

        var igcListModelItem;

        var i;
        var j;
        var ct;
        var item;

        // Find classify field in igc for current contestant
        for (j = 0; j < contestantsListModel.count; j++) {

            // contestant item
            ct = contestantsListModel.get(j);

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
            str += "\"" + ct.startTimeScore + "\";"

            str += "\"" + (ct.circlingCount + ct.oppositeCount) + "\";"
            str += "\"" + Math.abs(ct.oppositeScore + ct.circlingScore) + "\";"

            str += "\"" + ct.otherPenalty + "\";"
            str += "\"" + 0 + "\";"

            str += "\"" + Math.max(ct.scorePoints, 0) + "\";"
            str += "\"" + Math.max(ct.scorePoints1000, 0) + "\";"

            var classify = ct.classify === 0 ? "yes" : "no";

            str += "\"" + classify + "\";"   //index 20

            //str += "\"" + F.addSlashes(ct.otherPointsNote) + "/&/" + F.addSlashes(ct.otherPenaltyNote) + "\";" //note delimeter
            str += "\"" + F.addSlashes(ct.pointNote) + "\";"

            str += "\"" + ct.tgScoreSum + "\";"
            str += "\"" + ct.tpScoreSum + "\";"
            str += "\"" + ct.sgScoreSum + "\";"
            str += "\"" + ct.altLimitsScoreSum + "\";"
            str += "\"" + ct.speedSecScoreSum + "\";"
            str += "\"" + ct.altSecScoreSum + "\";"
            str += "\"" + ct.spaceSecScoreSum + "\";"
            str += "\"" + (isNaN(parseInt(ct.pilot_id)) ? "-1" : ct.pilot_id) + "\";"
            str += "\"" + (isNaN(parseInt(ct.copilot_id)) ? "-1" : ct.copilot_id) + "\";"
            str += "\"" + F.addSlashes(ct.trackHash) + "\";"
            str += "\"" + ct.speed + "\";"
            str += "\"" + ct.startTime + "\";"
            str += "\"" + ct.category + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.wptScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.speedSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.spaceSectionsScoreDetails) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.altitudeSectionsScoreDetails) + "\";"
            str += "\"" + F.addSlashes(ct.filename) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.score) + "\";"
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
                    +"\";\""+ F.addSlashes(isNaN(parseInt(item.crew_id)) ? "-1" : item.crew_id)
                    +"\";\""+ F.addSlashes(isNaN(parseInt(item.pilot_id)) ? "-1" : item.pilot_id)
                    +"\";\""+ F.addSlashes(isNaN(parseInt(item.copilot_id)) ? "-1" : item.copilot_id)
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

        if (tracks === undefined || tracks.tracks === undefined) {
            return;
        }

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

    function compareBy21thColumn(a, b) {

        if (parseInt(a[21]) === parseInt(b[21])) {
            return 0;
        }
        else {
            return (parseInt(a[21]) > parseInt(b[21])) ? -1 : 1;
        }
    }

    function getContinuousResults() {

        var igcItem;
        var contestant;
        var index;

        // neni nactena trat
        if (tracks === undefined || tracks.tracks === undefined) {
            return;
        }

        var resArr = {};

        var trtr = tracks.tracks
        for (var i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            resArr[category_name] = [];
        }


        for (var i = 0; i < contestantsListModel.count; i++) {

            contestant = contestantsListModel.get(i);

            if (resArr[contestant.category] !== undefined) {
                var category_name = contestant.category
                resArr[category_name].push
                        ([
                             contestant.name,
                             contestant.category,
                             String(contestant.tgScoreSum),
                             String(contestant.tpScoreSum),
                             String(contestant.sgScoreSum),
                             String(contestant.altLimitsScoreSum),
                             String(contestant.speedSecScoreSum),
                             String(contestant.altSecScoreSum),
                             String(contestant.spaceSecScoreSum),
                             String(getMarkersScore(contestant.markersOk, 0, 0, contestant.marker_max_score)),
                             String(getMarkersScore(0, contestant.markersNok, 0, contestant.marker_max_score)),
                             String(getMarkersScore(0, 0, contestant.markersFalse, contestant.marker_max_score)),
                             String(getPhotosScore(contestant.photosOk, 0, 0, contestant.photos_max_score)),
                             String(getPhotosScore(0, contestant.photosNok, 0, contestant.photos_max_score)),
                             String(getPhotosScore(0, 0, contestant.photosFalse, contestant.photos_max_score)),
                             String(contestant.landingScore),
                             String(contestant.startTimeScore),
                             //String(contestant.circlingScore),
                             String(contestant.oppositeScore),
                             String(contestant.otherPoints),
                             String(contestant.otherPenalty),
                             String(contestant.scorePoints),
                             String(contestant.scorePoints1000)
                         ]);
                //(parseInt(igcItem.scorePoints) < 0 ? "" : String(igcItem.scorePoints)),
                //(parseInt(igcItem.scorePoints1000) < 0 ? "" : String(igcItem.scorePoints1000))])
            }
        }

        for (var i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            resArr[category_name].sort(compareBy21thColumn);

        }
        return resArr;
    }

    Timer {

        id: computingTimer
        interval: 1;
        repeat: false;
        running: false;

        property variant tpi;
        property variant polys;

        onTriggered: {

            computeScore(tpi, polys);
            running = false;
        }
    }

    Timer {
        id: resultsExporterTimer
        interval: 20;
        repeat: true;
        running: false;

        onTriggered: {

            if (contestantsListModel.count <= 0) {

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
            var contestant;

            contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

            // select first item of list
            if (current < 0) {

                current = 0;
                contestantsTable.selection.clear();
                contestantsTable.selection.select(current);
                contestantsTable.currentRow = current;

                // create contestant html file
                contestantsTable.generateResults(current, false);
            }
            else {

                // load contestant
                contestant = contestantsListModel.get(current);

                if (file_reader.file_exists(pathConfiguration.resultsFolder + "/"+ F.getContestantResultFileName(contestant.name, contestant.category) + ".html"))  { //if results created
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
                        contestantsTable.selection.select(current + 1)
                        contestantsTable.currentRow = current + 1;

                        // create contestant html file
                        contestantsTable.generateResults(current + 1, false);
                    }
                }
            }
        }
    }

    Timer {
        id: workingTimer
        repeat: true;
        running: false;
        interval: 1;

        property string action; //["pathOnOk", "refreshDialogOnOk", "refreshContestant", "showRegenMessageDialog", "sortlistModelByStartTime"]

        onTriggered: {

            switch(action) {

            case "showRegenMessageDialog":

                running = false;
                regenResultsMessage.open();
                action = "";

                break;

            case "pathOnOk":

                running = false;

                // save downloaded applications
                if (pathConfiguration.contestantsDownloadedString !== "") {

                    file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), pathConfiguration.contestantsDownloadedString);
                    pathConfiguration.contestantsDownloadedString = "";
                }

                // clear contestant in categories counters
                if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile ))) {
                    tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(pathConfiguration.trackFile )))

                    competitionClassModel.clear();
                    competitionClassModel.append({text:"-"})
                    for (var i = 0; i < tracks.tracks.length; i++) {
                        var category_name = tracks.tracks[i].name;
                        competitionClassModel.append({text: category_name})
                    }



                    // load VTB and preparation times
                    tracksVbtTimes = [];
                    tracksPrepTimes = [];

                    for (var t = 0; t < tracks.tracks.length; t++) {

                        trItem = tracks.tracks[t]

                        tracksVbtTimes[trItem.name] = trItem.conn[0] === undefined ? 0 : trItem.conn[0].addTime;
                        tracksPrepTimes[trItem.name] = trItem.preparation_time;
                    }

                } else {

                    //% "Track file"
                    errorMessage.title = qsTrId("trackFile-not-found-dialog-title");
                    //% "File %1 not found!"
                    errorMessage.text = qsTrId("trackFile-not-found-dialog-text").arg(pathConfiguration.trackFile);
                    errorMessage.open();
                }

                if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile))) {

                    loadContestants(Qt.resolvedUrl(pathConfiguration.contestantsFile))
                    loadPrevResults();
                }

                // load igc
                igcFolderModel.folder = "";
                igcFolderModel.folder = pathConfiguration.igcDirectory;

                recalculateContestantsScoreOrder();

                storeTrackSettings(pathConfiguration.tsFile);
                map.requestUpdate();

                // changed competition property, regenerate results only if needed
                if (pathConfiguration.prevSettingsMD5 != pathConfiguration.currentSettingsMD5){

                    running = true;
                    action = "showRegenMessageDialog";
                }
                else {
                    action = "";
                }

                // save manual values
                writeCSV();
                recalculateScoresTo1000();
                writeScoreManulaValToCSV();

                break;

            case "refreshDialogOnOk":

                running = false;

                // create one cotestant list models
                joinContestantsListModels();

                // load prev results
                loadPrevResults();

                // drop tmp list models
                unmodifiedContestants.clear();
                updatedContestants.clear();
                addedContestants.clear();
                removedContestants.clear();

                // save manual values
                writeCSV();
                recalculateScoresTo1000();
                writeScoreManulaValToCSV();

                // sort list model by startTime
                running = true;
                action = "sortlistModelByStartTime";

                break;

            case "sortlistModelByStartTime":

                running = false;

                // sort list model by startTime
                sortListModelByStartTime();

                action = "";
                break;

            case "refreshContestant":

                running = false;

                selectCompetitionOnlineDialog.refreshApplications();

                action = "";
                break;

            default:
                running = false;
                action = "";
                //console.log("working timer: unknown action: " + action)
                //running = false;

            }
        }
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
                if (current + 1 == contestantsListModel.count) { // finsihed
                    running = false;

                    regenerateResultsFile(); // toto tu musi byt, pri tom generovani se asi neco nesyncne a pak se vysedku generuji z prazdneho listmodelu

                } else { // go to next
                    contestantsTable.selection.clear();
                    contestantsTable.selection.select(current + 1)
                    contestantsTable.currentRow = current + 1;
                }
            }
        }
    }

    MessageDialog {
        id: errorMessage;
        icon: StandardIcon.Critical;
        modality: "ApplicationModal"
    }

    function regenerateResultsFile() {

        contestantsTable.selection.clear(); // clear selection - start on first row
        resultsExporterTimer.running = true;
    }

    MessageDialog {
        id: regenResultsMessage;
        icon: StandardIcon.Question;
        modality: "ApplicationModal"
        standardButtons: StandardButton.Yes | StandardButton.No

        //% "Regenerate results message title"
        title: qsTrId("regen-res-message-dialog-title");

        //% "Competition property has been changed. Do you want to regenerate results?"
        text: qsTrId("regen-res-message-dialog-text");

        onYes: {
            regenerateResultsFile();
        }

        onNo: {
            close();
        }
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
            if (config.get("v2_competitionName", "") === "") {

                // nothing in DB, load defaults
                pathConfiguration.competitionName = pathConfiguration.competitionName_default;
                pathConfiguration.competitionType = pathConfiguration.competitionType_default;
                pathConfiguration.competitionDirector = pathConfiguration.competitionDirector_default;
                pathConfiguration.competitionArbitr = pathConfiguration.competitionArbitr_default;
                pathConfiguration.competitionDate = pathConfiguration.competitionDate_default;
                pathConfiguration.competitionDirectorAvatar = pathConfiguration.competitionDirectorAvatar_default;
                pathConfiguration.competitionArbitrAvatar = pathConfiguration.competitionArbitrAvatar_default;
                pathConfiguration.competitionRound = pathConfiguration.competitionRound_default;
                pathConfiguration.competitionGroupName = pathConfiguration.competitionGroupName_default;

            }
            else {

                // set values from DB
                pathConfiguration.competitionName = config.get("v2_competitionName", pathConfiguration.competitionName_default);
                pathConfiguration.competitionType = config.get("v2_competitionType", pathConfiguration.competitionType_default);
                pathConfiguration.competitionDirector = config.get("v2_competitionDirector", pathConfiguration.competitionDirector_default);
                pathConfiguration.competitionArbitr = JSON.parse(config.get("v2_competitionArbitr", pathConfiguration.competitionArbitr_default));
                pathConfiguration.competitionDate = config.get("v2_competitionDate", pathConfiguration.competitionDate_default);
                pathConfiguration.competitionDirectorAvatar = JSON.parse(config.get("v2_competitionDirectorAvatar", pathConfiguration.competitionDirectorAvatar_default));
                pathConfiguration.competitionArbitrAvatar = JSON.parse(config.get("v2_competitionArbitrAvatar", pathConfiguration.competitionArbitrAvatar_default));
                pathConfiguration.competitionRound = config.get("v2_competitionRound", pathConfiguration.competitionRound_default);
                pathConfiguration.competitionGroupName = config.get("v2_competitionGroupName", pathConfiguration.competitionGroupName_default);
            }

            // init tmp var
            pathConfiguration.contestantsDownloadedString = "";

            // try to load last path settings
            var igcPrevCheckBox = 0;
            var trackPrevCheckBox = 0;
            var resultsFolderPrevCheckBox = 0;
            var onlineOfflinePrevCheckBox = 0;

            pathConfiguration.igcDirectory_user_defined = config.get("v2_igcDirectory_user_defined", "");
            pathConfiguration.resultsFolder_user_defined = config.get("v2_resultsFolder_user_defined", "");
            pathConfiguration.trackFile_user_defined = config.get("v2_trackFile_user_defined", "");
            pathConfiguration.selectedCompetition = config.get("v2_onlineOffline_user_defined", "");
            selectCompetitionOnlineDialog.selectedCompetitionId = config.get("v2_selectedCompetitionId", 0);
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

            // view settings
            mainViewMenuCompetitionPropertyStatusBar.checked = config.get("v2_mainViewMenuCompetitionPropertyStatusBar_checked", "no") === "yes" ? true : false;
            mainViewMenuCategoryCountersStatusBar.checked = config.get("v2_mainViewMenuCategoryCountersStatusBar_checked", "no") === "yes" ? true : false;
            mainViewMenuAltChart.checked = config.get("v2_mainViewMenuAltChart_checked", "no") === "yes" ? true : false;
            //            mainViewMenuContinuousResults.checked = config.get("v2_mainViewMenuContinuousResults_checked", "no") === "yes" ? true : false;
            mainViewMenuTables.checked = config.get("v2_mainViewMenuTables_checked", "yes") === "yes" ? true : false;

            // map view settings
            setMapView(config.get("v2_mapTypeExclusive", "main-map-menu-local"));

            // air space settings
            setAirspaceView(config.get("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-off"));
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
            // dont show regen results dialog - clean start od the application
            pathConfiguration.dontShowRegenResultsDialog = true;
            pathConfiguration.show();

            // view settings
            mainViewMenuCompetitionPropertyStatusBar.checked = false;
            mainViewMenuCategoryCountersStatusBar.checked = false;
            mainViewMenuAltChart.checked = false;
            //            mainViewMenuContinuousResults.checked = false;
            mainViewMenuTables.checked = true;
            config.set("v2_mainViewMenuTables_checked", mainViewMenuTables.checked ? "yes" : "no"); // set default as last selected value
            //            config.set("v2_mainViewMenuContinuousResults_checked", mainViewMenuContinuousResults.checked ? "yes" : "no"); // set default as last selected value
            config.set("v2_mainViewMenuAltChart_checked", mainViewMenuAltChart.checked ? "yes" : "no"); // set default as last selected value
            config.set("v2_mainViewMenuCategoryCountersStatusBar_checked", mainViewMenuCategoryCountersStatusBar.checked ? "yes" : "no"); // set default as last selected value
            config.set("v2_mainViewMenuCompetitionPropertyStatusBar_checked", mainViewMenuCompetitionPropertyStatusBar.checked ? "yes" : "no"); // set default as last selected value

            // map view settings
            setMapView("main-map-menu-local");
            config.set("v2_mapTypeExclusive", "main-map-menu-local"); // set default as last selected value

            // air space settings
            setAirspaceView("main-map-menu-airspace-off");
            config.set("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-off"); // set default as last selected value
        }
    }

    function setAirspaceView(airSpaceSettings) {

        airspaceOff.checked = false;
        airspaceProsoar.checked = false;
        airspaceLocal.checked = false;

        switch(airSpaceSettings) {
        case "main-map-menu-airspace-off":
            airspaceOff.checked = true;
            break;
        case "main-map-menu-airspace-prosoar":
            airspaceProsoar.checked = true;
            break;
        case "main-map-menu-airspace-local":
            airspaceLocal.checked = true;
            break;
        default:
        }
    }

    function setMapView(mapSettings) {

        mapNone.checked = false;
        mapLocal.checked = false;
        mapOsm.checked = false;
        mapGoogleRoadmap.checked = false;
        mapGoogleTerrain.checked = false;
        mapGoogleSatelite.checked = false;
        mapCustom.checked = false;

        switch(mapSettings) {
        case "main-map-menu-none":
            mapNone.checked = true;
            break;
        case "main-map-menu-local":
            mapLocal.checked = true;
            break;
        case "main-map-menu-osm":
            mapOsm.checked = true;
            break;
        case "main-map-menu-google-roadmap":
            mapGoogleRoadmap.checked = true;
            break;
        case "main-map-menu-google-terrain":
            mapGoogleTerrain.checked = true;
            break;
        case "main-map-menu-google-satellite":
            mapGoogleSatelite.checked = true;
            break;
        case "main-map-menu-custom-tile-layer":
            mapCustom.checked = true;
            break;
        default:
        }
    }

    MessageDialog {
        id: contestnatsNotFoundMessage;
        icon: StandardIcon.Critical;

        standardButtons: StandardButton.Yes | StandardButton.Cancel

        onButtonClicked: {

            if (clickedButton === StandardButton.Yes) {

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
                var i;
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

                    for (i = 0; i < contestantsListModel.count; i++) {
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
                        for (i = 0; i < igcFilesModel.count; i++) {
                            var item = igcFilesModel.get(i);
                            if (item.contestant === 0) {
                                igc_index = i;
                                break;
                            }
                        }
                    } else {
                        for (i = 0; i < igcFilesModel.count; i++) {
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

    Component.onCompleted: {
        startUpMessage.open();  // clean or reload prev settings
    }
}
