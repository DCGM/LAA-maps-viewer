import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ApplicationWindow {

    id: competitionConfiguration
    width: 500;
    height: 300;
    modality: "WindowModal"
    //% "Competition configuration"
    title: qsTrId("competition-configuration-dialog-title")
    color: "#ffffff"

    property string competitionName: "competitionName";
    property string competitionType: "0";
    property string competitionTypeText: "";
    property string competitionDirector: "competitionDirector";
    property string competitionDirectorAvatar: "";
    property variant competitionArbitr: ["competitionArbitr"];
    property variant competitionArbitrAvatar: [""];
    property string competitionDate: "01.01.2001";

    onVisibleChanged: {

        // set current competition property
        if (visible) {

            competitionName.text = competitionConfiguration.competitionName;
            competitionType.currentIndex = parseInt(competitionConfiguration.competitionType);
            competitionDirector.text = competitionConfiguration.competitionDirector;
            competitionArbitr.text = competitionConfiguration.competitionArbitr.join(", ");
            competitionDate.text = competitionConfiguration.competitionDate;
        }
    }

    function getCompetitionTypeString(type) {

        var str = "";

        switch(parseInt(type)) {

            case(0):
                //% "Navigation along known track"
                str = qsTrId("competition-type-navigation-along-known-track")
                break;
            case(1):
                //% "Navigation along unknown track"
                str = qsTrId("competition-type-navigation-along-unknown-track")
                break;
            case(2):
                //% "Economy"
                str = qsTrId("competition-type-economy")
                break;
            case(3):
                //% "Search of objects"
                str = qsTrId("competition-type-search-of-objects")
                break;
            case(4):
                //% "Triangle"
                str = qsTrId("competition-type-Triangle")
                break;
            case(5):
                //% "Landing"
                str = qsTrId("competition-type-landing")
                break;
            case(6):
                //% "Other"
                str = qsTrId("competition-type-other")
                break;
            default:
                str = "unknown competition type";

        }

        return str;
    }

    ListModel {

        id: competitionTypeListModel

        ListElement { text: qsTrId("competition-type-navigation-along-known-track") }
        ListElement { text: qsTrId("competition-type-navigation-along-unknown-track") }
        ListElement { text: qsTrId("competition-type-economy") }
        ListElement { text: qsTrId("competition-type-search-of-objects") }
        ListElement { text: qsTrId("competition-type-Triangle") }
        ListElement { text: qsTrId("competition-type-landing") }
        ListElement { text: qsTrId("competition-type-other") }
    }

    CalendarWindow {

        id: celandar

        onAccepted: {

            competitionDate.text = date;
        }
    }

    GridLayout {

        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10
        columnSpacing: 10;
        rowSpacing: 10;
        columns: 2
        rows: 5

        NativeText {
            //% "Competition name"
            text: qsTrId("competition-configuration-competition-name")
        }

        TextField {
            id: competitionName
            //text: competitionName_default
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Competition type"
            text: qsTrId("competition-configuration-competition-type")
        }

        ComboBox {

            id: competitionType
            model: competitionTypeListModel
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }


        NativeText {
            //% "Competition director"
            text: qsTrId("competition-configuration-competition-director")
        }

        TextField {
            id: competitionDirector
            //text: competitionDirector_default
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Competition arbitr"
            text: qsTrId("competition-configuration-competition-arbitr")
        }

        TextField {
            id: competitionArbitr
            //text: competitionArbitr_default
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2
        }

        NativeText {
            //% "Competition date"
            text: qsTrId("competition-configuration-competition-date")
        }

        TextField {
            id: competitionDate
            //text: competitionDate_default
            Layout.fillWidth:true;
            Layout.preferredWidth: parent.width/2

            MouseArea {
                anchors.fill: parent

                onClicked:  {

                    celandar.visible = true;
                }
            }
        }
    }


    /// Action Buttons
    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("path-configuration-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                // save changes into DB
                config.set("competitionName_default", competitionName.text);
                config.set("competitionType_default", competitionType.currentIndex);
                config.set("competitionDirector_default", competitionDirector.text);
                config.set("competitionDirectorAvatar_default", JSON.stringify(""));

                // split string into array od arbiters
                var arr = [];
                var re = /\s*[,;]\s*/;
                arr = competitionArbitr.text.split(re);

                // push empty string for default avatar
                var arrAvatar = [];
                for (var i = 0; i < arr.length; i++) { arrAvatar.push(""); }

                config.set("competitionArbitr_default", JSON.stringify(arr));
                config.set("competitionArbitrAvatar_default", JSON.stringify(arrAvatar));
                config.set("competitionDate_default", competitionDate.text);

                competitionConfiguration.competitionName = competitionName.text;
                competitionConfiguration.competitionType = competitionType.currentIndex
                competitionConfiguration.competitionTypeText = getCompetitionTypeString(parseInt(competitionType));
                competitionConfiguration.competitionDirector = competitionDirector.text;
                competitionConfiguration.competitionDirectorAvatar = "";
                competitionConfiguration.competitionArbitr = arr;
                competitionConfiguration.competitionArbitrAvatar = arrAvatar;
                competitionConfiguration.competitionDate = competitionDate.text;

                competitionConfiguration.close();
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("path-configuration-ok-cancel")
            onClicked: {

                competitionConfiguration.close()
            }
        }
    }
}
