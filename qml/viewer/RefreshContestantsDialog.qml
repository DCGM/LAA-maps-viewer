import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ApplicationWindow {

    id: refreshDialogMainWindow
    width: applicationWindow.width;
    height: applicationWindow.height;
    modality: "WindowModal"
    color: "#ffffff"

    signal ok();
    signal cancel();

    onVisibleChanged: {
        if(visible) {

            /**/
            updatedContestants.append(unmodifiedContestants.get(1))
            updatedContestants.append(unmodifiedContestants.get(2))
            updatedContestants.append(unmodifiedContestants.get(3))

            addedContestants.append(unmodifiedContestants.get(1))
            addedContestants.append(unmodifiedContestants.get(2))

            removedContestants.append(unmodifiedContestants.get(1))
            removedContestants.append(unmodifiedContestants.get(2))
            removedContestants.append(unmodifiedContestants.get(3))


            console.log("unmodifiedContestants: " + unmodifiedContestants.count)
            console.log("updatedContestants: " + updatedContestants.count)
            console.log("addedContestants: " + addedContestants.count)
            console.log("removedContestants: " + removedContestants.count)
        }
    }

    ScrollView {

        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: actionButtons.top
        anchors.margins: 20
        //horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        Column {

            width: Math.max(column1.width, column2.width)
            spacing: 20

            Column {

                id: column1
                width: visibleCol ? 2000 : 0
                height: visibleCol ? children.height : 0
                spacing: 20

                property bool visibleCol: updatedContestants.count > 0

                NativeText {
                    id: updatedLabel
                    //% Updated crews %1/%2
                    text: qsTr("refresh-dialog-updated-crews-title %1/%2").arg(updatedContestants.selected).arg(updatedContestants.count)
                    visible: updatedContestants.count > 0
                }


                RefreshDialogListViewWithCheckBox {

                    id: modifiedCrewListViewCheckBox
                    visible: updatedContestants.count > 0
                    model: updatedContestants
                }
            }


            //ColumnLayout {
            Column {

                id: column2
                spacing: 20
                width: refreshDialogMainWindow.width - scrollView.anchors.margins * 2//updatedContestants.count > 0 ? 2000 : scrollView.width // picovina, ale co s tim
                height: children.height

                NativeText {
                    id: unmodifiedLabel
                    //% Unmodified crews %1/%2
                    text: qsTr("refresh-dialog-unmodified-crews-title %1/%2").arg(unmodifiedContestants.selected).arg(unmodifiedContestants.count)
                    visible: unmodifiedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {
                    id: unmodifiedCrewListViewCheckBox
                    visible: unmodifiedContestants.count > 0
                    model: unmodifiedContestants
                }

                NativeText {
                    id: addedLabel
                    //% Added crews %1/%2
                    text: qsTr("refresh-dialog-added-crews-title %1/%2").arg(addedContestants.selected).arg(addedContestants.count)
                    visible: addedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {

                    id: addedCrewListViewCheckBox
                    visible: addedContestants.count > 0
                    model: addedContestants
                }

                NativeText {
                    id: missingLabel
                    //% Missing crews %1/%2
                    text: qsTr("refresh-dialog-missing-crews-title %1/%2").arg(removedContestants.selected).arg(removedContestants.count)
                    visible: removedContestants.count > 0
                }

                RefreshDialogListViewWithCheckBox {

                    id: removedCrewListViewCheckBox
                    visible: removedContestants.count > 0
                    model: removedContestants
                    //anchors.bottom: parent.bottom
                    //anchors.bottomMargin: 10
                }


                /*
                            Column {

                                id: unmodifiedView
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                height: unmodifiedContestantsListView.height + unmodifiedContestantsListView.topMargin + selectAllCheckBox.height + spacing
                                spacing: 10

                                CheckBox {

                                    id: selectAllCheckBox
                                    anchors.left: parent.left
                                    anchors.leftMargin: 5
                                    anchors.right: parent.right
                                }

                                ListView {

                                    id: unmodifiedContestantsListView
                                    model: unmodifiedContestants
                                    delegate: listModelDelegate
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: unmodifiedContestants.count * 30
                                }
                            }*/

                /*TableView {
                    id: updatedContestantsTableView;
                    model: updatedContestants;
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin:  10
                    //height: updatedContestants.count * 30 + 50    // tohle se taky sere > vyska se nastavi sama na 150...???

                    clip: true;

                    rowDelegate: Rectangle {
                        height: 30;
                        color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")
                    }

                    property int selectorColumnWidth: 70
                    property int nameColumnWidth: 150
                    property int speedColumnWidth: 50
                    property int categoryColumnWidth: 60
                    property int startTimeColumnWidth: 60
                    property int planeRegColumnWidth: 60
                    property int planeTypeColumnWidth: 60
                    property int spacerColumnWidth: 30
                    property int checkBoxColumnWidth: 30

                    TableViewColumn {
                        role: "selected"
                        width: updatedContestantsTableView.checkBoxColumnWidth
                        delegate: checkBoxDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "name"
                        width: updatedContestantsTableView.nameColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "nameSelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newName"
                        width: updatedContestantsTableView.nameColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn { role: "spacer"; width: updatedContestantsTableView.spacerColumnWidth; delegate: textDelegate; movable: false }

                    TableViewColumn {
                        role: "category"
                        width: updatedContestantsTableView.categoryColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "categorySelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newCategory"
                        width: updatedContestantsTableView.categoryColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn { role: "spacer"; width: updatedContestantsTableView.spacerColumnWidth; delegate: textDelegate; movable: false}

                    TableViewColumn {
                        role: "speed"
                        width: updatedContestantsTableView.speedColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "speedSelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newSpeed"
                        width: updatedContestantsTableView.speedColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn { role: "spacer"; width: updatedContestantsTableView.spacerColumnWidth; delegate: textDelegate; movable: false }

                    TableViewColumn {
                        role: "startTime"
                        width: updatedContestantsTableView.startTimeColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "startTimeSelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newStartTime"
                        width: updatedContestantsTableView.startTimeColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn { role: "spacer"; width: updatedContestantsTableView.spacerColumnWidth; delegate: textDelegate; movable: false }

                    TableViewColumn {
                        role: "aircraft_registration"
                        width: updatedContestantsTableView.planeRegColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "planeRegSelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newAircraft_registration"
                        width: updatedContestantsTableView.planeRegColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn { role: "spacer"; width: updatedContestantsTableView.spacerColumnWidth; delegate: textDelegate; movable: false}

                    TableViewColumn {
                        role: "aircraft_type"
                        width: updatedContestantsTableView.planeTypeColumnWidth
                        delegate: textDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "planeTypeSelector"
                        width: updatedContestantsTableView.selectorColumnWidth
                        delegate: switchDelegate
                        movable: false
                    }

                    TableViewColumn {
                        role: "newAircraft_type"
                        width: updatedContestantsTableView.planeTypeColumnWidth
                        delegate: textDelegate
                        movable: false
                    }
                }*/
            }
        }
    }



    RowLayout {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Row {
            spacing: 10;

            Button {
                id: okButton;
                //% "Ok"
                text: qsTrId("refresh-dialog-ok-button")
                focus: true;
                isDefault: true;
                onClicked: {
                    ok();
                    refreshDialogMainWindow.close();
                }
            }
            Button {
                //% "Cancel"
                text: qsTrId("refresh-dialog-cancel-button")

                onClicked: {
                    cancel();
                    refreshDialogMainWindow.close()
                }
            }
        }
    }

    /*
    ScrollView {

        id: scrollView
        //width: applicationWindow.width;
        //height: applicationWindow.height;
        //width: parent.width
        anchors.fill: parent
        anchors.margins: 20

        Component.onCompleted: console.log(width)
        Column {

            id: column
            //width: scrollView.width - 20

            anchors.fill: parent
            //anchors.margins: 20
            //anchors.left: parent.left
//            anchors.right: parent.right
            //anchors.top: parent.top

            spacing: 10

            onWidthChanged: console.log(width + "::")
            Component.onCompleted: console.log(width+ ":")

            NativeText {

                id: updatedCrewsLabel
                //width: parent.width

                //% Updated crews
                text: qsTr("refresh-dialog-updated-crews-title")
            }

            Rectangle {

                //anchors.top: updatedCrewsLabel.bottom
                anchors.left: column.left
                anchors.right: column.right
                //anchors.leftMargin:  10
                height: 600
                //width: 100
                color: "red"
            }

            /*

            */
        //}
    //}


    Component {
        id: checkBoxDelegate

        Item {
            anchors.fill: parent

            CheckBox {
                checked: styleData.value
                //anchors.horizontalCenter: parent.horizontalCenter
                anchors.leftMargin: 5
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    updatedContestants.setProperty(styleData.row, styleData.role, checked ? 1 : 0);
                    updatedContestantsTableView.model = null;
                    updatedContestantsTableView.model = updatedContestants;
                }
            }
        }
    }

    Component {
        id: textDelegate

        Item {
            anchors.fill: parent

            Rectangle {

                visible: !getSelectedState(styleData.row)
                width: parent.width
                height: 1
                border.width: 1
                border.color: "gray"
                color: "gray"
                anchors.verticalCenter: parent.verticalCenter
            }

            NativeText {
                anchors.fill: parent
                elide: styleData.elideMode
                text: styleData.value
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: getStyleDataColor(styleData.row, styleData.role);
            }
        }
    }

    Component {
        id: switchDelegate

        Item {
            anchors.fill: parent

            Rectangle {

                visible: !getSelectedState(styleData.row)
                width: parent.width
                height: 1
                border.width: 1
                border.color: "gray"
                color: "gray"
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                checked: styleData.value
                opacity: enabled ? 1 : 0.2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                enabled: getSwitchEnabledState(styleData.row, styleData.role);

                onClicked: {
                    updatedContestants.setProperty(styleData.row, styleData.role, checked ? 1 : 0);
                    updatedContestantsTableView.model = null;
                    updatedContestantsTableView.model = updatedContestants;
                }
            }
        }
    }

    function getSelectedState(row, model) {

        if (row < 0 || model.count === 0) {
            return true;
        }

        return model.get(row).selected;
    }

    function getSwitchEnabledState(row, role) {

        if (row < 0) {
            return false;
        }

        var state = true;

        var item = updatedContestants.get(row);

        switch(role) {

            case "nameSelector":
                state = !item.selected && item.name !== item.newName ? true : false;
                break;
            case "speedSelector":
                state = !item.selected && item.speed !== item.newSpeed ? true : false;
                break;
            case "categorySelector":
                state = !item.selected && item.category !== item.newCategory ? true : false;
                break;
            case "startTimeSelector":
                state = !item.selected && item.startTime !== item.newStartTime ? true : false;
                break;
            case "planeTypeSelector":
                state = !item.selected && item.aircraft_type !== item.newAircraft_type ? true : false;
                break;
            case "planeRegSelector":
                state = !item.selected && item.aircraft_registration !== item.newAircraft_registration ? true : false;
                break;
            default:
                break;

        }

        return state;
    }

    function getStyleDataColor(row, role) {

        if (row < 0) {
            return "black";
        }

        var color = "black";

        var item = updatedContestants.get(row);

        switch(role) {

            case "name":
                color = item.nameSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newName":
                color = !item.nameSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "speed":
                color = item.speedSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newSpeed":
                color = !item.speedSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "category":
                color = item.categorySelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newCategory":
                color = !item.categorySelector || !item.selected  ? "#aaa" : "black";
                break;
            case "startTime":
                color = item.startTimeSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newStartTime":
                color = !item.startTimeSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "aircraft_type":
                color = item.planeTypeSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newAircraft_type":
                color = !item.planeTypeSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "aircraft_registration":
                color = item.planeRegSelector || !item.selected  ? "#aaa" : "black";
                break;
            case "newAircraft_registration":
                color = !item.planeRegSelector || !item.selected  ? "#aaa" : "black";
                break;
            default:
                break;

        }

        return color;
    }
/*
    Component {
        id: tabViewDelegate

        Loader { // Initialize text editor lazily to improve performance
            id: loader
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            Connections {
                target: loader.item
            }
sourceComponent: null
           // sourceComponent: (styleData.role === "name" ? textComponent :
           //                  (styleData.role === "nameSelector" ? switchComponent : null))

            Component {

                id: textComponent
                NativeText {
                    width: parent.width
                    text: styleData.value
                    anchors.verticalCenter: parent.verticalCenter
                    //color: switchItem.checked || !selected ? "#aaa" : "black";
                }
            }

            Component {

                id: switchComponent
                Switch {
                    checked: styleData.value
                    opacity: enabled ? 1 : 0.2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }



            Component {
                id: importConteNameComponent

                RowLayout {

                    property bool selected: true;
                    property string oldVal;
                    property string newVal;

                    NativeText {
                        text: getCurrentTextForDelegate(styleData.row, styleData.role, updatedContestants);
                        width: parent.width * 2/5;
                        color: switchItem.checked || !selected ? "#aaa" : "black";
                    }

                    Item {
                        width: parent.width/5;
                        height: parent.height
                        Switch {
                            id: switchItem
                            //enabled: speed !== newSpeed && selected
                            opacity: enabled ? 1 : 0.2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            checked: styleData.value

                            onClicked: {
                                updatedContestants.setProperty(styleData.row, "speedSelector", checked ? 1 : 0);
                            }
                        }
                    }

                    NativeText {
                        text: "newSpeed";
                        width: parent.width * 2/5;
                        horizontalAlignment: Text.AlignRight;
                        color: !switchItem.checked || !selected ? "#aaa" : "black";
                    }
                }
            }
        }
    }




    ScrollView {

        id: scrollView

        //anchors.top: header.bottom
        //anchors.left: parent.left
        //anchors.right: parent.right
        //anchors.bottom: parent.bottom

        anchors.fill: parent
        anchors.margins: 20

        ListView {

            model: updatedContestants
            delegate: listModelDelegate
        }
    }

    */

}
