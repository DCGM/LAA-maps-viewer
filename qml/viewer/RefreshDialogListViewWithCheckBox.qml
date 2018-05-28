import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

Rectangle {

    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 10
    anchors.rightMargin: 30
    height: listView.contentHeight + selectAllCheckBoxItem.height + 1
    border.color: "grey"
    border.width: 1

    property variant model;

    Item {

        id: selectAllCheckBoxItem
        width: listView.width
        height: 30
        anchors.top: parent.top

        CheckBox {

            id: selectAllCheckBox
            anchors.fill: parent
            anchors.topMargin: 9
            anchors.leftMargin: 6

            property int checkedData: column.model.selectedAll;

            onCheckedDataChanged: {
                checked = checkedData;
            }

            onClicked: {

                for(var i = 0; i < column.model.count; ++i) {
                    column.model.setProperty(i, "selected", checked ? 1 : 0);
                }
            }
        }
    }

    ListView {
        id: listView
        model: column.model
        anchors.top: selectAllCheckBoxItem.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.bottomMargin: 1

        interactive: false

        delegate: ModifiedContestantsDelegate {
        }
    }
}
