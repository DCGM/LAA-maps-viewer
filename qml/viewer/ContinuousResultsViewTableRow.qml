import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Rectangle {

    width: recWidth;
    height: recHeight;

    property int recWidth;
    property int recHeight;
    property bool verticalLines;
    property bool horizontalLine;

    property string col1;
    property string col2;
    property string col3;
    property string col4;
    property string col5;
    property string col6;
    property string col7;
    property string col8;
    property string col9;

    RowLayout {
        anchors.fill: parent;
        anchors.bottomMargin: horizontalLine ? 1 : 0
        spacing: 5

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 50

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col1
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 200
            Layout.minimumWidth: 200
            Layout.fillWidth: true

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col2
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 80

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col3
                }
            }
        }


        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 80

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col4 == -1 ? "" : col4
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 80

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col5 == -1 ? "" : col5
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 150

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col6 == -1 ? "" : col6
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 150

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col7 == -1 ? "" : col7
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 80

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col8 == -1 ? "" : col8
                }
            }
        }

        Item {

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 90

            TableHeaderVerticalSplitter {
                height: parent.height
                anchors.left: parent.left
                visible: verticalLines
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 5

                NativeText {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: col9 == -1 ? "" : col9
                }
            }
        }
    }

    Rectangle {

        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
        color: "lightGrey"
        visible: horizontalLine
    }
}
