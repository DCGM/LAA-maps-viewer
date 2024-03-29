import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.2
import cz.mlich 1.0
import "functions.js" as F
import "geom.js" as G
import "csv.js" as CSVJS
import "md5.js" as MD5
import "./components"

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


    onClosing: {
        writeAllNow()
        console.log("Quitting app")

    }

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
                onTriggered: {
                    writeAllNow()
                    console.log("Quitting app")
                    Qt.quit()
                }
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
                        map.maxZoomLevel = 19
                        map.attribution = ""

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
                        setLocalPath()

                    }
                }

                shortcut: "Ctrl+2"

                function setLocalPath() {
                    var homepath = QStandardPathsHomeLocation+"/Maps/OSM/"
                    var binpath = QStandardPathsApplicationFilePath +"/../Maps/OSM/";
                    map.url_subdomains = [];
                    map.maxZoomLevel = 19
                    map.attribution = ""

                    if (file_reader.is_dir_and_exists_local(binpath)) {
                        map.url = "file:///"+binpath + "%(zoom)d/%(x)d/%(y)d.png"
                    } else if (file_reader.is_dir_and_exists_local(homepath)) {
                        map.url = "file:///"+homepath + "%(zoom)d/%(x)d/%(y)d.png"
                    } else {
                        map.url = "";
                        console.warn("local map not found")
                    }
                    console.log(map.url);
                }


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
                        map.url = "https://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
                        map.url_subdomains = ['a','b', 'c'];
                        map.maxZoomLevel = 19
                        map.attribution = "data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, " +
                        "<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, "
                        "Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"

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
                        map.url = "https://%(s)d.google.com/vt/lyrs=m@248407269&hl=x-local&x=%(x)d&y=%(y)d&z=%(zoom)d&s=Galileo"
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                        map.maxZoomLevel = 19
                        map.attribution = "data &copy; Google"

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
                        map.url = "https://%(s)d.google.com/vt/lyrs=t,r&x=%(x)d&y=%(y)d&z=%(zoom)d"
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                        map.maxZoomLevel = 19
                        map.attribution = "data &copy; Google"

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
                        map.url = 'https://%(s)d.google.com/vt/lyrs=s&x=%(x)d&y=%(y)d&z=%(zoom)d';
                        map.url_subdomains = ['mt0','mt1','mt2','mt3']
                        map.maxZoomLevel = 19
                        map.attribution = "data &copy; Google"

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
                        map.attribution = ""

                    }
                }

                shortcut: "Ctrl+7"
            }

            MenuItem {
                //% "Databáze letišť"
                text: qsTrId("main-map-menu-databaze-letist")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                property string homePath: QStandardPathsHomeLocation+"/Maps/DL/"
                property string binPath: QStandardPathsApplicationFilePath +"/../Maps/DL/"
                visible: file_reader.is_dir_and_exists_local(binPath) || file_reader.is_dir_and_exists_local(homePath)
                onTriggered: {

                    map.url_subdomains = [];
                    map.maxZoomLevel = 19
                    if (file_reader.is_dir_and_exists_local(binPath)) {
                        console.log("local map " + binPath)
                        map.url = Qt.resolvedUrl("file:///"+binPath) + "%(zoom)d/%(x)d/%(y)d.png"
                    } else if (file_reader.is_dir_and_exists_local(homePath)) {
                        console.log("local map " + homePath)
                        map.url = Qt.resolvedUrl("file:///"+homePath) + "%(zoom)d/%(x)d/%(y)d.png"
                    } else {
                        map.url = "";
                        console.warn("local map not found")
                    }

                    map.url_subdomains = []
                    map.maxZoomLevel = 13
                    map.attribution = "&copy; Databáze Letišť"
                }
                shortcut: "Ctrl+8"
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
                        map.airspaceAttribution = ""
                    }
                }
            }

            MenuItem {
                id: airspaceProsoar
                //% "Airspace (skylines.aero)"
                text: qsTrId("main-map-menu-airspace-prosoar")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    config.set("v2_mapTypeSecondaryExclusive", "main-map-menu-airspace-prosoar");
                }
                onCheckedChanged: {
                    if (checked) {
                        map.airspaceUrl = "https://skylines.aero/mapproxy/tiles/1.0.0/airspace+airports/EPSG3857/%(zoom)d/%(x)d/%(y)d.png"
                        map.mapAirspaceVisible = true;
                        map.airspaceAttribution = "&copy; skylines.aero"
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
                        setLocalPath();
                    }
                }

                function setLocalPath() {
                    var homepath = QStandardPathsHomeLocation+"/Maps/airspace/tiles/"
                    var binpath = QStandardPathsApplicationFilePath +"/../Maps/airspace/tiles/";
                    map.url_subdomains = [];
                    map.airspaceAttribution = ""

                    if (file_reader.is_dir_and_exists_local(binpath)) {
                        map.airspaceUrl = "file:///"+binpath + "%(zoom)d/%(x)d/%(y)d.png"
                        map.mapAirspaceVisible = true;

                    } else if (file_reader.is_dir_and_exists_local(homepath)) {
                        map.airspaceUrl = "file:///"+homepath + "%(zoom)d/%(x)d/%(y)d.png"
                        map.mapAirspaceVisible = true;
                    } else {
                        map.airspaceUrl = "";
                        map.mapAirspaceVisible = false;
                        console.warn("local map not found")
                    }
                    console.log(map.airspaceUrl)
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
                //% "Select position"
                text: qsTrId("main-view-menu-mark-position")
                onTriggered: map.triggerSelectPosition();
                enabled: contestantsTable.selection.count === 1;
                shortcut: "Space"
            }

            MenuItem {
                //% "Center to position"
                text: qsTrId("main-view-menu-zoom-to-position")
                onTriggered: map.setCenterLatLon(map.currentPositionLat, map.currentPositionLon)
                shortcut: "Ctrl+9"
                enabled: (igc.count > 0);
            }

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
                shortcut: "Ctrl++"
            }
            MenuItem {
                //% "Zoom &out"
                text: qsTrId("main-view-menu-zoom-out")
                onTriggered: map.zoomOut();
                shortcut: "Ctrl+-"
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
                id: mainViewMenuClipIgc
                //% "Clip GPS log"
                text: qsTrId("main-view-menu-clip-igc")
                checkable: true;
                checked: true; // default
                onCheckedChanged: {
                    contestantsTable.rowSelected();
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
                shortcut: "F1"
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

        text: "https://m3.mapserver.mapy.cz/ophoto-m/%(zoom)d-%(x)d-%(y)d"
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
                console.log("unmodifiedContestants contestantsListModel.append")

            }
        }

        for(i = 0; i < removedContestants.count; i++) {
            item = removedContestants.get(i);

            if (item.selected) {
                contestantsListModel.append(item);
                console.log("removedContestants contestantsListModel.append")

            }
        }

        for(i = 0; i < addedContestants.count; i++) {
            item = addedContestants.get(i);

            if (item.selected) {
                contestantsListModel.append(item);
                console.log("addedContestants contestantsListModel.append")

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
                console.log("updatedContestants contestantsListModel.append")
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
        id: createContestantMenu;

        property bool menuVisible: false

        MenuItem {
            //% "Create crew"
            text: qsTrId("scorelist-table-menu-append-contestant")
            enabled: (tracks !== undefined)

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
            enabled: (tracks !== undefined)

            onTriggered: {
                updateContestantMenu.openFormForEdit();
            }
        }

        MenuItem {
            //% "Create crew"
            text: qsTrId("scorelist-table-menu-append-contestant")
            enabled: (tracks !== undefined)

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
            enabled: (tracks !== undefined)

            onTriggered: {

                var conte = contestantsListModel.get(updateContestantMenu.row);

                // deselect row
                contestantsTable.selection.clear();

                // remove item from listmodel
                contestantsListModel.remove(updateContestantMenu.row, 1);

                // save results into CSV
                writeAllRequest();
            }
        }

        MenuItem {
            //% "Recalculate"
            text: qsTrId("scorelist-table-menu-recalculate-score")
            onTriggered: {
                contestantsTable.recalculateResults(updateContestantMenu.row);
            }
        }

        MenuItem {
            //% "Generate contestant results"
            text: qsTrId("scorelist-table-menu-generate-contestant-results")
            onTriggered: {
                console.log(updateContestantMenu.selectedRow+", "+true)
                contestantsTable.generateResults(updateContestantMenu.row, true);
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

                        if (tracks.tracks[t].name === contestant.category) {
                            trItem = tracks.tracks[t]
                        }
                    }
                }

                // reload update ctnt
                contestant = contestantsListModel.get(row);

                // no results for this values
                if (!applyPrevResultsSingle(row, contestant)) { // does resultsValid()

                    contestantsListModel.setProperty(row, "score", "");        //compute new score
                    contestantsListModel.setProperty(row, "scorePoints", -1);
                    contestantsListModel.setProperty(row, "scorePoints1000", -1);
                    //contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
                    //contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
                    //contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
                    //contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
                    contestantsListModel.setProperty(row, "score_json", "");
                    contestantsListModel.setProperty(row, "trackHash", "");

                    console.log("Recompute score for " + contestant.name + " (filename === \"\" || !resultValid)");

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
            writeAllRequest();

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

        Item {
            id: splitViewIgcResults
            width: Math.min(Math.max(applicationWindow.width *0.9, 100) , 1090);
            height: parent.height
            visible: mainViewMenuTables.checked

            ////
            TableView {
                id: contestantsTable;
                model: contestantsListModel;
                width: parent.width;
                height: parent.height;
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

                MouseArea {
                    anchors.fill: parent;
                    acceptedButtons: Qt.RightButton
                    enabled: (contestantsListModel.count == 0)

                    onClicked: {
                        createContestantMenu.popup();
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

                    console.log("selected row " +current + ": " + ctnt.name + " " +ctnt.startTime);


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
                    } else {

                        //                console.log("setFilter" + ctnt.startTime)
                        tool_bar.startTime = ctnt.startTime;

                        var filePath = pathConfiguration.igcDirectory + "/" + ctnt.filename;
                        if (file_reader.file_exists(Qt.resolvedUrl(filePath))) {
                            var clipStartTime = mainViewMenuClipIgc.checked ? ctnt.startTime : "00:00:00" ;
                            igc.load( file_reader.toLocal(Qt.resolvedUrl(filePath)), clipStartTime , mainViewMenuClipIgc.checked);
                            errorLine.text = "";
                        } else {
                            console.log(ctnt.name + ": igc file \"" + ctnt.filename + "\" doesn't exists")
                            if (ctnt.filename !== "") {
                                //% "Cannot read file '%1'"
                                errorLine.text = qsTrId("file-list-cannot-read-file-error").arg(ctnt.filename)
                            } else {
                                errorLine.text = "";
                            }

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
                    //% "Time gates score"
                    title: qsTrId("filelist-table-tgScoreSum");
                    role: "tgScoreSum"
                    width: 80
                }
                TableViewColumn {
                    //% "Score"
                    title: qsTrId("filelist-table-score")
                    role: "scorePoints"
                    width: 60
                }
                TableViewColumn {
                    //% "Score to 1000"
                    title: qsTrId("filelist-table-score-to-1000")
                    role: "scorePoints1000"
                    width: 60
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
                        contestantsListModel.setProperty(row, "poly_results", curentContestant.poly_results);
                        contestantsListModel.setProperty(row, "circling_results", curentContestant.circling_results);

                        contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", curentContestant.spaceSectionsScoreDetails);
                        contestantsListModel.setProperty(row, "selectedPositions", curentContestant.selectedPositions);

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
                        new_contestant.poly_results = curentContestant.poly_results;
                        new_contestant.circling_results = curentContestant.circling_results;

                        new_contestant.spaceSectionsScoreDetails = curentContestant.spaceSectionsScoreDetails;
                        new_contestant.selectedPositions = curentContestant.selectedPositions;


                        // append into list model
                        contestantsListModel.append(new_contestant);
                        console.log("contestantsListModel.append(new_contestant);")
                        row = contestantsListModel.count - 1;


                    }

                    // set current values as prev results - used as cache when recomputing score
                    saveCurrentResultValues(row, ctnt);

                    // used instead of the append due to some post processing (call some on change method)
                    contestantsListModel.changeLisModel(row, "category", curentContestant.category);
                    contestantsListModel.changeLisModel(row, "speed", parseInt("0"+curentContestant.speed, 10));
                    contestantsListModel.changeLisModel(row, "startTime", curentContestant.startTime);

                    // recalculate score
                    var score = getTotalScore(row);
                    contestantsListModel.setProperty(row, "scorePoints", score);
                    recalculateScoresTo1000();

                    // save changes into CSV
                    writeAllRequest();

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
                onClickedMeasuredTime: {
                    map.currentPositionTimeUnix = time;
                }
                onSelectedPointsChaged: {
                    map.requestUpdate();
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
                currentPositionShow: (igc.count > 0);
                selectedPoints: resultsDetailComponent.currentSelectedPositionsListAlias

                onTpiComputedData:  {
                    if (!updateContestantMenu.menuVisible && !resultsDetailComponent.visible && !resultsExporterTimer.running) {
                        //computeScore(tpi, polys)
                        computingTimer.tpi = tpi;
                        computingTimer.polys = polys;

                        computingTimer.running = true;
                    }
                }

                onSelectPosition: {

                    var current = -1;
                    contestantsTable.selection.forEach( function(rowIndex) { current = rowIndex; } )
                    if (current < 0) {
                        return;
                    }

                    var con = contestantsListModel.get(current);

                    var positions = [];
                    if ((con.selectedPositions !== undefined) && (con.selectedPositions !== "undefined") && (con.selectedPositions !== "")) {
                        try {
                            positions = JSON.parse(con.selectedPositions);
                        } catch(err) {
                            console.error(err)
                        }
                    }

                    var item = {}
                    var pos_index = -1;
                    for(var i = 0 ; i < positions.length; i++) {
                        item = positions[i];
                        if (item.gpsindex === gpsindex) {
                            pos_index = i;
                            break;
                        }
                    }
                    if (pos_index === -1) {
                        item = {
                            "gpsindex" : gpsindex,
                            "lat" : lat,
                            "lon" : lon,
                            "time" : time,
                            "alt" : alt,
                            "azimuth" : azimuth,
                            "distanceprev": 0,
                            "timetoprev": 0,
                            "timetoprev_str": "00:00:00",
                            "pointName": "",
                            "minDistance": 0,
                            "minTime": "",
                            "maxDistance": 0,
                            "maxTime": "",
                        }
                        positions.push(item);
                        console.log("positions added " + positions.length)
                    } else {
                        var removed = positions.splice(pos_index,1);
                        console.log("positions removed " + pos_index)
                    }

                    if (resultsDetailComponent.visible) {
                        var m = resultsDetailComponent.currentSelectedPositionsListAlias;
                        var found = false;
                        for (i = 0; i < m.count; i++) {
                            var search_item = m.get(i)
                            if (search_item.gpsindex === gpsindex) {
                                m.remove(i);
                                found = true;
                            }
                        }
                        if (!found) {
                            m.append(item)
                        }

                    }

                    contestantsListModel.setProperty(current, "selectedPositions", JSON.stringify(positions))

//                    console.log("Measured position at: " + JSON.stringify(positions));

                    writeAllRequest();
                }

                // navigation icons
                PinchMapControls {
                    anchors.right: parent.right;
                    anchors.bottom: parent.bottom;
                    onZoomIn: map.zoomIn();
                    onZoomOut: map.zoomOut();
                    onPanToMyPosition: map.pointsInBounds()
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
        console.log("contestantsTableShowResultsDialog " + row)

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

    // load data but don't show them
    IgcFile {
        id: igc_helper;
        onCountChanged: {
            if (count === 0) {
                return;
            }
        }
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
        id: writeAllTimer
        interval: 10000;
        running: true;
        repeat: true;
        property bool shoot: false;
        onTriggered: {
            if (!shoot) {
                return;
            }
            shoot = false;
            console.log("writeAllTimer.triggered")

            if (genResultsDetailTimer.running
                    || computingTimer.running
                    || resultsExporterTimer.running
                    || workingTimer.running
                    || evaluateTimer.running
                    ) {
                console.log("other timer running, skipping write")
                return;
            }
            writeAllNow();
        }
    }

    Timer {
        id: genResultsDetailTimer
        running: false;
        interval: 20;

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
            writeAllRequest();
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
                    text: G.formatCoordinate(map.currentPositionLat, map.currentPositionLon, {coordinateFormat: "DMS"})
                    visible: map.currentPositionShow

                }

                NativeText {
                    text: map.currentPositionAltitude + " m";
                    visible: map.currentPositionShow
                }

                NativeText {
                    // text: G.formatDistance(map.rulerDistance, {'distanceUnit':'m'})
                    text: parseFloat(map.rulerDistance).toFixed(1)+ " m"
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
                    //% "Trimmed takeoff %n"
                    text: qsTrId("toolbar-trimmed-fixes", igc.trimmedCount);
                    visible: igc.trimmedCount > 0;
                }

                NativeText {
                    //% "Trimmed landing %n"
                    text: qsTrId("toolbar-trimmed-end-fixes", igc.trimmedEndCount);
                    visible: igc.trimmedEndCount > 0;
                }

                NativeText {
                    //% "Fixes %n"
                    text: qsTrId("toolbar-igc-count", igc.count)
                    visible: (igc.count + igc.trimmedCount + igc.invalidCount) > 0
                    font.bold: (igc.count < 500);
                    color: (igc.count < 500) ? "red" : "black"
                }

                NativeText {
                    id: errorLine
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
        igcFilesModel.setProperty(igcRow, "classify", (conntestantIndex === 0) ? -1 : contestant.prevResultsClassify);
        igcFilesModel.setProperty(igcRow, "aircraftRegistration", contestant.aircraft_registration);
    }

    // Compare results current and prev results property
    function resultsValid(currentSpeed, currentStartTime, currentCategory, currentIgcFilename, currentTrackHash,
                          prevSpeed, prevStartTime, prevCategory, prevIgcFilename, prevTrackHash) {

        return (currentStartTime === prevStartTime &&
                parseInt(currentSpeed, 10) === parseInt(prevSpeed, 10) &&
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
            "selectedPositions": "[]",

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
            "prevPoly_results": "",
            "prevCircling_results": "",

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
            "poly_results": "",
            "circling_results": "",
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

    function loadContestants(filename) { // posadky.csv
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
        } else {
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
                console.log("loadContestants: contestantsListModel.append("+item[2]+")")
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
                            currentCrew.startTime !== (F.timeToUnix(currentCrew.newStartTime) === -1 ? F.addTimeStrFormat(0) : currentCrew.newStartTime) ||
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

                if (pilotID_resCSV !== -1) { // search by id
                    if (pilotID_resCSV === parseInt(curCnt.pilot_id, 10)) {
                        index = j;
                        break;
                    }
                } else { // locally added crew - search by name (id should by -1)

                    if ((pilotName_resCSV === curCnt.name) && (pilotID_resCSV === -1)) {
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
                curCnt.prevResultsClassify = (csvFileFromOffice ? (resultsCSV[j][19] === "yes" ? 0 : 1) : 0);

                console.log(resultsCSV[j][0] + " " + (curCnt.prevResultsClassify ? "no" : "yes") + " " +resultsCSV[j][19])

                curCnt.filename = (csvFileFromViewer && curCnt.filename === "" ? resultsCSV[j][38] : curCnt.filename);

                // manual values
                curCnt.prevResultsMarkersOk = (csvFileFromOffice ? parseInt(resultsCSV[j][1]) : 0);
                curCnt.prevResultsMarkersNok = (csvFileFromOffice ? parseInt(resultsCSV[j][2]) : 0);
                curCnt.prevResultsMarkersFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][3]) : 0);
                curCnt.prevResultsPhotosOk = (csvFileFromOffice ? parseInt(resultsCSV[j][4]) : 0);
                curCnt.prevResultsPhotosNok = (csvFileFromOffice ? parseInt(resultsCSV[j][5]) : 0);
                curCnt.prevResultsPhotosFalse = (csvFileFromOffice ? parseInt(resultsCSV[j][6]) : 0);
                curCnt.prevResultsStartTimeMeasured = (csvFileFromOffice ? resultsCSV[j][11] : "");
//                console.log("crew / curCnt.prevResultsStartTimeMeasured: " + curCnt.name + " / " + curCnt.prevResultsStartTimeMeasured )
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
                curCnt.prevPoly_results = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][48]) : "");
                curCnt.prevCircling_results = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][49]) : "");
                curCnt.selectedPositions = (csvFileFromViewer ? F.replaceSingleQuotes(resultsCSV[j][50]) : "");

                // check results validity due to the contestant values
                if (resultsValid(curCnt.speed, curCnt.startTime, curCnt.category, curCnt.filename, MD5.md5(JSON.stringify(trItem)),
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

                }

                // save changes
                contestantsListModel.set(i, curCnt);
            }
        }
    }

    function applyPrevResults() {
        for (var i = 0; i < contestantsListModel.count; i++) {
            var contestant = contestantsListModel.get(i)
            applyPrevResultsSingle(i, contestant);
        }
    }

    function applyPrevResultsSingle(row, contestant) {
        // load contestant category
        var trItem = [];
        if (tracks === undefined || tracks.tracks === undefined) {
            console.error("Cannot load tracks")
            return;
        }

        for (var t = 0; t < tracks.tracks.length; t++) {

            if (tracks.tracks[t].name === contestant.category) {
                trItem = tracks.tracks[t];
            }
        }
        var valid = (contestant.filename !== "" && resultsValid(contestant.speed,
                                                        contestant.startTime,
                                                        contestant.category,
                                                        contestant.filename,
                                                        MD5.md5(JSON.stringify(trItem)),
                                                        contestant.prevResultsSpeed,
                                                        contestant.prevResultsStartTime,
                                                        contestant.prevResultsCategory,
                                                        contestant.prevResultsFilename,
                                                        contestant.prevResultsTrackHas));
        if (valid) {

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
//            contestantsListModel.setProperty(row, "circlingCount", contestant.prevResultsCirclingCount);
            contestantsListModel.setProperty(row, "oppositeCount", contestant.prevResultsOppositeCount);
            contestantsListModel.setProperty(row, "otherPoints", contestant.prevResultsOtherPoints);
            contestantsListModel.setProperty(row, "otherPenalty", contestant.prevResultsOtherPenalty);
            contestantsListModel.setProperty(row, "pointNote", contestant.prevResultsPointNote);

            contestantsListModel.setProperty(row, "trackHash", contestant.prevResultsTrackHas);
            contestantsListModel.setProperty(row, "wptScoreDetails", contestant.prevResultsWPT);
            contestantsListModel.setProperty(row, "speedSectionsScoreDetails", contestant.prevResultsSpeedSec);
            contestantsListModel.setProperty(row, "spaceSectionsScoreDetails", contestant.prevResultsSpaceSec);
            contestantsListModel.setProperty(row, "altitudeSectionsScoreDetails", contestant.prevResultsAltSec);
//            console.log ("prevPolyResults"contestant.prevPoly_results)
            contestantsListModel.setProperty(row, "poly_results", contestant.prevPoly_results);
            contestantsListModel.setProperty(row, "circling_results", contestant.prevCircling_results);
            contestantsListModel.setProperty(row, "selectedPositions", contestant.selectedPositions);
            contestantsListModel.setProperty(row, "score_json", contestant.prevResultsScoreJson)
            contestantsListModel.setProperty(row, "score", contestant.prevResultsScore)
            contestantsListModel.setProperty(row, "scorePoints", contestant.prevResultsScorePoints);
        }

        return valid;
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
            if (!Array.isArray(catArray)) {
                continue;
            }

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

        file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + resultsFilename + ".csv"), Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + pathConfiguration.competitionName + "_" + resultsFilename + ".csv~"))
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
            tgScoreSum = Math.round(tgScoreSum)
            sgScoreSum = Math.round(sgScoreSum)
            tpScoreSum = Math.round(tpScoreSum)
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
        speedSecScoreSum = Math.round(speedSecScoreSum);

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

        var ctnt = contestantsListModel.get(row);

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

    function perfromance_class_from_category(category) {
        var performance_class = String(category);
        if (performance_class.match(/-/)) {
            performance_class = performance_class.split("-")[0];
        }
        return performance_class;

    }

    // recalculate score points to 1000
    function recalculateScoresTo1000() {
        console.log("recalculateScoresTo1000()")

        if (tracks === undefined) {
            return;
        }

        var i, item;
        maxPointsArr = {};
        var performance_class;

        var trtr = tracks.tracks
        for (i = 0; i < trtr.length; i++) {
            maxPointsArr[perfromance_class_from_category(trtr[i].name)] = 1;
        }

        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i)
            performance_class = perfromance_class_from_category(item.category);

            if (maxPointsArr[performance_class] < item.scorePoints && !item.classify) {
                maxPointsArr[performance_class] = item.scorePoints;
            }
        }


        for (i = 0; i < contestantsListModel.count; i++) {
            item = contestantsListModel.get(i)

            // classify set as NO
            if (item.classify) {
                contestantsListModel.setProperty(i, "scorePoints1000", -1);
                continue;
            }
            performance_class = perfromance_class_from_category(item.category)

            if (item.scorePoints >= 0) {
                contestantsListModel.setProperty(i, "scorePoints1000", Math.round(item.scorePoints/maxPointsArr[performance_class] * 1000));
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

            if (item.scorePoints1000 >= 0) {
                pushIfNotExistScorePoints(item.category, item.scorePoints1000);
            }
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

        if (categoriesScorePoints[category].indexOf(score) === -1) {
            categoriesScorePoints[category].push(parseInt(score));
        }
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

        if (altManual < 0 && altAuto < 0) {
            return -1;
        }

        return parseFloat(
                              (flags & (0x1 << 3)) && (flags & (0x1 << 4)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) + getMaxAltScore(altManual, altAuto, altMax, altPenalty) : (
                                                                                 (flags & (0x1 << 3)) ? getMinAltScore(altManual, altAuto, altMin, altPenalty) : (
                                                                                                            (flags & (0x1 << 4)) ? getMaxAltScore(altManual, altAuto, altMax, altPenalty) :
                                                                                                                                   -1)));
    }

    function getSGScore(sgManualVal, sgHitAuto, sgMaxScore) {
        return parseFloat(sgManualVal < 0 ? sgHitAuto * sgMaxScore : sgManualVal * sgMaxScore);
    }

    function getTPScore(tpManualVal, tpHitAuto, tpMaxScore) {
        return parseFloat(tpManualVal < 0 ? (tpHitAuto * tpMaxScore) : (tpManualVal * tpMaxScore));
    }

    function getTGScore(tgTimeDifference, tgMaxScore, tgPenalty, tgTolerance) {
        return parseFloat((tgTimeDifference > tgTolerance) ? Math.max(tgMaxScore - (tgTimeDifference - tgTolerance) * tgPenalty, 0) : tgMaxScore);
    }

    function getSpeedSectionScore(speedDiff, speedTolerance, speedMaxScore, speedPenalty) {
        return parseFloat(Math.max(speedDiff > speedTolerance ? (speedMaxScore - (speedDiff - speedTolerance) * speedPenalty) : speedMaxScore, 0));
    }

    function getMarkersScore(markersOk, markersNok, markersFalse, marker_max_score) {

        return markersOk * marker_max_score - (markersNok + markersFalse) * marker_max_score;
    }

    function getPhotosScore(photosOk, photosNok, photosFalse, photos_max_score) {

        return photosOk * photos_max_score - (photosNok + photosFalse) * photos_max_score;
    }

    function getTakeOffScore(startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore) {

        var tdiff = F.timeToUnix(startTimeDifferenceText);
        if ((tdiff > time_window_size) || (tdiff < 0)) {
            return Math.round(totalPointsScore/100 * time_window_penalty) * -1;
        } else {
            return 0;
        }
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

        if (totalPointsScore < 0) {
            return 0; // unable to calc penalty percent from negative sum
        }

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

        var contestant = contestantsListModel.get(current)

        // no igc assigned
        if ((contestant.filename === undefined) || (contestant.filename === "")) {
            console.log("contestant.filename not assigned")
            return;
        }

        var imagePath = Qt.resolvedUrl(pathConfiguration.resultsFolder+"/"+contestant.fullName+".png");

        if ((contestant.score !== undefined) && (contestant.score !== "") && file_reader.file_exists(imagePath)) { // pokud je vypocitane, tak nepocitame znovu
            console.log("contestant.score is defined and imagePath exists");
            return;
        }


        if (tpiData.length > 0) {
            printMapWindow.makeImage();
        } else {
            console.log("tpiData.length <= 0")
        }

        trItem = [];

        // load contestant category
        if (tracks !== undefined && tracks.tracks !== undefined) {

            for (var t = 0; t < tracks.tracks.length; t++) {

                if (tracks.tracks[t].name === contestant.category) {
                    trItem = tracks.tracks[t]
                }
            }
        }

        // load manual values into list models - used when compute score
        loadStringIntoListModel(wptNewScoreListManualValuesCache, (contestant.prevResultsWPT !== undefined) ? ctnt.prevResultsWPT : '', "; ");
        loadStringIntoListModel(speedSectionsScoreListManualValuesCache, contestant.prevResultsSpeedSec, "; ");
        loadStringIntoListModel(spaceSectionsScoreListManualValuesCache, contestant.prevResultsSpaceSec, "; ");
        loadStringIntoListModel(altSectionsScoreListManualValuesCache, contestant.prevResultsAltSec, "; ");

        // load manual values from prev results cache
        contestantsListModel.setProperty(current, "markersOk", contestant.prevResultsMarkersOk);
        contestantsListModel.setProperty(current, "markersNok", contestant.prevResultsMarkersNok);
        contestantsListModel.setProperty(current, "markersFalse", contestant.prevResultsMarkersFalse);
        contestantsListModel.setProperty(current, "photosOk", contestant.prevResultsPhotosOk);
        contestantsListModel.setProperty(current, "photosNok", contestant.prevResultsPhotosNok);
        contestantsListModel.setProperty(current, "photosFalse", contestant.prevResultsPhotosFalse);
        contestantsListModel.setProperty(current, "startTimeMeasured", contestant.prevResultsStartTimeMeasured);
        contestantsListModel.setProperty(current, "landingScore", contestant.prevResultsLandingScore);
        //contestantsListModel.setProperty(current, "circlingCount", contestant.prevResultsCirclingCount);
        contestantsListModel.setProperty(current, "oppositeCount", contestant.prevResultsOppositeCount);
        contestantsListModel.setProperty(current, "otherPoints", contestant.prevResultsOtherPoints);
        contestantsListModel.setProperty(current, "otherPenalty", contestant.prevResultsOtherPenalty);
        contestantsListModel.setProperty(current, "pointNote", contestant.prevResultsPointNote);
        contestantsListModel.setProperty(current, "classify", contestant.prevResultsClassify);

        // calc new start time difference
        var sec = F.timeToUnix(contestant.prevResultsStartTimeMeasured);
        var time;
        if (sec > 0) { // valid time

            var refVal = F.timeToUnix(contestant.startTime);
            var diff = (sec - refVal);
            contestantsListModel.setProperty(current, "startTimeDifference", F.addTimeStrFormat(diff));
        } else {
            // if prevResultsStartTimeMeasured not valid, difference is not valid -> no penalty
            contestantsListModel.setProperty(current, "startTimeDifference", "");
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

        var circling_results = [];

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
                section_speed_array.push({
                                             "start": section_speed_start_tid,
                                             "end": ti.tid,
                                             "distance": distance_cumul,
                                             "time_start": 0,
                                             "time_end": 0,
                                             "time_diff": 0,
                                             "speed": 0,
                                             "startName": startPointName,
                                             "endName": ti.name
                                         });
                section_speed_start_tid = -1;
            }

            if (section_alt_end && (section_alt_start_tid >= 0)) {
                section_alt_array.push({
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
                                       });
                section_alt_start_tid = -1;
            }

            if (section_space_end && (section_space_start_tid >= 0)) {
                section_space_array.push({
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
                                         });
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
                "inside_time_start": "00:00:00",
                "inside_time_end": "00:00:00",
                "inside_seconds": 0,
                "inside_count": 0,
                "inside_alt_min": poly_alt_min,
                "inside_alt_max": poly_alt_max,
                "outside_time_start" : "00:00:00",
                "outside_time_end" : "00:00:00",
                "outside_count": 0,
                "outside_seconds": 0,
                "outside_alt_min": poly_alt_min,
                "outside_alt_max": poly_alt_max,
            }
            poly_results.push(poly_result);
        }

        var section_speed_array_length = section_speed_array.length
        var section_alt_array_length = section_alt_array.length
        var section_space_array_length = section_space_array.length

        console.log(contestant.name + " " + contestant.startTime)

        if (igc.count > 0) {

            igcnext = igc.get(0);
            for (i = 1; i < igc.count; i++) {
                igcthis = igcnext
                igcnext = igc.get(i);

                for (j = 0; j < tpiData.length; j++) {
                    var ti = tpiData[j]


                    var distance = igc.getDistanceTo(ti.lat, ti.lon, igcnext.lat, igcnext.lon);
                    if (distance > (ti.radius + 500)) {
                        continue;
                    }

                    if ((distance <= ti.radius) && (!ti.hit)) {
                        tpiData[j].hit = true;
                    }


                    var gate_inter = G.lineIntersection(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon), ti.gateALat, ti.gateALon, ti.gateBLat, ti.gateBLon);

                    if (gate_inter !== false) {

                        var angle_low = ti.angle + 180;
                        var angle_high = angle_low + 180;
                        var flight_angle = igc.getBearingTo(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon))
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
                                    section_speed_array[k].time_end = timeEnd;
                                    section_speed_array[k].time_diff = timeDiff;
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
                            console.log(igcthis.time+ ": wrong direction on "+ ti.name  +":  B1 < A < B2: " + " " + Math.round(angle_low) + " " + Math.round(flight_angle) + "(+360) " + Math.round(angle_high))
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

                                        var proj = G.projectionPointToLineLatLon(point.lat, point.lon, prevPoint.lat, prevPoint.lon, parseFloat(igcthis.lat), parseFloat(igcthis.lon))
                                        var distance = igc.getDistanceTo(proj[0], proj[1], parseFloat(igcthis.lat), parseFloat(igcthis.lon));

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
                    var distance = igc.getDistanceTo(ti.lat, ti.lon, igcnext.lat, igcnext.lon);
                    if (distance > (ti.radius + 500)) {
                        continue;
                    }
                    var gate_inter = G.lineIntersection(parseFloat(igcthis.lat), parseFloat(igcthis.lon), parseFloat(igcnext.lat), parseFloat(igcnext.lon), ti.gateALat, ti.gateALon, ti.gateBLat, ti.gateBLon);

                    if (gate_inter !== false) {
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
                    poly_result.name = poly.name;

                    var inside = G.pointInPolygon(poly.points, igcthis)
                    if (inside) {
                        if (poly_result.inside_count === 0) {
                            poly_result.inside_time_start = igcthis.time;
                        }
                        poly_result.inside_time_end = igcthis.time;
                        poly_result.inside_alt_min = Math.min(poly_result.inside_alt_min, igcthis.alt)
                        poly_result.inside_alt_max = Math.max(poly_result.inside_alt_max, igcthis.alt)
                        poly_result.inside_count = poly_result.inside_count + 1;
                        poly_result.inside_seconds = F.timeToUnix(igcthis.time) - F.timeToUnix(poly_result.inside_time_start)
                    } else {
                        if (poly_result.outside_count=== 0) {
                            poly_result.outside_time_start = igcthis.time;
                        }
                        poly_result.outside_time_end = igcthis.time;
                        poly_result.outside_alt_min = Math.min(poly_result.outside_alt_min, igcthis.alt)
                        poly_result.outside_alt_max = Math.max(poly_result.outside_alt_max, igcthis.alt)
                        poly_result.outside_count = poly_result.outside_count + 1;
                        poly_result.outside_seconds = F.timeToUnix(igcthis.time) - F.timeToUnix(poly_result.outside_time_start)
                    }
                    poly_results[j] = poly_result;
                }


            }
        }

        var entry_point_time = 0;
        if ((tpiData[0] !== undefined) && (tpiData[0].time !== undefined)) {
            entry_point_time = F.timeToUnix(tpiData[0].time);
        }

        var exit_point_time = 86400;
        var exit_point_index = tpiData.length-1;
        if ((exit_point_index > 0) && (tpiData[exit_point_index].time !== undefined)) {
            exit_point_time = F.timeToUnix(tpiData[exit_point_index].time);
        }

        if (pathConfiguration.enableSelfIntersectionDetector) {
            console.time("self intersection")

            //        entry_point_time = mainViewMenuClipIgc.checked ? entry_point_time : 0;
            //        exit_point_time = mainViewMenuClipIgc.checked  ? entry_point_time : 86400;
            //        circling_results = self_intersetion_calculate(entry_point_time, exit_point_time); // very slow implementation
            circling_results = self_intersetion_calculate2(entry_point_time, exit_point_time);

            console.timeEnd("self intersection")
        }


        var wptString = [];
        contestantsListModel.setProperty(current, "trackHash", "");
        contestantsListModel.setProperty(current, "wptScoreDetails", "");
        contestantsListModel.setProperty(current, "speedSectionsScoreDetails", "");
        contestantsListModel.setProperty(current, "spaceSectionsScoreDetails", "");
        contestantsListModel.setProperty(current, "altitudeSectionsScoreDetails", "");
        contestantsListModel.setProperty(current, "poly_results", "");
        contestantsListModel.setProperty(current, "circling_results", "");

        var category_alt_penalty = trItem.alt_penalty;
        var category_marker_max_score = trItem.marker_max_score;
        var category_oposite_direction_penalty = trItem.oposite_direction_penalty;
        var category_gyre_penalty = trItem.gyre_penalty;
        var category_out_of_sector_penalty = trItem.out_of_sector_penalty;
        var category_photos_max_score = trItem.photos_max_score;
        var category_preparation_time = trItem.preparation_time; //sec
        var category_sg_max_score = trItem.sg_max_score;
        var category_speed_penalty = trItem.speed_penalty;
        var category_speed_max_score = (trItem.speed_max_score !== undefined) ? trItem.speed_max_score : trItem.tg_max_score;
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
        var extra_time_cmul = F.timeToUnix(contestant.startTime);

        var new_section_speed_array = [];
        var new_section_alt_array = [];
        var new_section_space_array = [];

        var speed_sections_score = 0;
        var space_sections_score = 0;
        var altitude_sections_score = 0;

        // create and compute speed sections data
        var arr_item;
        var speed_sec_score = 0;

        for (i = 0; i < section_speed_array.length; i++) {
            var ss_item = section_speed_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(speedSectionsScoreListManualValuesCache, "startPointName", ss_item.startName, "endPointName", ss_item.endName);
            arr_item = {
                "startPointName" : ss_item.startName,
                "endPointName" : ss_item.endName,
                "distance": Math.round(ss_item.distance),
                "calculatedSpeed": Math.round(ss_item.speed),
                "speedDifference": 0,
                "manualSpeed" : (index !== -1 ? speedSectionsScoreListManualValuesCache.get(index).manualSpeed : -1),
                "speedSecScore": -1,
                "maxScore" : category_speed_max_score,
                "speedTolerance" : category_speed_tolerance,
                "speedPenaly" : category_speed_penalty,
                "time_start": ss_item.time_start,
                "time_end": ss_item.time_end,
                "time_diff": ss_item.time_diff,
                "declared_speed": contestant.speed,
            }

            arr_item['speedDifference'] = (arr_item.manualSpeed === -1 ? Math.abs(contestant.speed - arr_item.calculatedSpeed) : Math.abs(contestant.speed - arr_item.manualSpeed));

            speed_sec_score = getSpeedSectionScore(arr_item['speedDifference'], category_speed_tolerance, category_speed_max_score, category_speed_penalty);
            arr_item['speedSecScore'] = speed_sec_score;
            speed_sections_score += speed_sec_score;

//            console.log(JSON.stringify(ss_item, null, 2))
//            console.log(JSON.stringify(arr_item, null, 2))

            // speedSectionsScoreList.append(arr_item);
            new_section_speed_array.push(arr_item);
        }

        // create and alt sections data
        for (i = 0; i < section_alt_array.length; i++) {
            var sa_item = section_alt_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(altSectionsScoreListManualValuesCache, "startPointName", sa_item.startName, "endPointName", sa_item.endName);

            arr_item = {
                "startPointName" : sa_item.startName,
                "endPointName" : sa_item.endName,
                "altMinEntriesCount" : sa_item.entries_below,
                "manualAltMinEntriesCount" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMinEntriesCount : -1),
                "altMinEntriesTime" : sa_item.time_spent_below,
                "manualAltMinEntriesTime" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMinEntriesTime : -1),
                "altMaxEntriesCount" : sa_item.entries_above,
                "manualAltMaxEntriesCount" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMaxEntriesCount : -1),
                "altMaxEntriesTime" : sa_item.time_spent_above,
                "manualAltMaxEntriesTime" : (index !== -1 ? altSectionsScoreListManualValuesCache.get(index).manualAltMaxEntriesTime : -1),
                "penaltyPercent": category_out_of_sector_penalty,
                "altSecScore": -1
            }

            new_section_alt_array.push(arr_item);
        }

        // create and space sections data
        for (i = 0; i < section_space_array.length; i++) {
            var sp_item = section_space_array[i];

            // get manual val from cache if exist(index != -1)
            var index = returnListModelIndexByContent(spaceSectionsScoreListManualValuesCache, "startPointName", sp_item.startName, "endPointName", sp_item.endName);

            arr_item = {
                "startPointName" : sp_item.startName,
                "endPointName" : sp_item.endName,
                "entries_out": sp_item.entries_out,
                "manualEntries_out": (index !== -1 ? spaceSectionsScoreListManualValuesCache.get(index).manualEntries_out : -1),
                "time_spent_out": sp_item.time_spent_out,
                "manualTime_spent_out": (index !== -1 ? spaceSectionsScoreListManualValuesCache.get(index).manualTime_spent_out : -1),
                "penaltyPercent": category_out_of_sector_penalty,
                "spaceSecScore": -1
            }

            new_section_space_array.push(arr_item);
        }

        for (i = 0; i < tpiData.length; i++ ) {
            var tpi_item = tpiData[i];
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
            distance_cumul += tpi_item.distance;
            extra_time_cmul += trItemCurrentPoint.addTime;


            for (var j = 0; j < section_speed_array_length; j++) {
                section = section_speed_array[j]
                if (section.start === tpi_item.tid) {
                    speed = section.speed;
                    if (section.measure || (section.time_start === 0)) {
                        speed = '';
                    }
                }
            }

            for (var j = 0; j < section_alt_array_length; j++) {
                section = section_alt_array[j]
                if (section.start === tpi_item.tid) {
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
                if (section.start === tpi_item.tid) {
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
                "tid": tpi_item.tid,
                "title": tpi_item.name,
                "alt": String(tpi_item.alt),
                "lat": G.getLat(tpi_item.lat, {coordinateFormat: "DMS"}),
                "lon": G.getLon(tpi_item.lon, {coordinateFormat: "DMS"}),
                "radius": parseFloat(tpi_item.radius),
                "angle": tpi_item.angle,
                "time": tpi_item.time,
                "hit": tpi_item.hit,
                "sg_hit": tpi_item.sg_hit,
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

            var tg_time_calculated = Math.round(distance_cumul * 3.6/contestant.speed + extra_time_cmul);

            var tg_time_measured = F.timeToUnix(tpi_item.time);
            var tg_time_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "tg_time_manual", -1, "tid", tpi_item.tid);

            var tg_time_difference = tg_time_manual === -1 ? Math.abs(tg_time_calculated - tg_time_measured) : Math.abs(tg_time_calculated - tg_time_manual);

            var tp_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "tp_hit_manual", -1, "tid", tpi_item.tid);
            var sg_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "sg_hit_manual", -1, "tid", tpi_item.tid);
            var alt_manual = returnManualValueFromListModelIfExist(wptNewScoreListManualValuesCache, "alt_manual", -1, "tid", tpi_item.tid);
            var point_alt_min = trItemCurrentPoint.alt_min;
            var point_alt_max = trItemCurrentPoint.alt_max;

            var newScoreData = {

                "tid": tpi_item.tid,
                "title": tpi_item.name,
                "type": tpi_item.flags,
                "distance_from_vbt": distance_cumul,

                "tg_time_calculated": tg_time_calculated,
                "tg_time_measured": tg_time_measured,
                "tg_time_manual": tg_time_manual,
                "tg_time_difference": tg_time_difference,
                "tg_category_time_tolerance": category_tg_tolerance,
                "tg_category_max_score": category_tg_max_score,
                "tg_category_penalty": category_tg_penalty,
                "tg_score": 0,

                "tp_hit_measured": tpi_item.hit,
                "tp_hit_manual": tp_manual,
                "tp_category_max_score": category_tp_max_score,
                "tp_score": 0,

                "sg_hit_measured": tpi_item.sg_hit,
                "sg_hit_manual": sg_manual,
                "sg_category_max_score": category_sg_max_score,
                "sg_score": 0,

                "alt_max": point_alt_max,
                "alt_min": point_alt_min,
                "alt_measured": isNaN(parseInt(tpi_item.alt)) ? -1 : parseInt(tpi_item.alt),
                                                            "alt_manual": alt_manual,
                                                            "alt_score": 0,
                                                            "category_alt_penalty": category_alt_penalty

            }

            // calc score points for whole struct
            newScoreData = calcPointScore(newScoreData);

            wptString.push(JSON.stringify(newScoreData));


            dataArr.push(newData)
            str += "\"" + tpi_item.time + "\";";
            str += "\"" + (tpi_item.hit ? "YES" : "NO" )+ "\";";
            str += "\"" + (tpi_item.sg_hit ? "YES" : "NO" ) + "\";";
            str += "\"" + tpi_item.alt + "\";";
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

        var trHash = MD5.md5(JSON.stringify(trItem));
        contestantsListModel.setProperty(current, "trackHash", trHash);
        contestantsListModel.setProperty(current, "wptScoreDetails", wptString.join("; "));
        contestantsListModel.setProperty(current, "speedSectionsScoreDetails", JSON.stringify(new_section_speed_array));
        contestantsListModel.setProperty(current, "spaceSectionsScoreDetails", JSON.stringify(new_section_space_array));
        contestantsListModel.setProperty(current, "altitudeSectionsScoreDetails", JSON.stringify(new_section_alt_array));
        contestantsListModel.setProperty(current, "poly_results", JSON.stringify(poly_results));
        contestantsListModel.setProperty(current, "circling_results", JSON.stringify(circling_results));


        contestantsListModel.setProperty(current, "score_json", JSON.stringify(dataArr))
        contestantsListModel.setProperty(current, "score", str)

        //calc contestant manual values score - markers, photos,..
        recalculateContestnatManualScoreValues(current);

        var score = getTotalScore(current);

        contestantsListModel.setProperty(current, "scorePoints", score);
        recalculateScoresTo1000();

        // save current results property
        contestantsListModel.setProperty(current, "prevResultsSpeed", contestant.speed);
        contestantsListModel.setProperty(current, "prevResultsStartTime", contestant.startTime);
        contestantsListModel.setProperty(current, "prevResultsCategory", contestant.category);
        contestantsListModel.setProperty(current, "prevResultsFilename", contestant.filename);
        contestantsListModel.setProperty(current, "prevResultsTrackHas", trHash);

        // set current values as prev results - used as cache when recomputing score
        saveCurrentResultValues(current, contestant);

        // save changes to CSV
        writeAllRequest();

        // gen new results sheet
        genResultsDetailTimer.showOnFinished = false;   // dont open results automatically
        genResultsDetailTimer.running = true;

        console.timeEnd("computeScore")
        return str;
    }

    function self_intersetion_calculate2(entry_point_time, exit_point_time) {

        var circling_results = [];
        if (igc.count > 60) {
            var i = 0, j = 0, k = 0, l = 0;
            var igck1, igck2, igcl1, igcl2;
            var STEP = 10; // 10 seconds
            var STEP_DISTANCE = STEP*60; // STEP*60m/s (216 km/h)
            var distance = 100000;

            var igci = igc.get(0)
            var igci_time = F.timeToUnix(igci.time);
            var entry_point_fix = (entry_point_time > igci_time) ? (entry_point_time - igci_time) : 0;
            var exit_point_fix = entry_point_fix + (exit_point_time - entry_point_time);
            var last_fix = igc.count - 60; // avoid check of minute after landing
            last_fix = (exit_point_fix < last_fix) ? exit_point_fix : last_fix;


            for (i = entry_point_fix; i < last_fix; i+= STEP) {
                var igcnext = igc.get(i);

                for (j = i; j < last_fix; j+= STEP) {
                    var igc2next = igc.get(j);

                    distance = igc.getDistanceTo(igcnext.lat, igcnext.lon, igc2next.lat, igc2next.lon);
                    if (distance > STEP_DISTANCE) {
                        continue;
                    }

                    var k_first = ((i - STEP) > 0) ? i - STEP : 0;
                    var k_last = ((i + STEP) < last_fix) ? (i + STEP) : last_fix
                    var l_first = ((j - STEP) > 0) ? j - STEP : 0;
                    var l_last = ((j + STEP) < last_fix) ? (j + STEP) : last_fix
                    igck2 = igc.get(k_first);

                    for (k = k_first+1;  k < k_last; k++) {
                        igck1 = igck2;
                        igck2 = igc.get(k);

                        igcl2 = igc.get(l_first);
                        for (l = l_first; l < l_last; l++) {
                            igcl1 = igcl2;
                            igcl2 = igc.get(l)

                            distance = igc.getDistanceTo(igck1.lat, igck1.lon, igcl1.lat, igcl1.lon);
                            if (distance > 150) {
                                continue;
                            }


                            var self_inter = G.lineIntersection(
                                        parseFloat(igck1.lat), parseFloat(igck1.lon),
                                        parseFloat(igck2.lat), parseFloat(igck2.lon),
                                        parseFloat(igcl1.lat), parseFloat(igcl1.lon),
                                        parseFloat(igcl2.lat), parseFloat(igcl2.lon)
                                        );
                            if (self_inter !== false) {

                                // avoid double insert
                                var found = false;
                                for (var cind = 0; cind < circling_results.length; cind++) {
                                    var cint = circling_results[cind];
                                    if (cint.time1 === igck1.time) {
                                        found = true;
                                        break;
                                    }
                                }

                                if (!found) {
                                    var push_item = {
                                        time1: igck1.time,
                                        time2: igcl1.time,
                                        lat: self_inter.x, // fixme position of intersection
                                        lon: self_inter.y,
                                    }
                                    circling_results.push(push_item)
                                    //                                console.log(JSON.stringify(push_item, null, 2) + " (distance of fixes " + distance+ ")"  )
                                    console.log(igck1.time + " " + igcl1.time + " (distance of fixes " + distance+ ")"  )
                                }
                            }

                        } // for (l)
                    } // for (k)

                } // for (j)
            } // for (i)
        }

        return circling_results;
    }


    /**
      * dummy implementation
      */

    function self_intersetion_calculate(entry_point_time, exit_point_time) {
        var circling_results = [];
        if (igc.count > 60) {

            var igck1, igck2, igcl1, igcl2;
            igck2 = igc.get(0);
            for (var k = 1; k < igc.count; k++) {
                igck1 = igck2;
                igck2 = igc.get(k);
                igcl2 = igck2;

                var igck_time = F.timeToUnix(igck1.time);
                if (igck_time < entry_point_time) {
                    continue;
                }
                if (igck_time > exit_point_time) {
                    continue;
                }

                for (var l = k+1; l < igc.count; l++) {
                    igcl1 = igcl2;
                    igcl2 = igc.get(l)

                    var igcl_time = F.timeToUnix(igcl2.time);
                    if (igcl_time < entry_point_time) {
                        continue;
                    }
                    if (igcl_time > exit_point_time) {
                        continue;
                    }


                    var distance = igc.getDistanceTo(igck1.lat, igck1.lon, igcl1.lat, igcl1.lon);
                    if (distance > 150) {
                        continue;
                    }

                    var self_inter = G.lineIntersection(
                                Number(igck1.lat), Number(igck1.lon),
                                Number(igck2.lat), Number(igck2.lon),
                                Number(igcl1.lat), Number(igcl1.lon),
                                Number(igcl2.lat), Number(igcl2.lon)
                                );
                    if (self_inter !== false) {
                        var push_item = {
                            time1: igck1.time,
                            time2: igcl1.time,
                            lat: self_inter.x, // fixme position of intersection
                            lon: self_inter.y,
                        }
                        console.log(JSON.stringify(push_item, null, 2))

                        circling_results.push(push_item)
                    }
                }
            }


        }

        return circling_results;
    }


    function saveCurrentResultValues(ctntIndex, contestant) {

        contestantsListModel.setProperty(ctntIndex, "prevResultsWPT", contestant.wptScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsSpeedSec", contestant.speedSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsSpaceSec", contestant.spaceSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevResultsAltSec", contestant.altitudeSectionsScoreDetails);
        contestantsListModel.setProperty(ctntIndex, "prevPoly_results", contestant.poly_results)
        contestantsListModel.setProperty(ctntIndex, "prevCircling_results", contestant.circling_results)
        contestantsListModel.setProperty(ctntIndex, "selectedPositions", contestant.selectedPositions);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersOk", contestant.markersOk);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersNok", contestant.markersNok);
        contestantsListModel.setProperty(ctntIndex, "prevResultsMarkersFalse", contestant.markersFalse);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosOk", contestant.photosOk);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosNok", contestant.photosNok);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPhotosFalse", contestant.photosFalse);
        contestantsListModel.setProperty(ctntIndex, "prevResultsStartTimeMeasured", contestant.startTimeMeasured);
        // FIXME prevResultsStartTimeDifference ?
        contestantsListModel.setProperty(ctntIndex, "prevResultsStartTimeDifference",  contestant.startTimeDifference);
        contestantsListModel.setProperty(ctntIndex, "prevResultsLandingScore", contestant.landingScore);
        //contestantsListModel.setProperty(ctntIndex, "circlingCount", item.prevResultsCirclingCount);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOppositeCount", contestant.oppositeCount);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOtherPoints", contestant.otherPoints);
        contestantsListModel.setProperty(ctntIndex, "prevResultsOtherPenalty", contestant.otherPenalty);
        contestantsListModel.setProperty(ctntIndex, "prevResultsPointNote", contestant.pointNote);
        contestantsListModel.setProperty(ctntIndex, "prevResultsClassify", contestant.classify);

    }

    function writeScoreManulaValToCSV() {
        console.log("writeScoreManulaValToCSV()");

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

            console.log(ct.name + " classify "
                        + ((ct.classify === 0) ? "yes" : "no" ) + " "
                        + ((ct.prevResultsClassify === 0) ? "yes" : "no" ))
            if (parseInt(ct.classify) === -1) {
                ct.classify = ct.prevResultsClassify;
            }

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
            str += "\"" + F.replaceDoubleQuotes(ct.score_json) + "\";" // 40
            str += "\"" + ct.markersScore + "\";"
            str += "\"" + ct.photosScore + "\";"
            str += "\"" + ct.startTimeDifference + "\";"
            str += "\"" + ct.circlingCount + "\";"
            str += "\"" + ct.circlingScore + "\";"
            str += "\"" + ct.oppositeCount + "\";"
            str += "\"" + ct.oppositeScore + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.poly_results) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.circling_results) + "\";"
            str += "\"" + F.replaceDoubleQuotes(ct.selectedPositions) + "\";" // 50

            str += "\n";
        }

        file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.csvResultsFile),Qt.resolvedUrl(pathConfiguration.csvResultsFile+"~"))
        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvResultsFile), str);
    }

    function writeAllRequest() {
//        console.count("dump of json data requested")

        writeAllTimer.shoot = true;
    }

    function writeAllNow() {
        console.time("write of all data")
        writeCSV();
        recalculateScoresTo1000();
        writeScoreManulaValToCSV();
//        writeJSONDump();
        console.timeEnd("write of all data")
    }

    function writeJSONDump() {

        var datamodel = []
        var j = 0;
        for (var i = 0; i < contestantsListModel.count; ++i){
            var item = contestantsListModel.get(i)
            var js_item = JSON.parse(JSON.stringify(item));

            if (item.prevResultsScoreJson === "") {
                js_item.prevResultsScoreJson = [];
            } else {
                try {
                    js_item.prevResultsScoreJson = JSON.parse(item.prevResultsScoreJson);
                } catch (e1) {
                    js_item.prevResultsScoreJson = [];
                    console.log(e1 + " prevResultsScoreJson["+i+"]: " + item.prevResultsScoreJson.substring(0, 20))
                }
            }

            if (item.prevResultsWPT === "") {
                js_item.prevResultsWPT = [];
            } else {
                try {
                    var arr = item.prevResultsWPT.split("; ")
                    var prevResultsWPT = []

                    for (j = 0; j < arr.length; j++) {
                        var prevResultsWPTItem = JSON.parse(arr[j]);
                        prevResultsWPT.push(prevResultsWPTItem)
                    }

                    js_item.prevResultsWPT = prevResultsWPT;


                } catch (e2) {
                    js_item.prevResultsWPT = [];
                    console.warn(e2)
                }
            }

            if (item.score_json === "") {
                js_item.score_json = [];
            } else {
                try {
                    js_item.score_json = JSON.parse(item.score_json);
                } catch (e3) {
                    js_item.score_json = [];
                    console.warn(e3 + " score_json["+i+"]:" + item.score_json.substring(0, 20))
                }
            }

            if (item.wptScoreDetails === "") {
                js_item.wptScoreDetails = [];
            } else {
                try {
                    var arr2 = item.wptScoreDetails.split("; ")
                    var wptScoreDetails = []

                    for (j = 0; j < arr2.length; j++) {
                        wptScoreDetails.push(JSON.parse(arr2[j]))
                    }

                    js_item.wptScoreDetails = wptScoreDetails;
                } catch (e4) {
                    js_item.wptScoreDetails = [];
                    console.warn(e4)
                }
            }

            if (item.selectedPositions === "") {
                js_item.selectedPositions = [];
            } else {
                try {
                    js_item.selectedPositions = JSON.parse(item.selectedPositions);
                } catch (e5) {
                    js_item.selectedPositions = [];
                    console.warn(e5 + " selectedPositions["+i+"]:" + item.selectedPositions.substring(0, 20))
                }
            }

            datamodel.push(js_item);
        }

        var fullSettings = {
            "pathConfiguration" : {
                "competitionArbitr": pathConfiguration.competitionArbitr,
                "contestantsFile": pathConfiguration.contestantsFile,
                "csvFile": pathConfiguration.csvFile,
                "tsFile": pathConfiguration.tsFile,
                "assignFile": pathConfiguration.assignFile,
                "csvResultsFile": pathConfiguration.csvResultsFile,
                "jsonDump": pathConfiguration.jsonDump,
                "igcDirectory": pathConfiguration.igcDirectory,
                "trackFile": pathConfiguration.trackFile,
                "resultsFolder": pathConfiguration.resultsFolder,
                "enableSelfIntersectionDetector": pathConfiguration.enableSelfIntersectionDetector,
                "contestantsDownloadedString": pathConfiguration.contestantsDownloadedString,
                "online": pathConfiguration.online,
                "competitionName": pathConfiguration.competitionName,
                "competitionType": pathConfiguration.competitionType,
                "competitionTypeText": pathConfiguration.competitionTypeText,
                "competitionDirector": pathConfiguration.competitionDirector,
                "competitionDirectorAvatar": pathConfiguration.competitionDirectorAvatar,
                "competitionArbitr": pathConfiguration.competitionArbitr,
                "competitionArbitrAvatar": pathConfiguration.competitionArbitrAvatar,
                "competitionDate": pathConfiguration.competitionDate,
                "competitionRound": pathConfiguration.competitionRound,
                "competitionGroupName": pathConfiguration.competitionGroupName,
                "api_key_get_url": pathConfiguration.api_key_get_url,
                "prevApi_key": pathConfiguration.prevApi_key,
                "apiKeyStatus": pathConfiguration.apiKeyStatus,
                "prevUserNameValidity" :pathConfiguration.prevUserNameValidity,
                "prevUserKeyValidity": pathConfiguration.prevUserKeyValidity,
                "contestantFileExist": pathConfiguration.contestantFileExist,
                "trackFileExist": pathConfiguration.trackFileExist,
            },
            "data": datamodel,
        };

        var str = JSON.stringify(fullSettings);
        file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.jsonDump),Qt.resolvedUrl(pathConfiguration.jsonDump+"~"))
        file_reader.write(Qt.resolvedUrl(pathConfiguration.jsonDump), str)
    }

    function writeCSV() {
        console.log("writeCSV()")

        var str = "";

        for (var i = 0; i < contestantsListModel.count; i++) {

            var ctnt = contestantsListModel.get(i)

            str += "\"" + ctnt.fullName + "\";"
            str += "\"" + ctnt.filename + "\";"

            str += ctnt.score;
            str += "\n";
        }
        str += ""

        if (str === "") {
            console.error("No data to save")
        } else {
            file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.csvFile), Qt.resolvedUrl(pathConfiguration.csvFile+"~"));
            file_reader.write(Qt.resolvedUrl(pathConfiguration.csvFile), str);
        }

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

        if (str === "") {
            console.error("No data to save")
        } else {
            file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.contestantsFile), Qt.resolvedUrl(pathConfiguration.contestantsFile+"~"));
            file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), str);
        }

    }

    function getPtByPid(pid, points) {
        for (var i = 0; i < points.length; i++) {
            var item = points[i]
            if (item.pid === pid) {
                return item;
            }
        }
    }

    function getPolyByCid(cid, poly) {
        for (var i = 0; i < poly.length; i++) {
            var item = poly[i];
            if (item.cid === cid) {
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
            str += "\"" + trk.speed_max_score + "\";";

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
            if (parseInt(a[20]) === parseInt(b[20])) {
                return 0;
            }
            return (parseInt(a[20]) > parseInt(b[20])) ? -1 : 1;
        } else {
            return (parseInt(a[21]) > parseInt(b[21])) ? -1 : 1;
        }
    }

    function getContinuousResults() {

        var igcItem;
        var contestant;
        var index;
        var i;

        // neni nactena trat
        if (tracks === undefined || tracks.tracks === undefined) {
            return;
        }

        var resArr = {};

        var trtr = tracks.tracks
        for (i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            resArr[category_name] = [];
        }


        for (i = 0; i < contestantsListModel.count; i++) {

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

        for (i = 0; i < trtr.length; i++) {
            var category_name = trtr[i].name;
            resArr[category_name].sort(compareBy21thColumn);

        }
        return resArr;
    }

    Timer {

        id: computingTimer
        interval: 20;
        repeat: false;
        running: false;

        property variant tpi;
        property variant polys;

        onTriggered: {
            computeScore(tpi, polys);
            writeAllRequest();
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

                writeAllRequest();

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
            } else {

                // load contestant
                contestant = contestantsListModel.get(current);

                if (file_reader.file_exists(pathConfiguration.resultsFolder + "/"+ F.getContestantResultFileName(contestant.name, contestant.category) + ".html"))  { //if results created
                    if (current + 1 == contestantsListModel.count) { // finsihed

                        running = false;

                        // category results
                        generateContinuousResults();

                        writeAllRequest();

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
        interval: 20;

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

                    file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.contestantsFile), Qt.resolvedUrl(pathConfiguration.contestantsFile+"~"))
                    file_reader.write(Qt.resolvedUrl(pathConfiguration.contestantsFile), pathConfiguration.contestantsDownloadedString);
                    pathConfiguration.contestantsDownloadedString = "";
                }

                contestantsListModel.clear(); // avoid damaging of model by clearing list of classes

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
                    applyPrevResults(); // do it for whole list (not just visible part)
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
                writeAllRequest();

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
                writeAllRequest();

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
        interval: 50;
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
                contestantsTable.positionViewAtRow(current, ListView.Visible);
                contestantsTable.selection.clear();
                contestantsTable.selection.select(current)
                contestantsTable.currentRow = current;
                return;
            }

            var item = contestantsListModel.get(current);

            var imagePath = Qt.resolvedUrl(pathConfiguration.resultsFolder+"/"+item.fullName+".png");

            if ((item.filename === "") || ( (item.score !== "") && file_reader.file_exists(imagePath)))  { // if ((no contestent selected) or (already computed))
                if (current + 1 == contestantsListModel.count) { // finsihed
                    running = false;

                    regenerateResultsFile(); // toto tu musi byt, pri tom generovani se asi neco nesyncne a pak se vysedku generuji z prazdneho listmodelu

                } else { // go to next
                    console.log("selecting: row[" + (current+1) + "]: " + item.fullName )
                    contestantsTable.positionViewAtRow(current+1, ListView.Visible);
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
        modality: Qt.ApplicationModal
    }

    function regenerateResultsFile() {

        contestantsTable.selection.clear(); // clear selection - start on first row
        resultsExporterTimer.running = true;
    }

    MessageDialog {
        id: regenResultsMessage;
        icon: StandardIcon.Question;
        modality: Qt.ApplicationModal
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
        modality: Qt.ApplicationModal
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

            } else {

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

            pathConfiguration.enableSelfIntersectionDetector = parseInt(config.get("selfIntersectionDetection", 0), 10);

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
                    var item;

                    if (filename === "") {
                        for (i = 0; i < igcFilesModel.count; i++) {
                            item = igcFilesModel.get(i);
                            if (item.contestant === 0) {
                                igc_index = i;
                                break;
                            }
                        }
                    } else {
                        for (i = 0; i < igcFilesModel.count; i++) {
                            item = igcFilesModel.get(i);
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

                file_reader.delete_file(Qt.resolvedUrl(pathConfiguration.assignFile));


            }
        }
    }

    ConfigFile {
        id: config
    }

    function test_self_intersetion_calculate2() {
        console.log("running test")
        var igc_path, clipStartTime, entry_point_time, exit_point_time;
        if (0) { // Mikolajek
            igc_path = "file:///home/jmlich/workspace/tucek/migration/53-LKHB/igcFiles/321T01V1R1_LENGAL1.igc"
            clipStartTime = "07:35:00";
            entry_point_time = 27667;
            exit_point_time = 31322;
        } else if (1) {
            // Zeman Prokop
            igc_path = "file:///home/jmlich/workspace/tucek/migration/53-LKHB/igcFiles/222T01V1R1_CHVOJKA1.igc"
            clipStartTime = "09:06:00";
            entry_point_time = 33118;
            exit_point_time = 35546;
        }

        igc.load( file_reader.toLocal(Qt.resolvedUrl(igc_path)), clipStartTime , true);

        var arr1 = [];

        console.time("self intersection")
        arr1 = self_intersetion_calculate2(entry_point_time, exit_point_time);
//        arr1 = self_intersetion_calculate(entry_point_time, exit_point_time); // slow method
//        file_reader.write_local("int1.json", JSON.stringify(arr1));

        console.timeEnd("self intersection")

    }


    Component.onCompleted: {
//            F.test_addTimeStrFormat();
//            F.test_timeToUnix();
//            test_self_intersetion_calculate2();

        startUpMessage.open();  // clean or reload prev settings
    }
}
