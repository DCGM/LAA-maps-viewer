import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

ApplicationWindow {

    id: competitionListWindow
    width: 800;
    height: 600;
    modality: "ApplicationModal"
    //% "Select competition window"
    title: qsTrId("select-competition-window-dialog-title")
    color: "#ffffff"

    signal refreshDataDownloaded(string csvString);
    signal competitionsDownloaded();
    property string selectedCompetition: "";
    signal competitionSelected();

    property variant selectedCompetitionId;
    property bool refresh: false;
    property bool exportResultsMode: false; // used in export results for destination competition selection

    property int httpRequestTimeOutMs: 5000

    // select previously selected competition
    onCompetitionsDownloaded: {

        // index out of range error
        competitionsTable.model = null;
        competitionsTable.model = competitions;

        competitionsTable.selection.clear();

        // select first
        if (competitions.count !== 0) {

            competitionsTable.selection.select(0);
            competitionsTable.currentRow = 0;

            // get competition id
            selectedCompetitionId  = competitions.get(competitionsTable.currentRow).id;
        }

        // select previously selected if not empty
        for (var i = 0; i < competitions.count; i++) {

            if(competitionListWindow.selectedCompetition !== "" && competitionListWindow.selectedCompetition === competitions.get(i).name) {

                competitionsTable.selection.clear();
                competitionsTable.selection.select(i);
                competitionsTable.currentRow = i;

                // get competition id
                selectedCompetitionId  = competitions.get(competitionsTable.currentRow).id;
            }
        }
    }

    ListModel {

        id: competitions
    }


    onVisibleChanged: {

        // get competitions list
        if (visible) {

            // clear refresh flag
            refresh = false;

            // clear export results flag
            exportResultsMode = false;

            // clear competitions list
            competitions.clear();

            var api_key_value = config.get("api_key", "");

            // download competitions list
            getCompetitionsData(F.base_url + "/competitionListApi.php", "GET", competitions, api_key_value);
        }

        // switch to offline state - nothing selected or connection error
        if(!visible && pathConfiguration.getEnviromentTabCompName() === "") {

            pathConfiguration.setEnviromentTabOnlineCheckBox(false);
        }
    }

    MessageDialog {

         id: errMessageDialog
         icon: StandardIcon.Critical;
         standardButtons: StandardButton.Open | StandardButton.Cancel

         signal showDialog();

         onShowDialog: {

             workingTimer.running = false;  // stop working timer - spin box in main.qml

             if(competitionListWindow.visible || refresh)
                open();
         }

         onButtonClicked: {

             if (clickedButton == StandardButton.Open) {

                 // open url with errors
                 Qt.openUrlExternally(F.base_url + "/exportCrews.php" + "?id=" + String(competitions.get(competitionsTable.currentRow).id) + "&errors=normal");
                 visible = false;
             }
             else {
                 visible = false;
                 competitionListWindow.visible = false;
             }
         }
     }

    TableView {

        id: competitionsTable
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: actionButtons.top
        anchors.margins: 10
        model: competitions

        property bool loading: false

        Rectangle {

            color: "#ffffff";
            opacity: 0.7;
            anchors.fill: parent;
            visible: competitions.count === 0 && competitionsTable.loading

            BusyIndicator {
                running: parent.visible
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

        TableViewColumn {
            //% "Competition round"
            title: qsTrId("competitions-table-round")
            role: "round";
            width: 80
        }

        TableViewColumn {
            //% "Competition date"
            title: qsTrId("competitions-table-date")
            role: "date";
            width: 160
        }

        TableViewColumn {
            //% "Competition name"
            title: qsTrId("competitions-table-name")
            role: "name";
            width: 500
        }

        itemDelegate: Item {

            NativeText {

                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter

                elide: styleData.elideMode
                text: styleData.value
                color: styleData.selected ? "white" : (styleData.role === "name" ?  "#1C6FB2" : styleData.textColor)
            }
        }

        rowDelegate: Rectangle {
            height: 30;
            color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

            MouseArea {
                anchors.fill: parent

                onClicked: {

                    competitionsTable.selection.clear();

                    if (styleData.row !== undefined) {
                        competitionsTable.selection.select(styleData.row);
                        competitionsTable.currentRow = styleData.row;

                        // get competition id
                        selectedCompetitionId  = competitions.get(competitionsTable.currentRow).id;
                    }
                }

                onDoubleClicked: {

                    competitionsTable.selection.clear();

                    if (styleData.row !== undefined) {
                        competitionsTable.selection.select(styleData.row);
                        competitionsTable.currentRow = styleData.row;
                        competitionsTable.positionViewAtRow(styleData.row, ListView.Contain)

                        // get competition id
                        selectedCompetitionId  = competitions.get(competitionsTable.currentRow).id;

                        // select destination competition - upload results
                        if (exportResultsMode) {

                            competitionListWindow.close()
                            competitionSelected();
                        }
                        else {
                            // get competition property
                            setCompetitionProperty();

                            var api_key_value = config.get("api_key", "");

                            getContestants(F.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);

                            //competitionListWindow.close()
                        }
                    }
                }
            }
        }
    }

    // open dialog for selectiion of the destination competition (upload files)
    function openForExportResultsPurpose() {

        show();

        exportResultsMode = true;
    }

    function setCompetitionProperty() {

        var comp = competitions.get(competitionsTable.currentRow);
        var director = "";
        var arbitr = "";

        selectedCompetition = comp.name;
        pathConfiguration.setEnviromentTabCompName(comp.name);

        // load manager
        if (comp.manager === null || comp.manager === undefined || comp.manager.firstname === undefined || comp.manager.firstname === null) {

            director = "";
            pathConfiguration.competitionDirectorAvatar = "";
        }
        else {

            director = comp.manager.firstname + " " + comp.manager.surname;
            pathConfiguration.competitionDirectorAvatar = (comp.manager.avatar_thumb !== undefined) ? comp.manager.avatar_thumb : "";
        }

        // load arbiters
        var item;
        var arr = [];
        var arrAvatar = [];
        for (var i = 0; i < comp.referees.count; i++ ) {

            item = comp.referees.get(i);
            arr.push(item.firstname + " " + item.surname);
            arrAvatar.push(item.avatar_thumb);
        }

        arbitr = arr.join(", ");
        pathConfiguration.competitionArbitrAvatar = arrAvatar;

        pathConfiguration.competitionRound = item.round;
        pathConfiguration.competitionGroupName = item.group_name;

        pathConfiguration.setCompetitionTabContent(comp.name, parseInt(comp.type), director, arbitr, comp.date);
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
            text: qsTrId("competition-list-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                if (competitionsTable.currentRow !== -1) {

                    selectedCompetition = competitions.get(competitionsTable.currentRow).name;

                    // select destination competition - upload results
                    if (exportResultsMode) {

                        competitionListWindow.close();
                        competitionSelected();

                    }
                    else {
                        // get competition property
                        setCompetitionProperty();

                        var api_key_value = config.get("api_key", "");

                        getContestants(F.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);
                    }
                }
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("competition-list-cancel-button")
            onClicked: {

                competitionListWindow.close()
            }
        }
    }

    function refreshApplications() {

        // set refresh flag - downloaded applications will be saved and reloaded
        refresh = true;

        // clear export results flag
        exportResultsMode = false;

        // clear competitions list
        competitions.clear();

        var api_key_value = config.get("api_key", "");

        getContestants(F.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);
    }

    function getContestants(baseUrl, id, method, api_key) {

        competitionsTable.loading = true;

        var http = new XMLHttpRequest();

        http.open(method, baseUrl + "?id=" + id + "&errors=text" + "&api_key=" + api_key, true);

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 5000; repeat: false; running: true;}", competitionListWindow, "MyTimer");
                        timer.triggered.connect(function(){

                            http.abort();
                        });


        http.onreadystatechange = function() {
            timer.running = false;

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("getContestants request DONE: " + http.status)

                if (http.status === 200) {

                    try{

                        // check for errors in response
                        if (http.responseText.indexOf("\"status\":") != -1) {

                            console.log("ERR getContestants DONE: " + http.responseText)

                            // set offline state
                            var enviromentTabValues = pathConfiguration.getEnviromentTabContent();
                            pathConfiguration.setFilesTabContent("",
                                                                 enviromentTabValues[1] ? 1 : 0,
                                                                 enviromentTabValues[2] ? 1 : 0,
                                                                 enviromentTabValues[3] ? 1 : 0,
                                                                 0);

                            // Set and show error dialog
                            if (http.responseText.indexOf("\"status\": 10") != -1) {

                                //% "Contestant download error dialog title"
                                errMessageDialog.title = qsTrId("contestant-download-error-dialog-title")
                                //% "Can not download registrations for selected competition. Some of the registrations includes invalid values. Please click on the Open button for more details."
                                errMessageDialog.text = qsTrId("contestant-download-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Open | StandardButton.Cancel
                            }
                            else {

                                //% "Access error dialog title"
                                errMessageDialog.title = qsTrId("contestant-download-access-error-dialog-title")
                                //% "Can not download registrations for selected competition. Please check the settings (e.g. api_key) and try it again."
                                errMessageDialog.text = qsTrId("contestant-download-access-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Close
                            }


                            errMessageDialog.showDialog();
                        }
                        // no errors, json downloaded
                        else {
                            var result = (http.responseText);

                            var resultObject = JSON.parse(result);
                            var csvArrr = [];
                            var item;
                            var pilotName;
                            var copilotName = "";
                            var name;
                            var str = "";

                            // parse json into csv
                            for (var i = 0; i < resultObject.length; i++) {

                                item = resultObject[i];

                                pilotName = (item.pilot_csv_name == null || item.pilot_csv_name == undefined || item.pilot_csv_name == "" ? item.pilot_surname + " " + item.pilot_firstname : item.pilot_csv_name);
                                copilotName = (item.copilot_csv_name == null || item.copilot_csv_name == undefined || item.copilot_csv_name == "" ? (item.copilot_surname == null || item.copilot_surname == undefined ? "" : item.copilot_surname + " " + item.copilot_firstname) : item.copilot_csv_name);

                                name = copilotName == "" ? pilotName : pilotName + " – " + copilotName;

                                var line = "\"" + F.addSlashes(name)
                                        +"\";\""+ F.addSlashes(item.category_name)
                                        +"\";\""+ F.addSlashes(name + "_" + item.category_name)
                                        +"\";\""+ F.addSlashes(item.starttime)
                                        +"\";\""+ F.addSlashes(item.igc)
                                        +"\";\""+ F.addSlashes(item.speed)
                                        +"\";\""+ F.addSlashes(item.aircraft_type)
                                        +"\";\""+ F.addSlashes(item.aircraft_registration)
                                        +"\";\""+ F.addSlashes(item.id)
                                        +"\";\""+ F.addSlashes(item.pilot)
                                        +"\";\""+ F.addSlashes(item.copilot)
                                        +"\";\""+ F.addSlashes(item.pilot_avatar_thumb)
                                        +"\";\""+ F.addSlashes(item.copilot_avatar_thumb) + "\""

                                str += line + "\n";
                            }

                            // refresh applications
                            if (refresh) {
                                refreshDataDownloaded(str);
                            }
                            else {
                                pathConfiguration.contestantsDownloadedString = str;
                            }

                            competitionListWindow.close();
                        }

                    } catch (e) {
                        console.log("ERR getContestants: parse failed" + e)
                    }
                }
                // Connection error
                else {

                    console.log("ERR getContestants http status: " + http.status)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("contestant-download-connection-error-dialog-title")
                    //% "Can not download registrations for selected competition. Please check the network connection and try it again."
                    errMessageDialog.text = qsTrId("contestant-download-connection-error-dialog-text")
                    errMessageDialog.standardButtons = StandardButton.Close
                    errMessageDialog.showDialog();
                }
            }

            competitionsTable.loading = false;
        }

        http.send()
    }

    function getCompetitionsData(url, method, model, api_key) {

        competitionsTable.loading = true;

        var http = new XMLHttpRequest();

        http.open(method, url + "?api_key=" + api_key, true);

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 5000; repeat: false; running: true;}", competitionListWindow, "MyTimer");
                        timer.triggered.connect(function(){

                            http.abort();
                        });

        http.onreadystatechange = function() {

            timer.running = false;

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("getCompetitionsData request DONE: " + http.status)

                if (http.status === 200) {

                    try{
                        var result = (http.responseText);

                        var resultObject = JSON.parse(result);

                        for (var i = 0; i < resultObject.length; i++) {

                            model.append(resultObject[i])
                        }

                        // nothing to parse, check for error
                        if (resultObject.length === 0 || resultObject.length === undefined) {

                            if (http.responseText.indexOf("\"status\":") != -1) {

                                console.log("ERR getCompetitionsData DONE: \n" + http.responseText)

                                // Set and show error dialog
                                //% "Access error dialog title"
                                errMessageDialog.title = qsTrId("competitions-download-access-error-dialog-title")
                                //% "Can not download competitions list from server. Please check the settings (e.g. api_key) and try it again."
                                errMessageDialog.text = qsTrId("competitions-download-access-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Close
                                errMessageDialog.showDialog();
                            }
                        }
                        else {
                            competitionsDownloaded();
                        }

                    } catch (e) {

                        console.log("ERR getCompetitionsData: parse failed" + e)
                    }
                }
                // Connection error
                else {

                    console.log("ERR getCompetitionsData http status: " + http.status)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("competitions-download-connection-error-dialog-title")
                    //% "Can not download competitions list from server. Please check the network connection and try it again."
                    errMessageDialog.text = qsTrId("competitions-download-connection-error-dialog-text")
                    errMessageDialog.standardButtons = StandardButton.Close
                    errMessageDialog.showDialog();
                }
            }

            competitionsTable.loading = false;
        }

        http.send()
    }
}
