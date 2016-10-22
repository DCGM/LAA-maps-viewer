import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Component {

    id: listModelDelegate

    Rectangle {

        id: rowDelegate
        height: 30
        width: parent.width
        color: index % 2 ? "#eee" : "#fff"

        property bool readOnly: rowDelegate.ListView.view.model.readOnly

        // line when not selected
        Rectangle {
            color: "gray"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 30
            anchors.rightMargin: 20
            height: 1
            anchors.verticalCenter: parent.verticalCenter
            visible: !selected
        }

        // read only delegate
        RowLayout {

            id: rowReadOnly
            height: parent.height
            spacing: 50
            visible: rowDelegate.readOnly
            width: listView.width

            Item {
                height: parent.height
                Layout.preferredWidth: 330;
                Layout.fillWidth: true;

                property int checkedData: selected

                onCheckedDataChanged: {
                    checkBoxReadOnlyDelegate.checked = checkedData;
                }

                CheckBox {
                    id: checkBoxReadOnlyDelegate
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter

                    onCheckedStateChanged: {
                        rowDelegate.ListView.view.model.setProperty(index, "selected", checked ? 1 : 0);
                    }
                }

                NativeText {
                    anchors.left: checkBoxReadOnlyDelegate.right;
                    anchors.leftMargin: 10;
                    anchors.right: parent.right;
                    anchors.verticalCenter: parent.verticalCenter
                    text: name;
                    color: !selected ? "#aaa" : "black" }
            }

            NativeText { text: category; Layout.preferredWidth: 100; color: !selected ? "#aaa" : "black" }
            NativeText { text: speed; Layout.preferredWidth:50; color: !selected ? "#aaa" : "black" }
            NativeText { text: startTime; Layout.preferredWidth: 80; color: !selected ? "#aaa" : "black" }
            NativeText { text: aircraft_registration; Layout.preferredWidth: 110; color: !selected ? "#aaa" : "black" }
            NativeText { text: aircraft_type; Layout.preferredWidth: 150; color: !selected ? "#aaa" : "black" }
        }

        // editable delegate
        RowLayout {

            id: row
            width: parent.width
            height: parent.height
            spacing: 50
            visible: !rowDelegate.readOnly

            Row {
                id: nameRow

                Layout.fillWidth: true

                Item {
                    id: checkBox
                    width: 20
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    property int checkedData: selected

                    onCheckedDataChanged: {
                        checkBoxCompo.checked = checkedData;
                    }

                    CheckBox {
                        id: checkBoxCompo
                        anchors.verticalCenter: parent.verticalCenter

                        onCheckedStateChanged: {
                            rowDelegate.ListView.view.model.setProperty(index, "selected", checked ? 1 : 0);
                        }
                    }                    
                }

                Item {
                    id: currentNameText
                    width: parent.width * 2/5
                    height: parent.height
                    anchors.left: checkBox.right
                    anchors.leftMargin: 10

                    NativeText {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter;
                        text: name;
                        color: nameSwitch.checked || !selected ? "#aaa" : "black"
                    }
                }

                Item {
                    id: nameSwitchItem
                    width: parent.width * 1/5 - 30
                    height: parent.height
                    anchors.left: currentNameText.right

                    Switch {
                        id: nameSwitch
                        enabled: name !== newName && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        checked: nameSelector

                        onClicked: {
                        }
                    }
                }
                Item {
                    id: newNameText
                    width: parent.width * 2/5
                    height: parent.height
                    anchors.left: nameSwitchItem.right

                    NativeText {
                        horizontalAlignment: Text.AlignRight;
                        verticalAlignment: Text.AlignVCenter;
                        text: newName;
                        anchors.fill: parent
                        color: !nameSwitch.checked || !selected ? "#aaa" : "black"
                    }
                }
            }

            Row {
                Layout.preferredWidth: 250

                NativeText { text: category; width: parent.width * 2/5; color: categorySwitch.checked || !selected ? "#aaa" : "black" }

                Item {
                    width: parent.width/5;
                    height: parent.height

                    Switch {
                        id: categorySwitch
                        enabled: category !== newCategory && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        checked: categorySelector

                        onClicked: {
                            rowDelegate.ListView.view.model.setProperty(index, "categorySelector", checked ? 1 : 0);
                        }
                    }
                }

                NativeText { text: newCategory; width: parent.width * 2/5; horizontalAlignment: Text.AlignRight; color: !categorySwitch.checked || !selected ? "#aaa" : "black"}
            }

            Row {
                Layout.preferredWidth: 150

                NativeText { text: speed; width: parent.width * 2/5; color: speedSwitch.checked || !selected ? "#aaa" : "black" }

                Item {
                    width: parent.width/5;
                    height: parent.height
                    Switch {
                        id: speedSwitch
                        enabled: speed !== newSpeed && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        checked: speedSelector

                        onClicked: {
                            rowDelegate.ListView.view.model.setProperty(index, "speedSelector", checked ? 1 : 0);
                        }
                    }
                }

                NativeText { text: newSpeed; width: parent.width * 2/5; horizontalAlignment: Text.AlignRight; color: !speedSwitch.checked || !selected ? "#aaa" : "black"}
            }

            Row {
                Layout.preferredWidth: 220

                NativeText { text: startTime; width: parent.width * 2/5; color: startTimeSwitch.checked || !selected ? "#aaa" : "black"}

                Item {
                    width: parent.width/5;
                    height: parent.height
                    Switch {
                        id: startTimeSwitch
                        enabled: startTime !== newStartTime && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        checked: startTimeSelector

                        onClicked: {
                           rowDelegate.ListView.view.model.setProperty(index, "startTimeSelector", checked ? 1 : 0);
                        }
                    }
                }

                NativeText { text: newStartTime; width: parent.width * 2/5; horizontalAlignment: Text.AlignRight; color: !startTimeSwitch.checked || !selected ? "#aaa" : "black"}
            }

            Row {
                Layout.preferredWidth: 270

                NativeText { text: aircraft_registration; width: parent.width * 2/5; color: planeRegistrationSwitch.checked || !selected ? "#aaa" : "black"}

                Item {
                    width: parent.width/5;
                    height: parent.height
                    Switch {
                        id: planeRegistrationSwitch
                        enabled: aircraft_registration !== newAircraft_registration && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        checked: planeRegSelector

                        onClicked: {
                           rowDelegate.ListView.view.model.setProperty(index, "planeRegSelector", checked ? 1 : 0);
                        }
                    }
                }

                NativeText { text: newAircraft_registration; width: parent.width * 2/5; horizontalAlignment: Text.AlignRight; color: !planeRegistrationSwitch.checked || !selected ? "#aaa" : "black"}
            }

            Row {
                Layout.preferredWidth: 350
                anchors.right: parent.right
                anchors.rightMargin: 10

                NativeText { text: aircraft_type; width: parent.width * 2/5; color: planeTypeSwitch.checked || !selected ? "#aaa" : "black"}

                Item {
                    width: parent.width/5;
                    height: parent.height
                    Switch {
                        id: planeTypeSwitch
                        enabled: aircraft_type !== newAircraft_type && selected
                        opacity: enabled ? 1 : 0.2
                        anchors.horizontalCenter: parent.horizontalCenter
                        checked: planeTypeSelector

                        onClicked: {
                            rowDelegate.ListView.view.model.setProperty(index, "planeTypeSelector", checked ? 1 : 0);
                        }
                    }
                }

                NativeText { text: newAircraft_type; width: parent.width * 2/5; horizontalAlignment: Text.AlignRight; color: !planeTypeSwitch.checked || !selected ? "#aaa" : "black"}
            }
        }
    }
}
