import QtQuick 2.9

Rectangle {
    property color backgroundColor: "#cccccc"
    property color textColor: "#ffffff"
    property alias text: headerTextItem.text

    height: 30
    anchors.left: parent.left
    anchors.right: parent.right

    NativeText {
        id: headerTextItem

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        font.pixelSize: 22
        anchors.verticalCenter: parent.verticalCenter
    }

    gradient: Gradient {
        GradientStop {
            position: 0
            color: backgroundColor
        }

        GradientStop {
            position: 0.5
            color: Qt.darker(backgroundColor, 1.2)
        }

        GradientStop {
            position: 1
            color: Qt.darker(backgroundColor, 1.5)
        }

    }

}
