import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "functions.js" as F


GridLayout {
        id: createContestantTabGrid

        property alias pilotName: pilotNameTextField.text
        property alias copilotName: copilotNameTextField.text;
        property alias category: categoryCombo.currentIndex;
        property alias startTime: startTimeTextField.value;
        property alias speed: speedTextField.text;
        property alias registration: registrationTextField.text
        property alias planeType: planeTypeTextField.text;
        property alias classify: classifyCombo.currentIndex;

        anchors.fill: parent;
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
            id: pilotNameTextField
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
            id: copilotNameTextField
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
            id: categoryCombo
            model: competitionClassModel
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2

        }

        NativeText {
            //% "Start time"
            text: qsTrId("create-contestant-start-time") + "*"
        }

        TextField {
            id: startTimeTextField
            Layout.fillWidth: true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-start-time")

            property string value
            property string prevVal: "00:00:00";
            text: F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(value), applicationWindow.utc_offset_sec));

            onEditingFinished: {

                var sec = F.timeToUnix(text);
                if (sec <= 0) {
                    text = prevVal;
                } else {
                    text = F.addTimeStrFormat(sec);
                }
                value = F.addTimeStrFormat(F.subUtcFromTime(sec, applicationWindow.utc_offset_sec));

            }

            onActiveFocusChanged: {

                if (focus) {
                    prevVal = text;
                }
            }
        }

        NativeText {
            //% "Speed"
            text: qsTrId("create-contestant-speed") + "*"
        }

        TextField {
            id: speedTextField
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
            id: registrationTextField
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-plane-registration")
        }

        NativeText {
            //% "Plane type"
            text: qsTrId("create-contestant-plane-type")
        }

        TextField {
            id: planeTypeTextField
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            placeholderText: qsTrId("create-contestant-plane-type")
        }

        NativeText {
            //% "Classify
            text: qsTrId("create-contestant-classify")
        }

        ComboBox {
            id: classifyCombo
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
            model: scoreListClassifyListModel

        }
    }

