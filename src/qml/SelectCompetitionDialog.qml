import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "functions.js" as F
import "./components"

ApplicationWindow {

    id: competitionListWindow
    width: 800;
    height: 600;
    modality: Qt.ApplicationModal
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

        var competitionId = 0;

        // select first
        if (competitions.count !== 0) {

            competitionsTable.selection.select(0);
            competitionsTable.currentRow = 0;

            // get competition id
            competitionId  = competitions.get(competitionsTable.currentRow).id;
        }


        // select previously selected if not empty
        for (var i = 0; i < competitions.count; i++) {

            if(competitionListWindow.selectedCompetition !== "" &&
               competitionListWindow.selectedCompetition === competitions.get(i).name &&
               parseInt(competitionListWindow.selectedCompetitionId) === parseInt(competitions.get(i).id)) {

                competitionsTable.selection.clear();
                competitionsTable.selection.select(i);
                competitionsTable.currentRow = i;

                // get competition id
                competitionId  = competitions.get(competitionsTable.currentRow).id;

                break;
            }
        }

        competitionListWindow.selectedCompetitionId = competitionId;
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
            getCompetitionsData(pathConfiguration.base_url + "/competitionListApi.php", "GET", competitions, api_key_value);
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
                 Qt.openUrlExternally(pathConfiguration.base_url + "/exportCrews.php" + "?id=" + String(selectedCompetitionId) + "&errors=normal");
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

                            getContestants(pathConfiguration.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);

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
        pathConfiguration.competitionDirectorAvatar = comp.competitionDirectorAvatar;

        pathConfiguration.competitionArbitrAvatar = JSON.parse(comp.arbitrAvatar);

        pathConfiguration.competitionRound = comp.round;
        pathConfiguration.competitionGroupName = comp.group_name;

        console.log(comp.date)

        pathConfiguration.setCompetitionTabContent(comp.name, parseInt(comp.type, 10), comp.director, comp.arbitr, comp.date, comp.round, comp.group_name);
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

                        getContestants(pathConfiguration.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);
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

        getContestants(pathConfiguration.base_url + "/exportCrewsApi.php", selectedCompetitionId, "GET", api_key_value);
    }

    function getContestants(baseUrl, id, method, api_key) {

        competitionsTable.loading = true;

        var http = new XMLHttpRequest();

        http.open(method, baseUrl + "?id=" + id + "&errors=text" + "&api_key=" + api_key, true);

        console.log("getContestants: " + baseUrl + "?id=" + id + "&errors=text" + "&api_key=" + api_key)

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.9; Timer {interval: 5000; repeat: false; running: true;}", competitionListWindow, "MyTimer");
        timer.triggered.connect(function(){
            console.log("getContestants http.abort()")
            http.abort();
        });


        http.onreadystatechange = function() {
            timer.running = false;

            var status;

            console.log("getContestants: readyState " + http.readyState + " status: "+ http.status + " " +http.statusText)

            if (http.readyState === XMLHttpRequest.DONE) {

                if (http.status === 200) {

                    try{

                        // check for errors in response
                        var response = JSON.parse(http.responseText);
                        if ((response.status !== undefined) && (parseInt(response.status, 10) !== 0)) {
                            console.warn(" " + response.status + " " + http.responseText)

                            // set offline state
                            var enviromentTabValues = pathConfiguration.getEnviromentTabContent();
                            pathConfiguration.setFilesTabContent("",
                                                                 enviromentTabValues[1] ? 1 : 0,
                                                                 enviromentTabValues[2] ? 1 : 0,
                                                                 enviromentTabValues[3] ? 1 : 0,
                                                                 0,
                                                                                          pathConfiguration.enableSelfIntersectionDetector);

                                status = parseInt(response.status, 10);

                                // Set and show error dialog
                                if (status === 9 || status === 10) {

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

                            var csvArrr = [];
                            var item;
                            var pilotName;
                            var copilotName = "";
                            var name;
                            var str = "";

                            // parse json into csv
                            for (var i = 0; i < response.length; i++) {

                                item = response[i];

                                pilotName = (item.pilot_csv_name === null || item.pilot_csv_name === undefined || item.pilot_csv_name === "" ? item.pilot_surname + " " + item.pilot_firstname : item.pilot_csv_name);
                                copilotName = (item.copilot_csv_name === null || item.copilot_csv_name === undefined || item.copilot_csv_name === "" ? (item.copilot_surname === null || item.copilot_surname === undefined ? "" : item.copilot_surname + " " + item.copilot_firstname) : item.copilot_csv_name);

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
                        console.error("getContestants: parse failed: " + e + " " + http.responseText)

                        errMessageDialog.title = "Error"
                        errMessageDialog.text = e.message
                        errMessageDialog.standardButtons = StandardButton.Close
                        errMessageDialog.showDialog();
                    }
                }
                // Connection error
                else {

                    console.error("ERR getContestants http status: " + http.status + " " + http.statusText)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("contestant-download-connection-error-dialog-title")
                    //% "Can not download registrations for selected competition. Please check the network connection and try it again. %1"
                    errMessageDialog.text = qsTrId("contestant-download-connection-error-dialog-text").arg(http.status + " " + http.statusText)
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

        console.log("getCompetitionsData: " + url + "?api_key=" + api_key)

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.9; Timer {interval: 5000; repeat: false; running: true;}", competitionListWindow, "MyTimer");
        timer.triggered.connect(function(){
            console.log("getCompetitionsData http.abort()")
            http.abort();
        });

        http.onreadystatechange = function() {

            timer.running = false;

            console.log("getCompetitionsData: readyState " + http.readyState + " status: "+ http.status + " " +http.statusText)

            if (http.readyState === XMLHttpRequest.DONE) {

                if (http.status === 200) {

                    try {
                        var result = (http.responseText);

//                        console.log(result)
                        var resultObject = JSON.parse(result);

                        for (var i = 0; i < resultObject.length; i++) {
                            var resultItem = resultObject[i];
                            var director = "";
                            var competitionDirectorAvatar ="";
                            var arbitr = "";

                            // load manager
                            if (resultItem.manager !== null && resultItem.manager !== undefined && resultItem.manager.firstname !== undefined && resultItem.manager.firstname !== null) {
                                director = resultItem.manager.firstname + " " + resultItem.manager.surname;
                                competitionDirectorAvatar = (resultItem.manager.avatar_thumb !== undefined) ? resultItem.manager.avatar_thumb : "";
                            }


                            // load arbiters
                            var arbitrArr = [];
                            var arrAvatar = [];
                            if (resultItem.referees !== undefined) {
                                var refList = resultItem.referees;

                                for (var j = 0; j < refList.length; j++ ) {
                                    var ref = refList[j];
                                    arbitrArr.push(ref.firstname + " " + ref.surname);
                                    arrAvatar.push(ref.avatar_thumb);
                                }
                            }

                            arbitr = arbitrArr.join(", ");


                            var appendItem = {
                                id: resultItem.id,
                                round: resultItem.round,
                                name: resultItem.name,
                                date: resultItem.date,
                                group_name: resultItem.group_name,
                                type: resultItem.type,
                                director: director,
                                competitionDirectorAvatar: competitionDirectorAvatar,
                                arbitr: arbitr,
                                arbitrAvatar: JSON.stringify(arrAvatar),
                            }

                            competitions.append(appendItem )
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

                        console.error("getCompetitionsData: parse failed: " + e)
                    }
                }
                // Connection error
                else {

                    console.error("ERR getCompetitionsData http status: " + http.status + " " + http.statusText)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("competitions-download-connection-error-dialog-title")
                    //% "Can not download competitions list from server. Please check the network connection and try it again. %1"
                    errMessageDialog.text = qsTrId("competitions-download-connection-error-dialog-text").arg(http.status + " " + http.statusText)
                    errMessageDialog.standardButtons = StandardButton.Close
                    errMessageDialog.showDialog();
                }
            }

            competitionsTable.loading = false;
        }

        http.send()
    }
}
