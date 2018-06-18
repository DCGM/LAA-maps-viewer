import QtQuick 2.9
import "functions.js" as F
import QtQuick.Controls 1.4


Item {
    id: delegate
    property variant comboModel

    anchors.fill: parent;

    signal changeModel(int row, string role, variant value);
    signal selectRow(int row);
    signal showContestnatEditForm();

    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        elide: styleData.elideMode
        text: (styleData.value !== undefined) ? styleData.value : ""
        color: styleData.textColor
        font.bold: styleData.role === "classOrder" && ( text === "1" )

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: styleData.role === "scorePoints1000" ? Text.AlignHCenter : Text.AlignLeft;

        visible: (styleData.role === "name" ||
                  styleData.role === "category" ||
                  styleData.role === "classify" ||
                  styleData.role === "aircraftRegistration" ||
                  styleData.role === "scorePoints" ||
                  (styleData.role === "scorePoints1000" && styleData.value !== -1) ||
                  (styleData.role === "classOrder" && styleData.value !== -1))

        MouseArea {
            id: mMouseArea
            anchors.fill: parent
            visible: parent.visible;
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            Timer{
                id:timer
                interval: 200
                onTriggered: mMouseArea.singleClick()
            }

            onClicked: {
                if(mouse.button === Qt.LeftButton) {
                    if(timer.running) {
                        dblClick();
                        timer.stop();
                    }
                    else {
                        timer.restart();
                    }
                }
                else {

                    // update contestant dialog
                    updateContestantMenu.row = styleData.row;
                    updateContestantMenu.showMenu();

                    selectRow(styleData.row);
                }
            }

            function singleClick(){

                selectRow(styleData.row);
            }
            function dblClick(){

                updateContestantMenu.row = styleData.row;
                showContestnatEditForm();
            }
        }
    }


    Loader { // Initialize text editor lazily to improve performance
        id: loaderCombobox
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderCombobox.item

            onCategorySelected: {
                changeModel(styleData.row, styleData.role, newVal)
            }

            onClassifyChanged : {
                changeModel(styleData.row, styleData.role, index)
            }

            onComboBoxSelected : {

                selectRow(styleData.row);
            }
        }

        sourceComponent: (styleData.role === "classify" ? contestantClassifyComboComponent :
                         (styleData.role === "category" ? contestantCattegoryComboComponent : null))

        Component {
            id: contestantClassifyComboComponent
            ComboBox {
                width: delegate.width - 10;

                signal categorySelected(string newVal);
                signal classifyChanged(int index);
                signal comboBoxSelected();

                model: scoreListClassifyListModel
                textRole: "classify"
                currentIndex: styleData.value === -1 ? 0 : styleData.value

                onCurrentIndexChanged: {
                    classifyChanged(currentIndex);
                }
            }
        }

        Component {
            id: contestantCattegoryComboComponent
            ComboBox {
                width: delegate.width - 10;

                signal categorySelected(string newVal);
                signal classifyChanged(int index);
                signal comboBoxSelected();

                enabled: currentText !== "-"
                model: competitionClassModel
                currentIndex: getClassIndex(styleData.value);

                property int prevIndex: -1

                onActivated: {

                    prevIndex = currentIndex;
                    comboBoxSelected();
                }

                onCurrentTextChanged: {

                    if (currentIndex === 0 && prevIndex !== -1) {
                        currentIndex = prevIndex;
                    }

                    if (currentIndex > 0) {
                        categorySelected(currentText);
                    }
                }

            }

        }
    }

    Loader {
        id: loaderFilenameButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderFilenameButton.item
            onClicked: {
                igcChooseDialog.crow = styleData.row;
                igcChooseDialog.show();
            }
        }
        sourceComponent: styleData.role === "filename" ? filenameButton : null;



        Component {
            id: filenameButton
            Button {
                width: delegate.width - 10;
                height: delegate.height - 4;
                text: (styleData.value !== undefined) ? styleData.value : ""


//                enabled: styleData.value >= 0

            }
        }

    }


    //editbox

    Loader { // Initialize text editor lazily to improve performance
        id: loaderTextEdit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderTextEdit.item
            onNewValue: {

                switch (styleData.role) {

                    case "startTime":

                        changeModel(styleData.row, styleData.role, value)
                        break;

                    case "speed":

                        changeModel(styleData.row, styleData.role, parseInt(value))
                        break;

                    default:
                        changeModel(styleData.row, styleData.role, value)
                        break;
                }

            }
        }


        sourceComponent:
            (
                styleData.role !== "name" &&
                styleData.role !== "filename" &&
                styleData.role !== "category" &&
                styleData.role !== "classify" &&
                styleData.role !== "scorePoints" &&
                styleData.role !== "scorePoints1000" &&
                styleData.role !== "contestant" &&
                styleData.role !== "aircraftRegistration" &&
                styleData.role !== "classOrder"
             ) //&& (styleData.selected)
            ? (styleData.role === "speed" ? igcListSpeed : igcListStartTime ) : null

        Component {
            id: igcListSpeed

            NativeTextInput {
                id: textinput
                validator: IntValidator{bottom: 1; top: 999;}
                signal newValue(string value);

                color: styleData.textColor
                text: getTextForRole(styleData.row, styleData.role, styleData.value);

                onAccepted: {

                    newValue(text);
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        textinput.forceActiveFocus()
                    }
                }
            }
        }

        Component {
            id: igcListStartTime

            NativeTextInput {
                id: textinput
                signal newValue(string value);

                property string prevVal: "";

                color: styleData.textColor
                text: getTextForRole(styleData.row, styleData.role, styleData.value);

                onAccepted: {

                    var sec = F.timeToUnix(text);
                    if (sec <= 0) {
                        text = prevVal;
                    } else {
                        newValue(F.addTimeStrFormat(F.subUtcFromTime(sec, applicationWindow.utc_offset_sec)));
                    }
                }

                onActiveFocusChanged: {

                    if (focus) {
                        prevVal = text;
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        textinput.forceActiveFocus()
                    }
                }
            }
        }
    }

    function getTextForRole(row, role, value) {

        if (row < 0) {
            return "";
        }

        var show = value;

        switch(role) {

            case "speed":

                if (value < 0)
                    show = "";
                break;
            case "startTime":               
                show = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(value), applicationWindow.utc_offset_sec));
                break;
            default:
                break;

        }

        return show;
    }
}
