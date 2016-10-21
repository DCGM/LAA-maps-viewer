import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Rectangle {

    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 10
    anchors.rightMargin: 30
    height: model.count * 30 + selectAllCheckBoxItem.height + 1
    border.color: "grey"
    border.width: 1

    property variant model;

    onHeightChanged: console.log("h comp column " + height + "model count  " + model.count)
    onWidthChanged:  console.log("w comp column " + width + "model count  " + model.count)

    //Column {

      //  /anchors.fill: parent
       // anchors.margins: 1

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

   /*     Rectangle {

            anchors.top: selectAllCheckBox.bottom
            width: parent.width
            height: column.model.count * 30

            color: "red"
        }*/




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

            //width: parent.width - 2
           // height: column.model.count * 30
            interactive: false

            delegate: ModifiedContestantsDelegate {
            }
        }
   // }

}

/*
Column {

    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 10
    anchors.rightMargin: 30
    height: listViewRect.height + checkBoxRect.height

    property variant model;

    // prasarna, ale jinak jsem tam to ramovani nedostal
    Rectangle {
        id: checkBoxRect
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        border.color: "grey"
        border.width: 1

        CheckBox {

            id: selectAllCheckBox
            anchors.leftMargin: 5
            anchors.fill: parent
            anchors.topMargin: 5

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
    // prasarna, ale jinak jsem tam to ramovani nedostal
    Rectangle {

        id: listViewRect
        anchors.left: parent.left
        anchors.right: parent.right
        height: column.model.count * 30 + 1
        border.color: "grey"
        border.width: 1

        //ScrollView {
//width: 1900
           // anchors.fill: parent

            ListView {
                id: listView
                model: column.model

                anchors.fill: parent
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.bottomMargin: 1
                anchors.topMargin: -1
                interactive: false

                delegate: ModifiedContestantsDelegate {
                }
            }
       // }
    }
}

*/

