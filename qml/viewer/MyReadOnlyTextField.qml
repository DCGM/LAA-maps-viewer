import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

TextField {

    property int mwidth;
    property int mheight;

    readOnly: true;
    style: TextFieldStyle {
            textColor: "gray"

            background: Rectangle {
                        radius: 2
                        implicitWidth: mwidth
                        implicitHeight: mheight
                        border.color: "gray"
                        border.width: 1
                    }
        }
}
