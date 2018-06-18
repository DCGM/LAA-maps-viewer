import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

TextField {

    id: textField

    property int mwidth;
    property int mheight;

    readOnly: false;
    style: TextFieldStyle {
            textColor: "black"
            renderType: Text.NativeRendering

            background: Rectangle {
                        radius: 2
                        implicitWidth: mwidth
                        implicitHeight: mheight
                        border.color: textField.focus ? "#0077cc" : "gray"
                        border.width: 1
                    }
        }
}
