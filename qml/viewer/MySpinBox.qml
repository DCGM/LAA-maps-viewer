import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

SpinBox {

    property int mwidth;
    property int mheight;

    style: SpinBoxStyle{
        horizontalAlignment: Qt.AlignLeft
        background: Rectangle {
            implicitWidth: mwidth
            implicitHeight: mheight
            border.color: "black"
            radius: 2
            }
        }
}
