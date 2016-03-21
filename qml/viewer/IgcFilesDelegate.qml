import QtQuick 2.5
import QtQuick.Controls 1.4


Item {
    id: delegate
    property variant comboModel
    anchors.fill: parent;
    signal changeModel(int row, string role, variant value);


    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: styleData.value
        color: styleData.textColor

        visible: (styleData.role === "fileName")
    }

    Loader { // Initialize text editor lazily to improve performance
        id: loaderCombobox
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderCombobox.item

            onContestantSelected: {
                if (t < 0 ) {
// FIXME
//                    console.log("comboSet: " +styleData.row+", "+styleData.role+", "+t)
                    return;
                }

                changeModel(styleData.row, styleData.role, t)
            }

        }

        sourceComponent: (styleData.role === "contestant") ? contestantComboComponent : null

        Component {
            id: contestantComboComponent
            ComboBox {
                width: delegate.width - 10;
                signal contestantSelected(int t);

                currentIndex: parseInt(styleData.value)
                onCurrentIndexChanged: {
                    contestantSelected(currentIndex)
                }

                model: delegate.comboModel
                textRole: "name"


            }
        }
    }



}
