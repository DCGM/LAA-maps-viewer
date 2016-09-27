import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ApplicationWindow {

    id: pathConfiguration
    width: 700;
    height: 700;//500;
    modality: "WindowModal"
    //% "Environment configuration"
    title: qsTrId("path-configuration-dialog-title")
    color: "#ffffff"

    property alias igcDirectory: igcDirectoryTextField.text
    property string igcDirectory_default: Qt.resolvedUrl("../../../igcFiles");
    //property string igcDirectory_default: config.get("igcDirectory_default", Qt.resolvedUrl("../../../igcFiles"));

    property alias trackFile: trackFileTextField.text
    property string trackFile_default: Qt.resolvedUrl("../../../track.json");
    //property string trackFile_default: config.get("trackFile_default", Qt.resolvedUrl("../../../track.json"));

    property alias resultsFolder: resultsFolderTextField.text;
    property string resultsFolder_default: Qt.resolvedUrl("../../../results");
    //property string resultsFolder_default: config.get("resultsFolder_default", Qt.resolvedUrl("../../../results"));

    property string contestantsFile: resultsFolderTextField.text + "/posadky.csv"
    property string csvFile: resultsFolderTextField.text + "/tucek.csv"
    property string tsFile: resultsFolderTextField.text + "/tucek-settings.csv"
    property string assignFile: resultsFolderTextField.text + "/assign.csv"
    property string csvResultsFile: resultsFolderTextField.text + "/results.csv"

    signal ok();
    signal cancel();

    property string contestantsDownloadedString;
    property bool online: status_online.checked;


    property string competitionName: qsTrId("competition-configuration-competition-name");
    property string competitionType: "0";
    property string competitionTypeText: "";
    property string competitionDirector: qsTrId("competition-configuration-competition-director");
    property string competitionDirectorAvatar: "";
    property variant competitionArbitr: [qsTrId("competition-configuration-competition-arbitr")];
    property variant competitionArbitrAvatar: [""];
    property string competitionDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy");

    property string selectedCompetition: "";

    property alias competitionNameTextAlias: competitionName.text;
    property alias competitionTypeIndexAlias: competitionType.currentIndex;
    property alias competitionTyoeTextAlias: competitionType.currentText;
    property alias competitionDirectorTextAlias: competitionDirector.text;
    property alias competitionArbitrTextAlias: competitionArbitr.text;
    property alias competitionDateTextAlias: competitionDate.text;

    property alias downloadedCompetitionNameAlias: status_online_text_field.text;

    property int onlineOfflineCheckBox: 0;
    property int trackCheckBox: 0;
    property int igcFolderCheckBox: 0;
    property int resultsFolderCheckBox: 0;

    property alias trackUserDefinedCheckBoxAlias: track_user_defined.checked;
    property alias trackDefaultCheckBoxAlias: track_default.checked;
    property alias trackFileTextFieldAlias: trackFileTextField.text;

    property alias igcFolderUserDefinedCheckBoxAlias: igc_user_defined.checked;
    property alias igcFolderDefaultCheckBoxAlias: igc_default.checked;
    property alias igcDirectoryTextFieldAlias: igcDirectoryTextField.text;

    property alias resultsFolderUserDefinedCheckBoxAlias: resultsFolder_user_defined.checked;
    property alias resultsFolderDefaultCheckBoxAlias: results_default.checked;
    property alias resultsFolderTextFieldAlias: resultsFolderTextField.text;

    property alias onlineOfflineUserDefinedCheckBoxAlias: status_online.checked;
    property alias onlineOfflineDefaultCheckBoxAlias: status_default.checked;

    onOnlineOfflineDefaultCheckBoxAliasChanged: {

        // remove downloaded data
        if(onOnlineOfflineDefaultCheckBoxAliasChanged) {

            initCompetitionPropertyOffline();
        }
    }

    onVisibleChanged: {

        // set current competition property
        if (visible) {

            // checkboxs and selected comp name
            downloadedCompetitionNameAlias = pathConfiguration.selectedCompetition; // must be set, when checkbox changed

            trackUserDefinedCheckBoxAlias = trackCheckBox === 1;
            trackDefaultCheckBoxAlias = !trackUserDefinedCheckBoxAlias;

            igcFolderUserDefinedCheckBoxAlias = igcFolderCheckBox === 1;
            igcFolderDefaultCheckBoxAlias = !igcFolderUserDefinedCheckBoxAlias;

            resultsFolderUserDefinedCheckBoxAlias = resultsFolderCheckBox === 1;
            resultsFolderDefaultCheckBoxAlias = !resultsFolderUserDefinedCheckBoxAlias;

            onlineOfflineUserDefinedCheckBoxAlias = onlineOfflineCheckBox === 1;
            onlineOfflineDefaultCheckBoxAlias = !onlineOfflineUserDefinedCheckBoxAlias;

            downloadedCompetitionNameAlias = pathConfiguration.selectedCompetition; //reinit value, checkbox deleted textfield value

            // competition property
            competitionNameTextAlias = pathConfiguration.competitionName;
            competitionTypeIndexAlias = parseInt(pathConfiguration.competitionType);
            competitionDirectorTextAlias = pathConfiguration.competitionDirector;
            competitionArbitrTextAlias = pathConfiguration.competitionArbitr.join(", ");
            competitionDateTextAlias = pathConfiguration.competitionDate;
        }
    }

    // remove downloaded values and init text field
    function initCompetitionPropertyOffline() {

        competitionNameTextAlias = qsTrId("competition-configuration-competition-name");
        competitionTypeIndexAlias =  0;
        competitionDirectorTextAlias = qsTrId("competition-configuration-competition-director");
        competitionArbitrTextAlias = [qsTrId("competition-configuration-competition-arbitr")].join(", ");
        competitionDateTextAlias = Qt.formatDateTime(new Date(), "dd.MM.yyyy");

        contestantsDownloadedString = "";
        downloadedCompetitionNameAlias = "";
    }

    FileDialog {
        id: igcFolderDialog
        selectFolder: true;
        selectMultiple: false
        //% "IGC Folder"
        title: qsTrId("path-configuration-dialog-title-igc-folder")
        folder:  Qt.resolvedUrl("../../..");

        onRejected: {

            // set to default - nothing selected
            if (igcDirectoryTextFieldAlias === "") {
                igcFolderDefaultCheckBoxAlias = true;
            }
        }
    }

    FileDialog {
        id: trackFileDialog
        selectFolder: false;
        selectMultiple: false
        //% "Track"
        title: qsTrId("path-configuration-dialog-title-")
        nameFilters: [ "Tucek json (*.json)", "All files (*)" ]
        folder:  Qt.resolvedUrl("../../..");

        onRejected: {

            // set to default - nothing selected
            if (trackFileTextFieldAlias === "") {
                trackDefaultCheckBoxAlias = true;
            }
        }
    }

    FileDialog {
        id: resultsDirectoryDialog
        selectFolder: true;
        selectMultiple: false;
        //% "Flight results"
        title: qsTrId("path-configuration-dialog-title-filight-results")

        folder:  Qt.resolvedUrl("../../..");

        onRejected: {

            // set to default - nothing selected
            if (resultsFolderTextFieldAlias === "") {
                resultsFolderDefaultCheckBoxAlias = true;
            }
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

    ColumnLayout {
        id: mainColumn
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10
        spacing: 10;

        ///// Track
        ExclusiveGroup { id: trackGroup }

        NativeText {
            //% "Track"
            text: qsTrId("path-configuration-track")
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: track_default
                exclusiveGroup: trackGroup
                //% "Default"
                text: qsTrId("path-configuration-track-default")
                checked: true
            }
        }

        RowLayout {
            spacing: 10;
            anchors.left: parent.left
            anchors.right: parent.right
            Spacer {}

            RadioButton {
                id: track_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-track-user-defined")
                exclusiveGroup: trackGroup
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
                id: trackFileTextField
                text: track_user_defined.checked ? trackFileDialog.fileUrl : trackFile_default
                readOnly: !track_user_defined.checked
                Layout.fillWidth:true;
                Layout.preferredWidth: parent.width/2
                anchors.verticalCenter: parent.verticalCenter
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-track-browse");
                enabled: track_user_defined.checked
                //width: pathConfiguration.thirdColumnWidth;
                onClicked: {
                    trackFileDialog.open();
                }
            }

        }


        ///// IGC folder
        ExclusiveGroup { id: igcGroup }

        NativeText {
            //% "IGC Folder"
            text: qsTrId("path-configuration-igc-folder")
        }

        RowLayout {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: igc_default
                exclusiveGroup: igcGroup
                //% "Default"
                text: qsTrId("path-configuration-igc-folder-default")
                checked: true
            }
        }

        RowLayout {
            spacing: 10;
            anchors.left: parent.left
            anchors.right: parent.right
            Spacer {}

            RadioButton {
                id: igc_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-igc-folder-user-defined")
                exclusiveGroup: igcGroup
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
                id: igcDirectoryTextField
                text: igc_user_defined.checked ? igcFolderDialog.fileUrl : igcDirectory_default
                readOnly: !igc_user_defined.checked
                Layout.fillWidth:true;
                Layout.preferredWidth: parent.width/2
                anchors.verticalCenter: parent.verticalCenter
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-igc-folder-browse-button");
                enabled: igc_user_defined.checked
                //width: pathConfiguration.thirdColumnWidth;
                onClicked: {
                    igcFolderDialog.open();
                }
            }

        }

        ExclusiveGroup { id: resultsFolderGroup }


        NativeText {
            //% "Working directory"
            text: qsTrId("path-configuration-flight-results")
        }

        RowLayout {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: results_default
                exclusiveGroup: resultsFolderGroup
                //% "Default"
                text: qsTrId("path-configuration-flight-results-default")
                checked: true
            }
        }

        RowLayout {
            spacing: 10;
            anchors.left: parent.left
            anchors.right: parent.right
            Spacer {}

            RadioButton {
                id: resultsFolder_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-flight-results-user-defined")
                exclusiveGroup: resultsFolderGroup
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
                id: resultsFolderTextField
                text: resultsFolder_user_defined.checked ? resultsDirectoryDialog.fileUrl : resultsFolder_default
                readOnly: !resultsFolder_user_defined.checked
                Layout.fillWidth:true;
                Layout.preferredWidth: parent.width/2
                anchors.verticalCenter: parent.verticalCenter
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-flight-results-browse");
                enabled: resultsFolder_user_defined.checked
                //width: pathConfiguration.thirdColumnWidth;
                onClicked: {
                    resultsDirectoryDialog.open();
                }
            }

        }

        ///// Server
        ExclusiveGroup { id: statusGroup }

        NativeText {
            //% "Competition"
            text: qsTrId("path-configuration-competition")
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: status_default
                exclusiveGroup: statusGroup
                //% "Offline"
                text: qsTrId("path-configuration-competition-offline")
                checked: true
            }
        }

        RowLayout {
            spacing: 10;
            anchors.left: parent.left
            anchors.right: parent.right
            Spacer {}

            RadioButton {
                id: status_online
                //% "Online"
                text: qsTrId("path-configuration-competition-online")
                exclusiveGroup: statusGroup
                anchors.verticalCenter: parent.verticalCenter

                onCheckedChanged: {

                    if (checked && pathConfiguration.downloadedCompetitionNameAlias === "") {

                        selectCompetitionOnlineDialog.show();
                    }
                }
            }
            TextField {
                id: status_online_text_field
                //text: status_online.checked ? selectCompetitionOnlineDialog.selectedCompetition : ""
                readOnly: true
                Layout.fillWidth:true;
                Layout.preferredWidth: parent.width/2
                anchors.verticalCenter: parent.verticalCenter
            }
            Button {
                //% "Connect ..."
                text: qsTrId("path-configuration-competition-connect");
                enabled: status_online.checked
                onClicked: {

                    selectCompetitionOnlineDialog.show();
                }
            }
        }

        GridLayout {

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

    } // Item visible false


    /// Action Buttons

    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("path-configuration-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                // split string into array od arbiters
                var arr = [];
                var re = /\s*[,;]\s*/;
                arr = competitionArbitrTextAlias.split(re);

                // push empty string for default avatar
                var arrAvatar = [];
                for (var i = 0; i < arr.length; i++) { arrAvatar.push(""); }

                // save current values
                pathConfiguration.competitionName = competitionNameTextAlias;
                pathConfiguration.competitionType = String(competitionTypeIndexAlias);
                pathConfiguration.competitionTypeText = competitionTyoeTextAlias;
                pathConfiguration.competitionDirector = competitionDirectorTextAlias;
                pathConfiguration.competitionDirectorAvatar = online ? competitionDirectorAvatar : "";    // online - field already set/offline clear item
                pathConfiguration.competitionArbitr = arr;
                pathConfiguration.competitionArbitrAvatar = online ? competitionArbitrAvatar : arrAvatar; // online - field already set/offline set array of empty strings
                pathConfiguration.competitionDate = competitionDateTextAlias;

                pathConfiguration.selectedCompetition = downloadedCompetitionNameAlias;

                pathConfiguration.onlineOfflineCheckBox = onlineOfflineUserDefinedCheckBoxAlias ? 1 : 0;
                pathConfiguration.trackCheckBox = trackUserDefinedCheckBoxAlias ? 1 : 0;
                pathConfiguration.igcFolderCheckBox = igcFolderUserDefinedCheckBoxAlias ? 1 : 0;
                pathConfiguration.resultsFolderCheckBox = resultsFolderUserDefinedCheckBoxAlias ? 1 : 0;

                config.set("igcDirectory_default", igcDirectoryTextField.text);
                config.set("trackFile_default", trackFileTextField.text);
                config.set("resultsFolder_default", resultsFolderTextField.text);

                ok();
                pathConfiguration.close();
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("path-configuration-ok-cancel")
            onClicked: {
                cancel();
                pathConfiguration.close()

            }
        }
    }
}
