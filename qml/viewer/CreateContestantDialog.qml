import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

ApplicationWindow {

    id: createContestantWindow
    width: 500;
    height: 400;
    modality: "WindowModal"
    color: "#ffffff"

    property int comboBoxCurrentIndex;
    property int igcRow;

    signal ok(int igcTableRow);

    onVisibleChanged: {

        if (visible) {

            // create new
            if (comboBoxCurrentIndex === 0) {

                //% "Create new contestant"
                createContestantWindow.title = qsTrId("create-contestant-window-title")

                // load implicit val
                category.currentIndex = category.prevIndex < 0 ? 1 : category.prevIndex;
                startTime.text = startTime.prevVal;
            }
            // update current
            else {

                //% "Update contestant"
                createContestantWindow.title = qsTrId("update-contestant-window-title")

                var ct = contestantsListModel.get(comboBoxCurrentIndex);

                // load contestant
                pilotName.text = (ct.name).split(' – ')[0];
                copilotName.text = (ct.name).split(' – ')[1] === undefined ? "" : (ct.name).split(' – ')[1];
                category.currentIndex = getClassIndex(ct.category);
                startTime.text = ct.startTime;
                speed.text = ct.speed;
                planeType.text = ct.aircraft_type;
                planeRegistration.text = ct.aircraft_registration;
            }
        }
    }


    GridLayout {

        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10
        columnSpacing: 10;
        rowSpacing: 10;
        columns: 2
        rows: 7

        NativeText {
            //% "Pilot name"
            text: qsTrId("create-contestant-pilot-name")
        }

        TextField {
            id: pilotName
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Copilot name"
            text: qsTrId("create-contestant-copilot-name")
        }

        TextField {
            id: copilotName
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Category"
            text: qsTrId("create-contestant-category")
        }

        ComboBox {
            id: category
            model: competitionClassModel
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2

            property int prevIndex: -1;

            onCurrentIndexChanged: {

                if (currentIndex !== 0) {
                    prevIndex = currentIndex;
                }
                else {
                    prevIndex === -1 ? 1 : prevIndex;
                    currentIndex = prevIndex;
                }
            }
        }

        NativeText {
            //% "Start time"
            text: qsTrId("create-contestant-start-time")
        }

        TextField {
            id: startTime
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2

            property string prevVal: "08:00:00";

            onAccepted: {

                var str = text;
                var regexp = /^(\d+):(\d+):(\d+)$/;
                var result = regexp.exec(str);
                if (result) {
                    var num = parseInt(result[1], 10) * 3600 + parseInt(result[2], 10) * 60 + parseInt(result[3], 10);
                    newValue(F.addTimeStrFormat(num));
                } else {
                    text = prevVal;
                }
            }

            onActiveFocusChanged: {

                if (focus)
                    prevVal = text;
            }
        }

        NativeText {
            //% "Speed"
            text: qsTrId("create-contestant-speed")
        }

        TextField {
            id: speed
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2

            validator: IntValidator {bottom: 10; top: 1000;}
        }

        NativeText {
            //% "Plane registration"
            text: qsTrId("create-contestant-plane-registration")
        }

        TextField {
            id: planeRegistration
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Plane type"
            text: qsTrId("create-contestant-plane-type")
        }

        TextField {
            id: planeType
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }
    }

    function apendNewContestant(pilotName, copilotName, category, startTime, speed, type, registration) {

        var name = copilotName === "" ? pilotName : pilotName + " - " + copilotName;

        contestantsListModel.append({
                                        "name": name,
                                        "category": category,
                                        "currentCategory": category,
                                        "fullName": name + "_" + category,
                                        "startTime": startTime,
                                        "currentStartTime": startTime,
                                        "filename": "",
                                        "speed": parseInt(speed),
                                        "currentSpeed": parseInt(speed),
                                        "aircraft_type": type,
                                        "aircraft_registration": registration,
                                        "crew_id": "",
                                        "pilot_id": "",
                                        "copilot_id": "",
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
                                        "prevResultsFileName": "",
                                        "prevResultsScorePoints": -1,
                                        "prevResultsScore": "",
                                        "prevResultsScoreJson": "",
                                        "prevResultsClassify": 0

                                    })
    }

    MessageDialog {

         id: errMessageDialog
         icon: StandardIcon.Critical;
         standardButtons: StandardButton.Cancel

         onButtonClicked: {

             visible = false;
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
            text: qsTrId("ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                // validate start time
                var regexp = /^(\d+):(\d+):(\d+)$/;
                var result = regexp.exec(startTime.text);
                startTime.text = "";
                if (result) {
                    var num = parseInt(result[1], 10) * 3600 + parseInt(result[2], 10) * 60 + parseInt(result[3], 10);
                    startTime.text = F.addTimeStrFormat(num);
                }

                // check required values
                if (pilotName.text !== "" && speed.text !== "" && startTime.text !== "") {

                    if (comboBoxCurrentIndex === 0) {

                        // add crew into listmodel
                        apendNewContestant(pilotName.text, copilotName.text, category.currentText, startTime.text, speed.text, planeType.text, planeRegistration.text)
                    }
                    else {
                        // update current
                        var name = copilotName.text === "" ? pilotName.text : pilotName.text + " - " + copilotName.text;

                        contestantsListModel.setProperty(comboBoxCurrentIndex, "name", name);
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "category", category.currentText);
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "fullName", name + "_" + category.currentText);
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "startTime", startTime.text);
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "speed", parseInt(speed.text));
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "aircraft_type", planeType.text);
                        contestantsListModel.setProperty(comboBoxCurrentIndex, "aircraft_registration", planeRegistration.text);
                    }

                    ok(igcRow);
                    createContestantWindow.close()
                }
                else {

                    startTime.text = startTime.prevVal;

                    // Set and show error dialog
                    //% "Contestant update error dialog title"
                    errMessageDialog.title = qsTrId("contestant-update-error-dialog-title")
                    //% "Invalid values. Can not update or create contestant. Please check the values for: pilot name, speed and start time."
                    errMessageDialog.text = qsTrId("contestant-update-error-dialog-text")
                    errMessageDialog.open();
                }
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("cancel-button")
            onClicked: {

                createContestantWindow.close()
            }
        }
    }
}

