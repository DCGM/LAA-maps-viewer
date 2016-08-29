import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

ApplicationWindow {

    id: importApplication
    width: 1280;
    height: header.height + (importContestantsListModel.count > maxWindowSize ? maxWindowSize : importContestantsListModel.count)  * rowHeight + 100 + actionButtons.height//860;
    modality: "WindowModal"
    //% "import window title"
    title: qsTrId("import-window-dialog-title")
    color: "#ffffff"

    property int scrollBarWidth: 40
    property int columnCount:  4;
    property int rowHeight: 40;
    property int maxWindowSize: 12 //size in contestant count, used for window auto size
    property int columnWidth: (importApplication.width - mainColumn.anchors.leftMargin - mainColumn.anchors.rightMargin - header.spacing * (columnCount - 1) - scrollBarWidth) / columnCount;

    property alias listModel: importContestantsListModel

    ListModel {

        id: importContestantsListModel

    }

    Rectangle {

        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: actionButtons.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
        anchors.rightMargin: 20
        color: "transparent"

        Row {

            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 90

            property int columnSpacing: 15

            Column {

                width: columnWidth
                spacing: header.columnSpacing

                NativeText {

                    font.bold : true
                    width: columnWidth
                    horizontalAlignment: Text.AlignHCenter;
                    //% "Import window header crew name"
                    text: qsTrId("import-window-header-name")
                }

                HorizontalDelimeter {

                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                NativeText {

                    width: columnWidth
                    horizontalAlignment: Text.AlignHCenter;
                    text: " "
                }
            }

            Column {

                width: columnWidth
                spacing: header.columnSpacing

                NativeText {

                    font.bold : true
                    width: columnWidth
                    horizontalAlignment: Text.AlignHCenter;
                    //% "Import window header crew category"
                    text: qsTrId("import-window-header-category")
                }

                HorizontalDelimeter {

                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Row {

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignLeft;
                        //% "Import window header crew actual value"
                        text: qsTrId("import-window-header-actual-value")
                    }

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignRight;
                        //% "Import window header crew new value"
                        text: qsTrId("import-window-header-new-value")
                    }
                }
            }

            Column {

                width: columnWidth
                spacing: header.columnSpacing

                NativeText {

                    font.bold : true
                    width: columnWidth
                    horizontalAlignment: Text.AlignHCenter;
                    //% "Import window header crew speed"
                    text: qsTrId("import-window-header-speed")
                }

                HorizontalDelimeter {

                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Row {

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignLeft;
                        //% "Import window header crew actual value"
                        text: qsTrId("import-window-header-actual-value")
                    }

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignRight;
                        //% "Import window header crew new value"
                        text: qsTrId("import-window-header-new-value")
                    }
                }
            }

            Column {

                width: columnWidth
                spacing: header.columnSpacing

                NativeText {

                    font.bold : true
                    width: columnWidth
                    horizontalAlignment: Text.AlignHCenter;
                    //% "Import window header crew start time"
                    text: qsTrId("import-window-header-startTime")
                }

                HorizontalDelimeter {

                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Row {

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignLeft;
                        //% "Import window header crew actual value"
                        text: qsTrId("import-window-header-actual-value")
                    }

                    NativeText {

                        width: columnWidth/2
                        horizontalAlignment: Text.AlignRight;
                        //% "Import window header crew new value"
                        text: qsTrId("import-window-header-new-value")
                    }
                }
            }
        }


        ScrollView {

            id: scrollView
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.bottomMargin: 20


            ListView {

                model: importContestantsListModel
                delegate: listModelDelegate
            }
        }
    }

    Component {

        id: listModelDelegate

        Rectangle {

            id: rowDelegate
            height: rowHeight
            width: parent.width
            color: modelRow % 2 ? "#eee" : "#fff"

            property int modelRow: row;

            Row {

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                spacing: header.spacing

                NativeText { text: name; width: columnWidth; }

                Row {
                    width: columnWidth

                    NativeText { text: prevResultsCategory; width: columnWidth/3; color: categorySelector ? "#aaa" : "black" }

                    Item {
                        width: columnWidth/3;
                        height: parent.height
                        Switch {
                            enabled: prevResultsCategory !== category
                            opacity: enabled ? 1 : 0.2

                            checked: categorySelector; anchors.horizontalCenter: parent.horizontalCenter

                            onClicked: {
                                importContestantsListModel.setProperty(rowDelegate.modelRow, "categorySelector", checked ? 1 : 0);

                                var ct = importContestantsListModel.get(rowDelegate.modelRow);
                                contestantsListModel.setProperty(ct.contestantOriginRow, "category", checked ? ct.category : ct.prevResultsCategory);
                            }
                        }
                    }

                    NativeText { text: category; width: columnWidth/3; horizontalAlignment: Text.AlignRight; color: !categorySelector ? "#aaa" : "black"}
                }

                Row {
                    width: columnWidth

                    NativeText { text: prevResultsSpeed; width: columnWidth/3; color: speedSelector ? "#aaa" : "black" }

                    Item {
                        width: columnWidth/3;
                        height: parent.height
                        Switch {
                            enabled: prevResultsSpeed !== speed
                            opacity: enabled ? 1 : 0.2

                            checked: speedSelector; anchors.horizontalCenter: parent.horizontalCenter

                            onClicked: {
                                importContestantsListModel.setProperty(rowDelegate.modelRow, "speedSelector", checked ? 1 : 0);

                                var ct = importContestantsListModel.get(rowDelegate.modelRow);
                                contestantsListModel.setProperty(ct.contestantOriginRow, "speed", checked ? ct.speed : ct.prevResultsSpeed);
                            }
                        }
                    }

                    NativeText { text: speed; width: columnWidth/3; horizontalAlignment: Text.AlignRight; color: !speedSelector ? "#aaa" : "black"}
                }

                Row {
                    width: columnWidth

                    NativeText { text: prevResultsStartTime; width: columnWidth/3; color: startTimeSelector ? "#aaa" : "black"}

                    Item {
                        width: columnWidth/3;
                        height: parent.height
                        Switch {
                            enabled: prevResultsStartTime !== startTime
                            opacity: enabled ? 1 : 0.2

                            checked: startTimeSelector; anchors.horizontalCenter: parent.horizontalCenter

                            onClicked: {
                                importContestantsListModel.setProperty(rowDelegate.modelRow, "startTimeSelector", checked ? 1 : 0);

                                var ct = importContestantsListModel.get(rowDelegate.modelRow);
                                contestantsListModel.setProperty(ct.contestantOriginRow, "startTime", checked ? ct.startTime : ct.prevResultsStartTime);
                            }
                        }
                    }

                    NativeText { text: startTime; width: columnWidth/3; horizontalAlignment: Text.AlignRight; color: !startTimeSelector ? "#aaa" : "black"}
                }
            }

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
            //% "Close"
            text: qsTrId("import-configuration-close")
            onClicked: {
                importApplication.close()
            }
        }
    }
}
