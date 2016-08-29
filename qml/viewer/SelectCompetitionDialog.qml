import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

ApplicationWindow {

    id: competitionListWindow
    width: 800;
    height: 600;
    modality: "WindowModal"
    //% "Select competition window"
    title: qsTrId("select-competition-window-dialog-title")
    color: "#ffffff"

    signal contestantsDownloaded(string csvString);
    signal competitionsDownloaded();
    property string selectedCompetition: "";

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
        }

        // select previously selected if not empty
        for (var i = 0; i < competitions.count; i++) {

            if(competitionListWindow.selectedCompetition !== "" && competitionListWindow.selectedCompetition === competitions.get(i).name) {

                competitionsTable.selection.clear();
                competitionsTable.selection.select(i);
                competitionsTable.currentRow = i;
            }
        }
    }

    ListModel {

        id: competitions
    }

    MessageDialog {

         id: errMessageDialog
         icon: StandardIcon.Critical;
         standardButtons: StandardButton.Open | StandardButton.Cancel

         onButtonClicked: {

             if (clickedButton == StandardButton.Open) {

                 // open url with errors
                 Qt.openUrlExternally("http://pcmlich.fit.vutbr.cz/ppt/exportCrews.php" + "?id=" + String(competitions.get(competitionsTable.currentRow).id) + "&errors=normal");
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
                    competitionsTable.selection.select(styleData.row);
                    competitionsTable.currentRow = styleData.row;
                }

                onDoubleClicked: {

                    competitionsTable.selection.clear();
                    competitionsTable.selection.select(styleData.row);
                    competitionsTable.currentRow = styleData.row;

                    // get competition property
                    setCompetitionProperty();

                    getContestants("http://pcmlich.fit.vutbr.cz/ppt/exportCrewsApi.php", competitions.get(competitionsTable.currentRow).id, "GET");

                    competitionListWindow.close()
                }
            }
        }
    }

    function setCompetitionProperty() {

        var comp = competitions.get(competitionsTable.currentRow);

        selectedCompetition = comp.name;

        competitionConfiguretion.competitionName = comp.name;
        competitionConfiguretion.competitionType = parseInt(comp.type);

        // load manager
        if (comp.manager == null || comp.manager == undefined) {

            competitionConfiguretion.competitionDirector = "";
            competitionConfiguretion.competitionDirectorAvatar = "";
        }
        else {

            competitionConfiguretion.competitionDirector = comp.manager.firstname + " " + comp.manager.surname;
            competitionConfiguretion.competitionDirectorAvatar = comp.manager.avatar_thumb;
        }

        competitionConfiguretion.competitionDate = comp.date;

        // load arbiters
        competitionConfiguretion.competitionArbitr = [];
        competitionConfiguretion.competitionArbitrAvatar = [];

        var item;
        for (var i = 0; i < comp.referees.count; i++ ) {

            item = comp.referees.get(i);
            competitionConfiguretion.competitionArbitr.push(item.firstname + " " + item.surname);
            competitionConfiguretion.competitionArbitrAvatar.push(item.avatar_thumb);
        }

        // save changes into DB
        config.set("competitionName_default", competitionConfiguretion.competitionName);
        config.set("competitionType_default", competitionConfiguretion.competitionType);
        config.set("competitionDirector_default", competitionConfiguretion.competitionDirector);
        config.set("competitionDirectorAvatar_default", JSON.stringify(competitionConfiguretion.competitionDirectorAvatar));
        config.set("competitionArbitr_default", JSON.stringify(competitionConfiguretion.competitionArbitr));
        config.set("competitionArbitrAvatar_default", JSON.stringify(competitionConfiguretion.competitionArbitrAvatar));
        config.set("competitionDate_default", competitionConfiguretion.competitionDate);

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
                    setCompetitionProperty();
                    getContestants("http://pcmlich.fit.vutbr.cz/ppt/exportCrewsApi.php", competitions.get(competitionsTable.currentRow).id, "GET");
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



    onVisibleChanged: {

        if (visible) {

            competitions.clear();

            getCompetitionsData("http://pcmlich.fit.vutbr.cz/ppt/competitionListApi.php", "GET", competitions);
        }
    }

    function listProperty(item)
    {
        for (var p in item)
        console.log(p + ": " + item[p]);
    }

    function getContestants(baseUrl, id, method) {

        var http = new XMLHttpRequest();

        http.open(method, baseUrl + "?id=" + id + "&errors=text", true);

        http.timeout = httpRequestTimeOutMs;
        http.ontimeout = function () {

            console.log("ERR getContestants http time out")

            // Set and show error dialog
            //% "Connection error dialog title"
            errMessageDialog.title = qsTrId("contestant-download-connection-error-dialog-title")
            //% "Can not download registrations for selected competition. Please check the network connection and try it again."
            errMessageDialog.text = qsTrId("contestant-download-connection-error-dialog-text")
            errMessageDialog.standardButtons = StandardButton.Close
            errMessageDialog.open();
        }


        http.onreadystatechange = function() {

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("getContestants request DONE: " + http.status)

                if (http.status === 200) {

                    try{

                        // check for errors in response
                        if (http.responseText.indexOf("Error") != -1) {

                            // Set and show error dialog
                            //% "Contestant download error dialog title"
                            errMessageDialog.title = qsTrId("contestant-download-error-dialog-title")
                            //% "Can not download registrations for selected competition. Some of the registrations includes invalid values. Please click on the Open button for more details."
                            errMessageDialog.text = qsTrId("contestant-download-error-dialog-text")
                            errMessageDialog.standardButtons = StandardButton.Open | StandardButton.Cancel
                            errMessageDialog.open();
                        }
                        // no errors, json downloaded
                        else {

                            var result = (http.responseText);
                            console.log(result)

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

                            contestantsDownloaded(str);
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
                    errMessageDialog.open();
                }
            }
        }

        http.send()
    }

    function getCompetitionsData(url, method, model) {

        console.log("getCompetitionsData")

        var http = new XMLHttpRequest();

        http.open(method, url, true);

        http.timeout = httpRequestTimeOutMs;
        http.ontimeout = function () {

            console.log("ERR getCompetitionsData http time out")

            // Set and show error dialog
            //% "Connection error dialog title"
            errMessageDialog.title = qsTrId("competitions-download-connection-error-dialog-title")
            //% "Can not download competitions list from server. Please check the network connection and try it again."
            errMessageDialog.text = qsTrId("competitions-download-connection-error-dialog-text")
            errMessageDialog.standardButtons = StandardButton.Close
            errMessageDialog.open();
        }

        http.onreadystatechange = function() {

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("getCompetitionsData request DONE: " + http.status)

                if (http.status === 200) {

                    try{
                        var result = (http.responseText);
                        var resultObject = JSON.parse(result);

                        for (var i = 0; i < resultObject.length; i++) {

                            model.append(resultObject[i])
                        }

                        competitionsDownloaded();

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
                    errMessageDialog.open();
                }
            }
        }

        http.send()
    }
}
