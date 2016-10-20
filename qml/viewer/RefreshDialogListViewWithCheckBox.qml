import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Column {

    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    height: listView.height + listView.topMargin + selectAllCheckBox.height + spacing
    spacing: 10

    property variant model;

    CheckBox {

        id: selectAllCheckBox
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right

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

    ListView {

        id: listView
        model: column.model
        anchors.left: parent.left
        anchors.right: parent.right
        height: model.count * 30

        delegate: ModifiedContestantsDelegate {
        }
    }
}

