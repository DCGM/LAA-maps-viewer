import QtQuick 2.5

Image {
    anchors.fill: parent
    anchors.margins: 3
    mipmap: true
    fillMode: Image.PreserveAspectFit
    opacity: baseOpacity

    signal mouse_clicked();

    property double baseOpacity: 0.7

    MouseArea {
        anchors.fill: parent
        onClicked: mouse_clicked();
        hoverEnabled: true;

        onEntered: parent.opacity = 1
        onExited: parent.opacity = baseOpacity
    }
}
