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

    property int contestantsListModelRow;
    property bool createNewContestant;

    signal ok(string name, string category, string startTime, int speed, string planeType, string planeRegistration);

    onVisibleChanged: {

        if (visible) {

            createNewContestant = contestantsListModelRow >= contestantsListModel.count;

            // create new
            if (createNewContestant) {

                //% "Create new contestant"
                createContestantWindow.title = qsTrId("create-contestant-window-title")

                // load implicit val
                category.currentIndex = category.prevIndex < 0 ? 1 : category.prevIndex;
                pilotName.text = "";
                copilotName.text = "";
                startTime.text = "";
                speed.text = "";
                planeType.text = "";
                planeRegistration.text = "";

            }
            // update current
            else {

                //% "Update contestant"
                createContestantWindow.title = qsTrId("update-contestant-window-title")

                var ct = contestantsListModel.get(contestantsListModelRow);

                // load contestant
                pilotName.text = (ct.name).split(' – ')[0];
                copilotName.text = (ct.name).split(' – ')[1] === undefined ? "" : (ct.name).split(' – ')[1];
                category.currentIndex = getClassIndex(ct.category);
                startTime.text = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(ct.startTime), applicationWindow.utc_offset_sec))
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
            text: qsTrId("create-contestant-pilot-name") + "*"
        }

        TextField {
            id: pilotName
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            //% "Pilot name place holder"
            placeholderText: qsTrId("create-contestant-placeHolder-pilot-name")
        }

        NativeText {
            //% "Copilot name"
            text: qsTrId("create-contestant-copilot-name")
        }

        TextField {
            id: copilotName
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            //% "Copilot name place holder"
            placeholderText: qsTrId("create-contestant-placeHolder-copilot-name")
        }

        NativeText {
            //% "Category"
            text: qsTrId("create-contestant-category") + "*"
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
            text: qsTrId("create-contestant-start-time") + "*"
        }

        TextField {
            id: startTime
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-start-time")

            property string prevVal: "08:00:00";

            onAccepted: {

                var sec = F.strTimeValidator(text);
                if (sec < 0) {
                    text = prevVal;
                }
                else {
                    text = F.addTimeStrFormat(sec);
                }
            }

            onActiveFocusChanged: {

                if (focus)
                    prevVal = text;
            }
        }

        NativeText {
            //% "Speed"
            text: qsTrId("create-contestant-speed") + "*"
        }

        TextField {
            id: speed
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-speed")

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
            placeholderText: qsTrId("create-contestant-plane-registration")
        }

        NativeText {
            //% "Plane type"
            text: qsTrId("create-contestant-plane-type")
        }

        TextField {
            id: planeType
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-plane-type")
        }
    }

    function apendNewContestant(pilotName, copilotName, category, startTime, speed, type, registration) {

        var name = copilotName === "" ? pilotName : pilotName + ' – ' + copilotName;

        // create blank user
        var new_contestant = createBlankUserObject();

        // fill user params
        new_contestant.name = name;
        new_contestant.category = category;
        new_contestant.fullName = name + "_" + category;
        new_contestant.speed = parseInt(speed);
        new_contestant.aircraft_type = type;
        new_contestant.aircraft_registration = registration;

        // append into list model
        contestantsListModel.append(new_contestant);

        // used instead of the append due to some post processing (call some on change method)
        contestantsListModel.changeLisModel(contestantsListModel.count - 1, "category", category);
        contestantsListModel.changeLisModel(contestantsListModel.count - 1, "speed", parseInt(speed));
        contestantsListModel.changeLisModel(contestantsListModel.count - 1, "startTime", startTime);
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

                //% "Contestant update error dialog title"
                errMessageDialog.title = qsTrId("contestant-update-error-dialog-title")

                // validate input values
                var sec = F.strTimeValidator(startTime.text);
                if (sec < 0) {

                    startTime.text = startTime.prevVal;

                    //% "Invalid value for start time!"
                    errMessageDialog.text = qsTrId("contestant-update-error-dialog-startTime-text")
                    errMessageDialog.open();
                }
                // names must be two word string separated by a space
                else if ((pilotName.text === "") || (pilotName.text !== "" && (!F.nameValidator(pilotName.text)))) {

                    //% "Invalid value for pilot name!"
                    errMessageDialog.text = qsTrId("contestant-update-error-dialog-pilotName-text")
                    errMessageDialog.open();
                }
                // names must be two word string separated by a space
                else if ((copilotName.text !== "") && (!F.nameValidator(copilotName.text))) {

                    //% "Invalid value for copilot name!"
                    errMessageDialog.text = qsTrId("contestant-update-error-dialog-copilotName-text")
                    errMessageDialog.open();
                }
                // speed must be inserted
                else if (speed.text === "") {

                    //% "Invalid value for speed!"
                    errMessageDialog.text = qsTrId("contestant-update-error-dialog-speed-text")
                    errMessageDialog.open();
                }
                // all OK
                else {

                    var name = copilotName.text === "" ? pilotName.text : pilotName.text + ' – ' + copilotName.text;
                    var startTimeUTC = F.addTimeStrFormat(F.subUtcFromTime(sec, applicationWindow.utc_offset_sec));

                    if (createNewContestant) {

                        // add crew into listmodel
                        apendNewContestant(pilotName.text, copilotName.text, category.currentText, startTimeUTC, speed.text, planeType.text, planeRegistration.text)
                    }
                    else {
                        // update current
                        contestantsListModel.setProperty(contestantsListModelRow, "name", name);
                        contestantsListModel.setProperty(contestantsListModelRow, "aircraft_type", planeType.text);
                        contestantsListModel.setProperty(contestantsListModelRow, "aircraft_registration", planeRegistration.text);

                        // used instead of the "setProperty" due to some post processing
                        contestantsListModel.changeLisModel(contestantsListModelRow, "category", category.currentText);
                        contestantsListModel.changeLisModel(contestantsListModelRow, "speed", parseInt(speed.text));
                        contestantsListModel.changeLisModel(contestantsListModelRow, "startTime", startTimeUTC);
                    }

                    ok(name, category.currentText, startTimeUTC, parseInt(speed.text), planeType.text, planeRegistration.text);
                    createContestantWindow.close()
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

