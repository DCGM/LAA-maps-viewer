import QtQuick 2.1
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import Qt.labs.folderlistmodel 2.1
import cz.mlich 1.0
import "functions.js" as F
import "csv.js" as CSVJS



ApplicationWindow {
    id: applicationWindow
    //% "Trajectory viewer"
    title: qsTrId("application-window-title")
    width: 1024
    height: 600

    property variant tracks;

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
            }

            MenuItem {
                //% "Evaluate all data"
                text: qsTrId("main-file-menu-process-all");
                onTriggered: evaluate_all_data();
            }

            MenuItem {
                //% "Export"
                text: qsTrId("main-file-menu-export")
                enabled: (igcFilesTable.currentRow >= 0)
                onTriggered: {
                    exportFileDialog.open()
                }
            }


            MenuItem {
                //% "E&xit"
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
                }
                //                Component.onCompleted: { // default value
                //                    checked = true;
                //                    map.url = ""
                //                }

            }
            MenuItem {
                //% "&Local"
                text: qsTrId("main-map-menu-local")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    console.log("Cached OSM")
                    map.url = QStandardPathsHomeLocation+"/.local/share/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = QStandardPathsApplicationFilePath + "/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = "../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"

                }
                Component.onCompleted: { // default value
                    checked = true;
                    map.url = QStandardPathsHomeLocation+"/.local/share/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = QStandardPathsApplicationFilePath + "../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                    //map.url = "../../Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
                }

            }
            MenuItem {
                //% "&OSM Mapnik"
                text: qsTrId("main-map-menu-osm")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://a.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
                }

            }
            MenuItem {
                //% "Google &Roadmap"
                text: qsTrId("main-map-menu-google-roadmap")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://mts0.google.com/vt/lyrs=m@248407269&hl=x-local&x=%(x)d&y=%(y)d&z=%(zoom)d&s=Galileo"
                }
            }

            MenuItem {
                //% "Google &Terrain"
                text: qsTrId("main-map-menu-google-terrain")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://mts1.google.com/vt/lyrs=t,r&x=%(x)d&y=%(y)d&z=%(zoom)d"
                }
            }

            MenuItem {
                //% "Google &Satellite"
                text: qsTrId("main-map-menu-google-satellite")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    map.url = "http://khms1.google.com/kh/v=144&src=app&x=%(x)d&y=%(y)d&z=%(zoom)d&s="
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
            }
            MenuItem {
                id: mainViewMenuAltChart
                //% "Altitude profile";
                text: qsTrId("main-view-menu-altchart")
                checkable: true;
                checked: true;
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


    PathConfiguration {
        id: pathConfiguration;
        onOk: {
            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile))) {
                loadContestants(Qt.resolvedUrl(pathConfiguration.contestantsFile))
            } else {
                //% "File %1 not found"
                errorMessage.text = qsTrId("path-configuration-error-contestantsFile-not-found").arg(pathConfiguration.contestantsFile);
                errorMessage.open();
                return;
            }

            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile ))) {
                tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(pathConfiguration.trackFile )))
            } else {
                // cleanup
                contestantsListModel.clear()

                //% "File %1 not found"
                errorMessage.text = qsTrId("path-configuration-error-trackFile-not-found").arg(pathConfiguration.trackFile);
                errorMessage.open();
                return;
            }


            igcFolderModel.folder = "";
            igcFolderModel.folder = pathConfiguration.igcDirectory;

            storeTrackSettings(pathConfiguration.tsFile);
            map.requestUpdate();

        }
        onCancel: {
            console.log("pathConfiguration Cancel")
        }
    }

    FolderListModel {
        id: igcFolderModel
        nameFilters: ["*.igc"]
        showDirs: false
        property string previousFolder;

        onCountChanged: {
            if (previousFolder != igcFolderModel.folder) { // beware do not compare with !== operator (string !== object)
                igcFilesModel.clear()
                previousFolder = igcFolderModel.folder;
            }

            for (var i = 0; i < igcFolderModel.count; i++) {

                var fileName = igcFolderModel.get(i, "fileName")
                var filePath = igcFolderModel.get(i, "filePath");

                var found = false;

                for (var j = 0; j < igcFilesModel.count; j++) {
                    var item = igcFilesModel.get(j);
                    if ((item.fileName === fileName) && (item.filePath === filePath)) {
                        found = true;
                    }
                }

                if (!found) {

                    // select item in combobox if filename match
                    var contestant_index = 0;
                    for (var j = 0; j < contestantsListModel.count; j++) {
                        var contestant = contestantsListModel.get(j);
                        if (fileName === contestant.filename) {
                            contestant_index = j;
                        }

                    }

                    igcFilesModel.append({"fileName": fileName, "filePath": filePath, "score": "", "score_json": "", contestant: contestant_index})
                }
            }

        }

    }

    ListModel {
        id: igcFilesModel
        onDataChanged: {
            if (igcFilesTable.currentRow < 0) {
                igcFilesTable.rowSelected();
            }
        }
    }

    ListModel {
        id: wptScoreList
    }

    ListModel {
        id: contestantsListModel
    }


    SplitView {
        id: splitView
        anchors.fill: parent;
        orientation: Qt.Horizontal

        ///// IGC file list

        TableView {

            Rectangle { // disable
                color: "#ffffff";
                opacity: 0.7;
                anchors.fill: parent;
                visible: evaluateTimer.running;
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {

                        console.log("onClick is disabled when evaluateTimer.running");
                        evaluateTimer.running = false;
                    }
                }
            }

            id: igcFilesTable
            width: 250;
            visible: mainViewMenuTables.checked

            clip: true;
            model: igcFilesModel;

            itemDelegate: IgcFilesDelegate {
                comboModel: contestantsListModel
                onChangeModel: {
                    if (row >= igcFilesModel.count) {
                        console.log("WUT? row role value " +row + " " +role + " " +value)
                        return;
                    }

                    var prevRow = igcFilesTable.currentRow
                    igcFilesModel.setProperty(row, role, value)
                    if (role === "contestant") {
                        writeCSV();
                        igcFilesModel.setProperty(row, "score", "")
                    }

                    if (prevRow === row) {
                        igcFilesTable.currentRow = row;
                        igcFilesTable.rowSelected();
                    }
                }
            }

            rowDelegate: Rectangle {
                height: 30;
                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")
            }


            TableViewColumn {
                //% "File name"
                title: qsTrId("filelist-table-filename")
                role: "fileName";
            }
            TableViewColumn {
                //% "Contestant"
                title: qsTrId("filelist-table-contestants")
                role: "contestant"
            }



            Component.onCompleted: {
                selection.selectionChanged.connect(rowSelected);
            }



            function rowSelected() {

                if (igcFilesModel.count <= 0) {
                    return;
                }

                var current = -1;

                igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

                if (current < 0) {
                    return;
                }



                var item = model.get(current)

                if (item.contestant >= contestantsListModel.count) {
                    console.log("incorrect contestant id " + item.contestant + " " + contestantsListModel.count)
                    return;
                }

                var ctnt = contestantsListModel.get(item.contestant)

                var arr = tracks.tracks;
                var found = false;
                for (var i = 0; i < arr.length; i++) {
                    var trItem = arr[i];
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
                igc.load( item.filePath, ctnt.startTime)

                map.requestUpdate()
                altChart.igcUpdate();

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
                    computeScore(tpi)
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

        TableView {
            id: scoreTable
            model: wptScoreList
            visible: mainViewMenuTables.checked

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

        }
    }

    FileReader {
        id: file_reader
    }

    ImageSaver {
        id: imageSaver;

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
                //                                text: F.formatDistance(map.rulerDistance, {'distanceUnit':'m'})
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


        }


    }

    function loadContestants(filename) {
        var f_data = file_reader.read(filename);
        var data = CSVJS.parseCSV(String(f_data));
        contestantsListModel.clear()
        contestantsListModel.append({
                                        "name": "-",
                                        "category": "-",
                                        "fullName": "undefined",
                                        "startTime": "00:00:00",
                                        "filename": ""
                                    })
        for (var i = 0; i < data.length; i++) {
            var item = data[i];
            var itemName = item[0]

            // CSV soubor ma alespon 3 Sloupce
            if ((item.length > 2) && (itemName.length > 0)) {
                contestantsListModel.append({
                                                "name": itemName,
                                                "category": item[1],
                                                "fullName": item[2],
                                                "startTime": item[3],
                                                "filename": item[4],
                                            })
            }
        }
    }

    function computeScore(tpiData) {


        var current = -1;

        igcFilesTable.selection.forEach( function(rowIndex) { current = rowIndex; } )

        if (current < 0) {
            console.log("computeScore, but currentRow == " + igcFilesTable.currentRow)
            return;
        }



        var item = igcFilesModel.get(current)
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

            var flags = ti.flags;
            var section_speed_start = F.getFlagsByIndex(7, flags)
            var section_speed_end   = F.getFlagsByIndex(8, flags)
            var section_alt_start   = F.getFlagsByIndex(9, flags)
            var section_alt_end     = F.getFlagsByIndex(10, flags)
            var section_space_start = F.getFlagsByIndex(11, flags)
            var section_space_end   = F.getFlagsByIndex(12, flags)

            //            console.log(j + " " + flags + " " +section_speed_start + " " + section_speed_end + " " + section_alt_start + " " + section_alt_end + " " + section_space_start + " " + section_space_end)

            distance_cumul += ti.distance;

            if (section_speed_end && (section_speed_start_tid >= 0)) {
                var item = {
                    "start": section_speed_start_tid,
                    "end": ti.tid,
                    "distance": distance_cumul,
                    "time_start": 0,
                    "speed": 0
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
                }
                section_space_array.push(item);
                section_space_start_tid = -1;
            }

            if (section_speed_start) {
                section_speed_start_tid = ti.tid;
                distance_cumul = 0;
            }
            if (section_alt_start) {
                section_alt_start_tid = ti.tid;
                section_alt_threshold_max = ti.alt_max;
                section_alt_threshold_min = ti.alt_min;
            }
            if (section_space_start) {
                section_space_start_tid = ti.tid;
                section_space_threshold = ti.radius;
                section_space_alt_threshold_max = ti.alt_max;
                section_space_alt_threshold_min = ti.alt_min;
            }

        }

        var section_speed_array_length = section_speed_array.length
        var section_alt_array_length = section_alt_array.length
        var section_space_array_length = section_space_array.length

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
                                    section_speed_array[k].speed = (speed * 3.6); // m/s to km/h
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

            }
        }



        //        console.log(JSON.stringify(section_speed_array))
        //        console.log(JSON.stringify(section_alt_array))
        //                console.log(JSON.stringify(section_space_array))
        //        console.log(JSON.stringify(sectorCache))


        wptScoreList.clear()
        var str = "";
        var dataArr = [];
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
                "hit": (item.hit
                        //% "YES"
                        ? qsTrId("hit-yes")
                          //% "NO"
                        : qsTrId("hit-no")
                        ),
                "sg_hit": (item.sg_hit
                           //% "YES"
                           ? qsTrId("sg-hit-yes")
                             //% "NO"
                           : qsTrId("sg-hit-no")
                           ),
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
            wptScoreList.append(newData);
            dataArr.push(newData)
            str += "\"" + item.time + "\";";
            str += "\"" + (item.hit ? qsTrId("hit-yes") : qsTrId("hit-no") )+ "\";";
            str += "\"" + (item.sg_hit ? qsTrId("sg-hit-yes") : qsTrId("sg-hit-no") ) + "\";";
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

        igcFilesModel.setProperty(current, "score_json", JSON.stringify(dataArr))
        igcFilesModel.setProperty(current, "score", str)


        writeCSV()
        console.timeEnd("computeScore")
        return str;
    }


    function writeCSV() {
        var str = "";

        for (var i = 0; i < igcFilesModel.count; i++) {
            var item = igcFilesModel.get(i)
            if (item.contestant < 0 ) {
                console.log("Error (writeCSV): " +JSON.stringify(item))
            }

            var ctnt = contestantsListModel.get(item.contestant)

            str += "\"" + ctnt.fullName + "\";"
            str += "\"" + item.fileName + "\";"

            str += item.score;
            str += "\n";
        }
        str += ""

        file_reader.write(Qt.resolvedUrl(pathConfiguration.csvFile), str);

    }

    function getPtByPid(pid, points) {
        for (var i = 0; i < points.length; i++) {
            var item = points[i]
            if (item.pid == pid) {
                return item;
            }
        }
    }

    function storeTrackSettings(filename) {
        var str = "";
        var trks = tracks.tracks
        var points = tracks.points;
        for (var i = 0; i < trks.length; i++) {
            var item = trks[i]
            var category_name = F.addSlashes(item.name)
            str += "\"" + category_name + "\";";
            str += "\"" + item.alt_penalty + "\";";
            str += "\"" + item.gyre_penalty + "\";";
            str += "\"" + item.marker_max_score + "\";";
            str += "\"" + item.oposite_direction_penalty + "\";";
            str += "\"" + item.out_of_sector_penalty + "\";";
            str += "\"" + item.photos_max_score + "\";";
            str += "\"" + item.speed_penalty + "\";";
            str += "\"" + item.tg_max_score + "\";";
            str += "\"" + item.tg_penalty + "\";";
            str += "\"" + item.tg_tolerance + "\";";
            str += "\"" + item.time_window_penalty + "\";";
            str += "\"" + item.time_window_size + "\";";
            str += "\"" + item.tp_max_score + "\";";
            str += "\"" + item.speed_tolerance + "\";";
            str += "\"" + item.sg_max_score + "\";";
            str += "\"" + ((item.preparation_time !== undefined) ? item.preparation_time : 0) + "\";";

            //            str += "\n";
            //            str += "\"" + category_name + "___PART2" +"\";";

            var conns = item.conn;


            for (var j = 0; (j < conns.length); j++) {
                var c = conns[j];

                var pt = getPtByPid(c.pid, points)

                //                console.log(JSON.stringify(pt))
                str += "\"" + ((c.flags < 0) ? item.default_flags : c.flags ) + "\";";
                str += "\"" + ((c.angle < 0) ? c.computed_angle : c.angle) + "\";";
                str += "\"" + ((c.distance < 0) ? c.computed_distance : c.distance) + "\";";
                str += "\"" + ((c.addTime < 0) ? item.default_addTime : c.addTime) + "\";";
                str += "\"" + ((c.radius < 0) ? item.default_radius : c.radius) + "\";";
                str += "\"" + ((c.alt_max < 0) ? item.default_alt_max : c.alt_max) + "\";";
                str += "\"" + ((c.alt_min < 0) ? item.default_alt_min : c.alt_min) + "\";";
                str += "\"" + ((c.speed_max < 0) ? item.default_speed_max : c.speed_max) + "\";";
                str += "\"" + ((c.speed_min < 0) ? item.default_speed_min : c.speed_min) + "\";";
                str += "\"" + F.addSlashes(pt.name) + "\";";
            }



            var section_speed_start_pid = -1;
            var section_alt_start_pid = -1;
            var section_space_start_pid = -1;
            var sections = [];

            for (var j = 0; j < conns.length; j++) {
                var c = conns[j];

                var flags = ((c.flags < 0) ? item.default_flags : c.flags );
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
                } else { // go to next
                    igcFilesTable.selection.clear();
                    igcFilesTable.selection.select(current+1)
                    igcFilesTable.currentRow = current+1;
                }


            }


        }
    }


    MessageDialog {
        id: errorMessage;
        icon: StandardIcon.Critical;

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

                    //                    console.log(igc_index)

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


}
