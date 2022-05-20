import QtQuick 2.9

Image {
    property double baseOpacity: 0.7

    signal mouse_clicked()

    anchors.fill: parent
    anchors.margins: 3
    mipmap: true
    fillMode: Image.PreserveAspectFit
    opacity: baseOpacity

    MouseArea {
        anchors.fill: parent
        onClicked: mouse_clicked()
        hoverEnabled: true
        onEntered: parent.opacity = 1
        onExited: parent.opacity = baseOpacity
    }

}
