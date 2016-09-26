import QtQuick 2.5
import "functions.js" as F
import QtQuick.Controls 1.4


Item {
    id: delegate
    property variant comboModel

    anchors.fill: parent;

    signal changeModel(int row, string role, variant value);
    signal showResults(int row);
    signal selectRow(int row);

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
                  (styleData.role === "scorePoints1000" && styleData.value !== -1) ||
                  (styleData.role === "classOrder" && styleData.value !== -1))

        MouseArea {

            anchors.fill: parent
            visible: styleData.role === "name"
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onDoubleClicked: {

                createContestantDialog.contestantsListModelRow = styleData.row;
                createContestantDialog.show();
            }
            onClicked: {

                if (mouse.button === Qt.RightButton) {

                    // update contestant dialog
                    updateContestantMenu.row = styleData.row;
                    updateContestantMenu.popup();
                }
                else {
                    selectRow(styleData.row);
                }
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

                enabled: styleData.value !== -1

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

                    if (currentIndex === 0 && prevIndex !== -1)
                        currentIndex = prevIndex;

                    if (currentIndex > 0)
                        categorySelected(currentText);
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

                igcChooseDialog.row = styleData.row;
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

    Loader { // Initialize text editor lazily to improve performance
        id: loaderButton
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderButton.item

            onButtonPressed: {

                showResults(row);
            }

            onRightButtonPressed: {

                recalculateScoreMenu.selectedRow = row;
                recalculateScoreMenu.popup();
            }
        }

        sourceComponent: styleData.role === "scorePoints"? contestantButton : null;


        Component {
            id: contestantButton
            Button {
                width: delegate.width - 10;
                height: delegate.height - 4;
                text: (styleData.value < 0 ? 0 : styleData.value)
                enabled: styleData.value >= 0

                signal buttonPressed(int row);
                signal rightButtonPressed(int row);

                MouseArea {

                   // id: mouse
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onPressed: {

                        if (mouse.button === Qt.RightButton)
                            rightButtonPressed(styleData.row); //recalculate results
                        else
                            buttonPressed(styleData.row);
                    }
                }
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
                //validator: RegExpValidator { regExp: /^(\d{2}):(\d{2}):(\d{2})$/ }
                signal newValue(string value);

                property string prevVal: "";

                color: styleData.textColor
                text: getTextForRole(styleData.row, styleData.role, styleData.value);

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
                break;
            default:
                break;

        }

        return show;
    }
}