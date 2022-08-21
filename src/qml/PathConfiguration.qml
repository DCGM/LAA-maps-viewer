import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "functions.js" as F
import "md5.js" as MD5
import "./components"

ApplicationWindow {

    id: pathConfiguration
    width: 700;
    height: 500;
    minimumHeight: 550
    minimumWidth: 750
    modality: Qt.ApplicationModal

    //% "Configuration"
    title: qsTrId("path-configuration-dialog-title")
    color: "#ffffff"

    property bool autoConfirmFlag: false;
    property bool dontShowRegenResultsDialog: false;
    property string igcDirectory_default: Qt.resolvedUrl("file:///"+QStandardPathsApplicationFilePath+"/../igcFiles");
    property string igcDirectory_user_defined;

    property string trackFile_default: Qt.resolvedUrl("file:///"+QStandardPathsApplicationFilePath+"/../track.json");
    property string trackFile_user_defined;

    property string resultsFolder_default: Qt.resolvedUrl("file:///"+QStandardPathsApplicationFilePath+"/../results");
    property string resultsFolder_user_defined;

    property string contestantsFile: pathConfiguration.resultsFolder + "/" + contestantsFileName
    property string csvFile: pathConfiguration.resultsFolder + "/tucek.csv"
    property string tsFile: pathConfiguration.resultsFolder + "/tucek-settings.csv"
    property string assignFile: pathConfiguration.resultsFolder + "/assign.csv"
    property string csvResultsFile: pathConfiguration.resultsFolder + "/results.csv"
    property string jsonDump: pathConfiguration.resultsFolder + "/tucek.json"


    property string contestantsFileName: "posadky.csv"

    property string requestedDateFormat: "yyyy-MM-dd";

    property string igcDirectory;
    property string trackFile;
    property string resultsFolder;

    property bool enableSelfIntersectionDetector: false;

    signal ok();
    signal cancel();

    property string contestantsDownloadedString: "";

    property bool online;   // changed when checkbox changed

    property string competitionName: "";
    property string competitionType: "0";
    property string competitionTypeText: getCompetitionTypeString(parseInt(pathConfiguration.competitionType, 10));
    property string competitionDirector: "";
    property string competitionDirectorAvatar: "";
    property variant competitionArbitr: [""];
    property variant competitionArbitrAvatar: [""];
    property string competitionDate: "";
    property string competitionRound: "";
    property string competitionGroupName: "";

    onCompetitionDateChanged: {

        applicationWindow.utc_offset_sec = cppWorker.getOffsetFromUtcSec(competitionDate, pathConfiguration.requestedDateFormat);
        console.log("calc UTC offset: " + applicationWindow.utc_offset_sec + "/" + competitionDate);
    }

    property string base_url: F.base_url_default
    property string api_key_get_url: pathConfiguration.base_url + "/apiKeys.php?action=create"

    property string prev_api_base_url: F.base_url_default
    property string prevApi_key: ""
    property string apiKeyStatus: "unknown" // ["ok", "nok", "unknown"]

    property string prevUserNameValidity: "";
    property string prevUserKeyValidity: "";

    property bool contestantFileExist: false
    property bool trackFileExist: false

    onCompetitionTypeChanged: {

        pathConfiguration.competitionTypeText = getCompetitionTypeString(parseInt(pathConfiguration.competitionType));
    }

    property string competitionName_default: "";//qsTrId("competition-configuration-competition-name");
    property string competitionType_default: "0";
    property string competitionTypeText_default: "";
    property string competitionDirector_default: ""//qsTrId("competition-configuration-competition-director");
    property string competitionDirectorAvatar_default: "";
    property variant competitionArbitr_default: [""]//[qsTrId("competition-configuration-competition-arbitr")];
    property variant competitionArbitrAvatar_default: [""];
    property string competitionDate_default: ""//Qt.formatDateTime(new Date(), pathConfiguration.requestedDateFormat);
    property string competitionRound_default: "";
    property string competitionGroupName_default: "";

    property string selectedCompetition: "";

    property int onlineOfflineCheckBox: 0;
    property int trackCheckBox: 0;
    property int igcFolderCheckBox: 0;
    property int resultsFolderCheckBox: 0;

    property string prevSettingsMD5: "";
    property string currentSettingsMD5: "";

    onVisibleChanged: {

        // set current competition property
        if (visible) {

            // get last known api_key
            prev_api_base_url = config.get("api_base_url", "https://ppt.laacr.cz");
            prevApi_key = config.get("api_key", "");
            prevUserNameValidity = config.get("userNameValidity", "");
            prevUserKeyValidity = config.get("userKeyValidity", "");

            // set previous api key
            setLoginTabValues(prev_api_base_url, prevApi_key, prevUserNameValidity, prevUserKeyValidity);

            // set previous enviroment tab values
            setFilesTabContent(pathConfiguration.selectedCompetition,
                               pathConfiguration.trackCheckBox,
                               pathConfiguration.igcFolderCheckBox,
                               pathConfiguration.resultsFolderCheckBox,
                               pathConfiguration.onlineOfflineCheckBox,
                               pathConfiguration.enableSelfIntersectionDetector
                               );

            // competition property
            setCompetitionTabContent(pathConfiguration.competitionName,
                                     pathConfiguration.competitionType,
                                     pathConfiguration.competitionDirector,
                                     pathConfiguration.competitionArbitr.join(", "),
                                     pathConfiguration.competitionDate,
                                     pathConfiguration.competitionRound,
                                     pathConfiguration.competitionGroupName);

            // folder status
            contestantFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile));
            trackFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile));

            // MD5 from comp. property
            prevSettingsMD5 = MD5.md5(JSON.stringify(getCompetitionTabContent()));
        }
        else {

            // clear MD5 if there is no reason to regenerate results - first start
            if (dontShowRegenResultsDialog) {
                prevSettingsMD5 = currentSettingsMD5;
            }

            dontShowRegenResultsDialog = false;
            autoConfirmFlag = false;
        }
    }

    // confirm and close automatically dialog - used when prev enviroment settings is loaded from DB
    onAfterRendering: {
//    onAfterSynchronizing: {

        if(visible && autoConfirmFlag) {

            autoConfirmFlag = false;
            okButton.clicked();
        }
    }

    function getLoginTabValues() {
        var ret = [];

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "login");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("login");

        // load data into array

        ret.push(tabView.loginTabAlias.apiBaseUrlAlias)
        ret.push(tabView.loginTabAlias.apiKeyAlias)
        ret.push(tabView.loginTabAlias.userNameValidityAlias)
        ret.push(tabView.loginTabAlias.userKeyValidityAlias)

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setLoginTabValues(api_base_url, api_key, prevUserNameValidity, prevUserKeyValidity) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "login");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("login");

        // login property
        tabView.loginTabAlias.apiBaseUrlAlias = api_base_url;
        tabView.loginTabAlias.apiKeyAlias = api_key;
        tabView.loginTabAlias.userNameValidityAlias = prevUserNameValidity;
        tabView.loginTabAlias.userKeyValidityAlias = prevUserKeyValidity;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }


    function getEnviromentTabContent() {

        var ret = [];

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");

        // load data into array
        ret.push(tabView.pathTabAlias.downloadedCompetitionNameAlias)
        ret.push(tabView.pathTabAlias.trackUserDefinedCheckBoxAlias)
        ret.push(tabView.pathTabAlias.igcFolderUserDefinedCheckBoxAlias)
        ret.push(tabView.pathTabAlias.resultsFolderUserDefinedCheckBoxAlias)
        ret.push(tabView.pathTabAlias.onlineOfflineUserDefinedCheckBoxAlias)
        ret.push(tabView.pathTabAlias.trackFileTextFieldAlias);
        ret.push(tabView.pathTabAlias.igcDirectoryTextFieldAlias);
        ret.push(tabView.pathTabAlias.resultsFolderTextFieldAlias);

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setFilesTabContent(selectedCompetition, trackCheckBox, igcFolderCheckBox, resultsFolderCheckBox, onlineOfflineCheckBox, selfIntersectionDetector) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");

        tabView.pathTabAlias.downloadedCompetitionNameAlias = selectedCompetition; // must be set, when checkbox changed

        tabView.pathTabAlias.trackUserDefinedCheckBoxAlias = trackCheckBox === 1;
        tabView.pathTabAlias.trackDefaultCheckBoxAlias = !tabView.pathTabAlias.trackUserDefinedCheckBoxAlias;

        tabView.pathTabAlias.igcFolderUserDefinedCheckBoxAlias = igcFolderCheckBox === 1;
        tabView.pathTabAlias.igcFolderDefaultCheckBoxAlias = !tabView.pathTabAlias.igcFolderUserDefinedCheckBoxAlias;

        tabView.pathTabAlias.resultsFolderUserDefinedCheckBoxAlias = resultsFolderCheckBox === 1;
        tabView.pathTabAlias.resultsFolderDefaultCheckBoxAlias = !tabView.pathTabAlias.resultsFolderUserDefinedCheckBoxAlias;

        tabView.pathTabAlias.onlineOfflineUserDefinedCheckBoxAlias = onlineOfflineCheckBox === 1;
        tabView.pathTabAlias.onlineOfflineDefaultCheckBoxAlias = !tabView.pathTabAlias.onlineOfflineUserDefinedCheckBoxAlias;

        tabView.pathTabAlias.downloadedCompetitionNameAlias = selectedCompetition; //reinit value, checkbox deleted textfield value
        tabView.pathTabAlias.selfIntersectionDetectorAlias = selfIntersectionDetector;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }

    function getEnviromentTabCompName() {

        var ret = "";

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "competition");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("competition");

        // load data into array
        ret = tabView.pathTabAlias.downloadedCompetitionNameAlias;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setEnviromentTabCompName(selectedCompetition) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");


        tabView.pathTabAlias.downloadedCompetitionNameAlias = selectedCompetition;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }

    function setEnviromentTabOnlineCheckBox(value) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");

        tabView.pathTabAlias.onlineOfflineUserDefinedCheckBoxAlias = value;
        tabView.pathTabAlias.onlineOfflineDefaultCheckBoxAlias = !value;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }


    function getCompetitionTabContent() {

        var ret = [];

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "competition");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("competition");

        // load data into array
        ret.push(tabView.competitionTabAlias.competitionNameTextAlias);
        ret.push(String(tabView.competitionTabAlias.competitionTypeIndexAlias));
        ret.push(tabView.competitionTabAlias.competitionTyoeTextAlias);
        ret.push(tabView.competitionTabAlias.competitionDirectorTextAlias);
        ret.push(tabView.competitionTabAlias.competitionArbitrTextAlias);
        ret.push(tabView.competitionTabAlias.competitionDateTextAlias);
        ret.push(tabView.competitionTabAlias.competitionRoundTextAlias);
        ret.push(tabView.competitionTabAlias.competitionGroupNameTextAlias);

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setCompetitionTabContent(competitionName, competitionType, competitionDirector, competitionArbitr, competitionDate, competitionRound, competitionGroupName) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "competition");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("competition");

        // competition property
        tabView.competitionTabAlias.competitionNameTextAlias = competitionName;
        tabView.competitionTabAlias.competitionTypeIndexAlias = parseInt(competitionType);
        tabView.competitionTabAlias.competitionDirectorTextAlias = competitionDirector;
        tabView.competitionTabAlias.competitionArbitrTextAlias = competitionArbitr;
        tabView.competitionTabAlias.competitionDateTextAlias = (competitionDate === "" ? Qt.formatDateTime(new Date(), pathConfiguration.requestedDateFormat) :competitionDate.replace(/\./g, "-"));

        tabView.competitionTabAlias.competitionRoundTextAlias = competitionRound;
        tabView.competitionTabAlias.competitionGroupNameTextAlias = competitionGroupName;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }

    function setCompetitionTabDate(competitionDate) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");

        // competition property
        tabView.competitionTabAlias.competitionDateTextAlias = competitionDate;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)
    }

    // remove downloaded values and init text field
    function initCompetitionPropertyOffline() {

        setCompetitionTabContent(competitionName_default,
                                 parseInt(competitionType_default),
                                 competitionDirector_default,
                                 competitionArbitr_default.join(", "),
                                 competitionDate_default,
                                 competitionRound_default,
                                 competitionGroupName_default);

        competitionDirectorAvatar = competitionDirectorAvatar_default;
        competitionArbitrAvatar = competitionArbitrAvatar_default;

        contestantsDownloadedString = "";
    }


    TabView {
        id: tabView
        Layout.fillWidth: true;
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10;


        property alias pathTabAlias: pathTab.item;
        property alias competitionTabAlias: competitionTab.item;
        property alias loginTabAlias: loginTab.item;

        function getActive() {
            if (pathTab.visible) {
                return "path";
            }
            if (competitionTab.visible) {
                return "competition";
            }
            if (loginTab.visible) {
                return "login"
            }
            return "";

        }

        function activateTabByName(name) {
            pathTab.visible = false;
            competitionTab.visible = false;
            loginTab.visible = false;
            switch (name) {
            case "path":
                pathTab.visible = true;
                break;
            case "competition":
                competitionTab.visible = true;
                break;
            case "login":
                loginTab.visible = true;
                break;
            }

        }

        Tab {
            id: pathTab
            //% "Environment"
            title: qsTrId("path-configuration-environment-tab-title")

            GridLayout {
                id: mainColumn
                anchors.fill: parent
                anchors.margins: 10
                //spacing: 10;
                columnSpacing: 10
                columns: 1

                property alias downloadedCompetitionNameAlias: status_online_text_field.text;

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

                property alias selfIntersectionDetectorAlias: selfIntersectionCheckbox.checked;

                onOnlineOfflineDefaultCheckBoxAliasChanged: {

                    // remove downloaded data
                    if(onOnlineOfflineDefaultCheckBoxAliasChanged) {

                        initCompetitionPropertyOffline();
                        downloadedCompetitionNameAlias = "";
                    }

                    pathConfiguration.online = onlineOfflineUserDefinedCheckBoxAlias;
                }

                onOnlineOfflineUserDefinedCheckBoxAliasChanged: {
                    pathConfiguration.online = onlineOfflineUserDefinedCheckBoxAlias;
                }

                ///// Track
                ExclusiveGroup { id: trackGroup }

                NativeText {
                    //% "Track"
                    text: qsTrId("path-configuration-track")
                }
/*
                RowLayout {
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
*/
                RowLayout {
                    spacing: 10;
                    Spacer {}

                    Item {

                        width: track_user_defined.width
                        height: tracksFolderRow.height

                        RadioButton {
                            id: track_default
                            Layout.alignment: Qt.AlignVCenter;
                            exclusiveGroup: trackGroup
                            //% "Default"
                            text: qsTrId("path-configuration-track-default")
                            checked: true
                        }
                    }

                    Item {
                        width: 25
                        height: 25
                        Layout.alignment: Qt.AlignVCenter;

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:///images/ic_warning_black_48dp_1x.png"
                            opacity: 0.7
                            mipmap: true
                            visible: (!trackFileExist)
                        }
                    }

                    NativeText {
                        visible: (!trackFileExist)
                        //% "File not found!"
                        text: qsTrId("path-configuration-warning-not-found-trackFile");
                    }
                }

                RowLayout {
                    id: tracksFolderRow
                    spacing: 10;
                    Spacer {}

                    RadioButton {
                        id: track_user_defined
                        //% "User defined"
                        text: qsTrId("path-configuration-track-user-defined")
                        exclusiveGroup: trackGroup
                        Layout.alignment: Qt.AlignVCenter;

                        onCheckedChanged: {

                            if(checked && pathConfiguration.trackFile_user_defined === "") {

                                trackFileDialog.open();
                            }
                        }
                    }
                    TextField {
                        id: trackFileTextField
                        text: track_user_defined.checked ? pathConfiguration.trackFile_user_defined : trackFile_default
                        readOnly: true//!track_user_defined.checked
                        Layout.fillWidth:true;
                        Layout.preferredWidth: parent.width/2
                        Layout.alignment: Qt.AlignVCenter;

                        onTextChanged: {
                            pathConfiguration.trackFile = text;
                            trackFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.trackFile));
                        }
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
                    Spacer {}

                    RadioButton {
                        id: igc_user_defined
                        //% "User defined"
                        text: qsTrId("path-configuration-igc-folder-user-defined")
                        exclusiveGroup: igcGroup
                        Layout.alignment: Qt.AlignVCenter;

                        onCheckedChanged: {
                            if(checked && pathConfiguration.igcDirectory_user_defined === "") {
                                igcFolderDialog.open();
                            }
                        }

                    }
                    TextField {
                        id: igcDirectoryTextField
                        text: igc_user_defined.checked ? pathConfiguration.igcDirectory_user_defined : igcDirectory_default
                        readOnly: true//!igc_user_defined.checked
                        Layout.fillWidth:true;
                        Layout.preferredWidth: parent.width/2
                        Layout.alignment: Qt.AlignVCenter;

                        onTextChanged: {
                            pathConfiguration.igcDirectory = text;
                        }
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

                    Item {

                        width: resultsFolder_user_defined.width
                        height: resultsFolderRow.height

                        RadioButton {
                            id: results_default
                            exclusiveGroup: resultsFolderGroup
                            Layout.alignment: Qt.AlignVCenter;
                            //% "Default"
                            text: qsTrId("path-configuration-flight-results-default")
                            checked: true
                        }
                    }

                    Item {
                        width: 25
                        height: 25
                        Layout.alignment: Qt.AlignVCenter;

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:///images/ic_warning_black_48dp_1x.png"
                            opacity: 0.7
                            mipmap: true
                            visible: (!contestantFileExist && contestantsDownloadedString === "")
                        }
                    }

                    NativeText {
                        visible: (!contestantFileExist && contestantsDownloadedString === "")
                        //% "File %1 not found!"
                        text: qsTrId("path-configuration-warning-not-found-contestant-file").arg(pathConfiguration.contestantsFileName);
                    }
                }

                RowLayout {
                    id: resultsFolderRow
                    spacing: 10;
                    Spacer {}

                    RadioButton {
                        id: resultsFolder_user_defined
                        //% "User defined"
                        text: qsTrId("path-configuration-flight-results-user-defined")
                        exclusiveGroup: resultsFolderGroup
                        Layout.alignment: Qt.AlignVCenter;
                        onCheckedChanged: {
                            if(checked && pathConfiguration.resultsFolder_user_defined === "") {
                                resultsDirectoryDialog.open();
                            }
                        }

                    }
                    TextField {
                        id: resultsFolderTextField
                        text: resultsFolder_user_defined.checked ? pathConfiguration.resultsFolder_user_defined : resultsFolder_default
                        readOnly: true//!resultsFolder_user_defined.checked
                        Layout.fillWidth:true;
                        Layout.preferredWidth: parent.width/2
                        Layout.alignment: Qt.AlignVCenter;

                        onTextChanged: {
                            pathConfiguration.resultsFolder = text;
                            contestantFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile));
                        }
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
                    //% "Online offline regime"
                    text: qsTrId("path-configuration-online-offline-regime")
                }

                RowLayout {
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
                    Spacer {}

                        RadioButton {
                            id: status_online
                            //% "Online"
                            text: qsTrId("path-configuration-competition-online")
                            exclusiveGroup: statusGroup
                            Layout.alignment: Qt.AlignVCenter

                            onCheckedChanged: {

                                if (checked && pathConfiguration.getEnviromentTabCompName() === "") {

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
                        Layout.alignment: Qt.AlignVCenter;
                    }
                    Button {
                        //% "Browse ..."
                        text: qsTrId("path-configuration-competition-connect");
                        enabled: status_online.checked
                        onClicked: {

                            selectCompetitionOnlineDialog.show();
                        }
                    }
                }

                CheckBox{
                    id: selfIntersectionCheckbox
                    //% "Circling detection (could be slow)"
                    text: qsTrId("path-configuration-competition-circling-detection")
                    onCheckedChanged: {
                        pathConfiguration.enableSelfIntersectionDetector = checked
                    }
                }
            }
        }

        Tab {
            id: competitionTab
            //% "Competition"
            title: qsTrId("path-configuration-competition-tab-title")

            GridLayout {

                id:gridLayout
                anchors.fill: parent
                anchors.margins: 10
                columnSpacing: 10;
                columns: 2

                property alias competitionNameTextAlias: competitionName.text;
                property alias competitionTypeIndexAlias: competitionType.currentIndex;
                property alias competitionTyoeTextAlias: competitionType.currentText;
                property alias competitionDirectorTextAlias: competitionDirector.text;
                property alias competitionArbitrTextAlias: competitionArbitr.text;
                property alias competitionDateTextAlias: competitionDate.text;
                property alias competitionRoundTextAlias: competitionRound.text;
                property alias competitionGroupNameTextAlias: competitionGroupName.text;

                NativeText {
                    //% "Competition name"
                    text: qsTrId("competition-configuration-competition-name")
                }

                TextField {
                    id: competitionName
                    //text: competitionName_default
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    placeholderText: qsTrId("competition-configuration-competition-name")
                    readOnly: online
                }

                NativeText {
                    //% "Competition group name"
                    text: qsTrId("competition-configuration-competition-group-name")
                }

                TextField {
                    id: competitionGroupName
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    placeholderText: qsTrId("competition-configuration-competition-group-name")
                    readOnly: online
                }

                NativeText {
                    //% "Competition round"
                    text: qsTrId("competition-configuration-competition-round")
                }

                TextField {
                    id: competitionRound
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    placeholderText: qsTrId("competition-configuration-competition-round")
                    readOnly: online
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
                    enabled: !online;
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
                    placeholderText: qsTrId("competition-configuration-competition-director")
                    readOnly: online
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
                    placeholderText: qsTrId("competition-configuration-competition-arbitr")
                    readOnly: online
                }

                NativeText {
                    //% "Competition date"
                    text: qsTrId("competition-configuration-competition-date")
                }

                RowLayout {

                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2

                    TextField {
                        id: competitionDate
                        //text: competitionDate_default
                        Layout.fillWidth:true;
                        placeholderText: Qt.formatDateTime(new Date(), pathConfiguration.requestedDateFormat);
                        readOnly: online

                        onTextChanged: {
                            var utcOffset = cppWorker.getOffsetFromUtcSec(text, pathConfiguration.requestedDateFormat);
                            utcOffsetText.text = "UTC" + (utcOffset < 0 ? " - " : " + ") + utcOffset/3600;
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked:  {

                                if (!competitionDate.readOnly) {
                                    celandar.visible = true;
                                }
                            }
                        }
                    }

                    NativeText {
                        id: utcOffsetText
                    }
                }
            }
        }

        Tab {
            id: loginTab
            //% "Login"
            title: qsTrId("path-configuration-login-tab-title")

            // save api key
            onVisibleChanged: {
                config.set("api_base_url", tabView.loginTabAlias.apiBaseUrlAlias)
                config.set("api_key", tabView.loginTabAlias.apiKeyAlias);
                config.set("userNameValidity", tabView.loginTabAlias.userNameValidityAlias);
                config.set("userKeyValidity", tabView.loginTabAlias.userKeyValidityAlias);
            }

            GridLayout {

                id: gridLayoutLoginTab
                anchors.fill: parent
                anchors.margins: 10
                columnSpacing: 10;
                columns: 3

                property alias apiBaseUrlAlias: api_base_url_textinput.text;
                property alias apiKeyAlias: api_key.text;
                property alias userNameValidityAlias: userNameValidity.text;
                property alias userKeyValidityAlias: userKeyValidity.text;


                NativeText {
                    //% "Server"
                    text: qsTrId("api-server")
                }

                TextField {
                    id: api_base_url_textinput
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    onTextChanged: {
                        pathConfiguration.base_url = text;
                    }
                }

                NativeText { // spacer
                }


                Row {
                    height: api_key.height
                    spacing: 10

                    NativeText {
                        //% "API Key"
                        text: qsTrId("path-configuration-login-api-key")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Image {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        //visible: apiKeyStatus !== "unknown"
                        source: apiKeyStatus === "ok" ? "qrc:///images/ic_check_circle_black_48dp_1x.png"
                                                      : ((apiKeyStatus === "nok") ? "qrc:///images/ic_error_red_48dp_1x.png"
                                                                                  : "qrc:///images/ic_help_black_48dp_1x.png")

                    }
                }

                TextField {
                    id: api_key
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    text: config.get("api_key", "");

                    onTextChanged: {

                        apiKeyStatus = "unknown";
                        userNameValidity.text = "";
                        userKeyValidity.text = "";
                    }

                }
                Button {
                    text:
                        (api_key.text !== "") ?
                            //% "Validate API Key"
                            qsTrId("path-configuration-login-validate")
                          :
                            //% "Get API Key"
                            qsTrId("path-configuration-login-open-web")
                    ;
                    onClicked: {
                        if (api_key.text !== "") {
                            validApiKey(pathConfiguration.base_url + "/apiKeyCheck.php", "GET", apiKeyAlias);
                        } else {
                            Qt.openUrlExternally(api_key_get_url)
                        }

                    }
                }

                NativeText {
                    //% "Name"
                    text: qsTrId("api-key-name")
                }

                MyReadOnlyTextField {
                    id: userNameValidity
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                }

                NativeText { // spacer
                }

                NativeText {
                    //% "Validity"
                    text: qsTrId("api-key-validity")
                }

                MyReadOnlyTextField {
                    id: userKeyValidity
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                }

                NativeText { // spacer
                }



                function validApiKey(url, method, api_key) {

                    var http = new XMLHttpRequest();

                    http.open(method, url + "?api_key=" + api_key, true);
                    console.log("url = " + url + " method = " + method + " api_key = " + api_key)

                    // set timeout
                    var timer = Qt.createQmlObject("import QtQuick 2.9; Timer {interval: 5000; repeat: false; running: true;}", pathConfiguration, "MyTimer");
                    timer.triggered.connect(function(){
                        console.log("validApiKey http.abort()")
                        http.abort();
                    });

                    http.onreadystatechange = function() {

                        timer.running = false;

                        console.log("validApiKey: readyState " + http.readyState + " status: "+ http.status + " " +http.statusText)

                        if (http.readyState === XMLHttpRequest.DONE) {

                            console.log("validApiKey request DONE: " + http.status + " " +http.statusText + "  " + url + " " + http.responseText)

                            if (http.status === 200) {

                                try{

                                    var result = JSON.parse(http.responseText);
                                    var resultStatus = (result.status !== undefined && result.status === 0);
                                    apiKeyStatus = resultStatus  ? "ok" : "nok";

                                    if (resultStatus) {
                                        userNameValidity.text = result.message.firstname + " " + result.message.surname;
                                        userKeyValidity.text  = String(result.message.valid_until).replace(/\./g, "-");
                                    } else {
                                        userNameValidity.text = "";
                                        userKeyValidity.text = "";
                                    }


                                } catch (e) {
                                    userNameValidity.text = "ERR: parse failed" + e
                                    console.error("validApiKey: parse failed" + e)
                                }
                            }
                            // Connection error
                            else {

                                console.error("validApiKey http status: " + http.status + " " +http.statusText)

                                userNameValidity.text = "";
                                userKeyValidity.text = "";

                                // Set and show error dialog
                                //% "Connection error dialog title"
                                errMessageDialog.title = qsTrId("valid-apikey-connection-error-dialog-title")
                                //% "Can not validate Api key on the server. Please check the network connection and try it again. %1"
                                errMessageDialog.text = qsTrId("valid-apikey-connection-error-dialog-text").arg(http.status + " " + http.statusText)
                                errMessageDialog.standardButtons = StandardButton.Close
                                errMessageDialog.showDialog();
                            }
                        }
                    }

                    http.send()
                }

            }
        }
    }

    /// Action Buttons

    RowLayout {
        id: actionButtons;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        anchors.margins: 10;

        Row {

            Layout.fillWidth: true
            spacing: 10;

            Image {
                source: "qrc://images/emblem_readonly.png"
                //http://findicons.com/icon/115472/emblem_readonly?id=115472#
                visible: pathConfiguration.online && tabView.competitionTabAlias.visible
                mipmap: true
            }

            NativeText {
                //% "Note: Online state - read-only"
                text: qsTrId("competition-configuration-read-only-note")
                font.italic: true
                color: "grey"
                anchors.verticalCenter: parent.verticalCenter
                visible: pathConfiguration.online && tabView.competitionTabAlias.visible
            }
        }

        Row {
            spacing: 10;

            Button {
                id: okButton;
                //% "Ok"
                text: qsTrId("path-configuration-ok-button")
                focus: true;
                isDefault: true;
                onClicked: {

                    // get current values from competition property tab
                    var competitionTabValues = getCompetitionTabContent();
                    currentSettingsMD5 = String(MD5.md5(JSON.stringify(competitionTabValues)));

                    // split string into array od arbiters
                    var arr = [];
                    var re = /\s*[,;]\s*/;
                    arr = competitionTabValues[4].split(re);

                    // push empty string for default avatar
                    var arrAvatar = [];
                    for (var i = 0; i < arr.length; i++) { arrAvatar.push(""); }

                    // save current values
                    pathConfiguration.competitionName = competitionTabValues[0];
                    pathConfiguration.competitionType = competitionTabValues[1];
                    pathConfiguration.competitionTypeText = competitionTabValues[2];
                    pathConfiguration.competitionDirector = competitionTabValues[3];
                    pathConfiguration.competitionDirectorAvatar = online ? competitionDirectorAvatar : "";    // online - field already set/offline clear item
                    pathConfiguration.competitionArbitr = arr;
                    pathConfiguration.competitionArbitrAvatar = online ? competitionArbitrAvatar : arrAvatar; // online - field already set/offline set array of empty strings
                    pathConfiguration.competitionDate = competitionTabValues[5];

                    // get current values from enviroment tab
                    var enviromentTabValues = getEnviromentTabContent();

                    pathConfiguration.selectedCompetition = enviromentTabValues[0];
                    pathConfiguration.onlineOfflineCheckBox = enviromentTabValues[4] ? 1 : 0;
                    pathConfiguration.trackCheckBox = enviromentTabValues[1] ? 1 : 0;
                    pathConfiguration.igcFolderCheckBox = enviromentTabValues[2] ? 1 : 0;
                    pathConfiguration.resultsFolderCheckBox = enviromentTabValues[3] ? 1 : 0;

                    // save path values to DB - for default save empty string
                    config.set("v2_igcDirectory_user_defined", pathConfiguration.igcFolderCheckBox === 0 ? "" : enviromentTabValues[6]);
                    config.set("v2_trackFile_user_defined", pathConfiguration.trackCheckBox === 0 ? "" : enviromentTabValues[5]);
                    config.set("v2_resultsFolder_user_defined", pathConfiguration.resultsFolderCheckBox === 0 ? "" : enviromentTabValues[7]);
                    config.set("v2_onlineOffline_user_defined", pathConfiguration.onlineOfflineCheckBox === 0 ? "" : enviromentTabValues[0]);
                    config.set("v2_selectedCompetitionId", selectCompetitionOnlineDialog.selectedCompetitionId);

                    // save competition values to DB
                    config.set("v2_competitionName", competitionTabValues[0]);
                    config.set("v2_competitionType", competitionTabValues[1]);
                    config.set("v2_competitionDirector", competitionTabValues[3]);
                    config.set("v2_competitionDirectorAvatar", pathConfiguration.online ? JSON.stringify(competitionDirectorAvatar) : JSON.stringify(""));
                    config.set("v2_competitionArbitr", JSON.stringify(arr));
                    config.set("v2_competitionArbitrAvatar", pathConfiguration.online ? JSON.stringify(competitionArbitrAvatar) : JSON.stringify(arrAvatar));
                    config.set("v2_competitionDate", competitionTabValues[5] === "" ? Qt.formatDateTime(new Date(), pathConfiguration.requestedDateFormat) : competitionTabValues[5]);
                    config.set("v2_competitionRound", competitionTabValues[6]);
                    config.set("v2_competitionGroupName", competitionTabValues[7]);

                    var loginTabValues = getLoginTabValues()

                    config.set("api_server", loginTabValues[0]);
                    config.set("api_key", loginTabValues[1]);
                    config.set("userNameValidity", loginTabValues[2]);
                    config.set("userKeyValidity", loginTabValues[3]);

                    config.set("selfIntersectionDetection", pathConfiguration.enableSelfIntersectionDetector);
                    ok();
                    pathConfiguration.close();
                }
            }
            Button {
                //% "Cancel"
                text: qsTrId("path-configuration-ok-cancel")

                onClicked: {

                    config.set("api_base_url", prev_api_base_url);
                    config.set("api_key", prevApi_key); // restore
                    config.set("userNameValidity", prevUserNameValidity);
                    config.set("userKeyValidity", prevUserKeyValidity);

                    cancel();
                    pathConfiguration.close()
                }
            }
        }
    }

    FileDialog {
        id: igcFolderDialog
        selectFolder: true;
        selectMultiple: false
        //% "IGC Folder"
        title: qsTrId("path-configuration-dialog-title-igc-folder")
        folder:  Qt.resolvedUrl("../../../../..");

        onAccepted: {

            pathConfiguration.igcDirectory_user_defined = fileUrl;
        }

        onRejected: {

            // set to default - nothing selected
            if (pathConfiguration.igcDirectory_user_defined === "") {
                tabView.pathTabAlias.igcFolderDefaultCheckBoxAlias = true;
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
        folder:  Qt.resolvedUrl("../../../../..");

        onAccepted: {

            pathConfiguration.trackFile_user_defined = fileUrl;
        }

        onRejected: {

            // set to default - nothing selected
            if (pathConfiguration.trackFile_user_defined === "") {
                tabView.pathTabAlias.trackDefaultCheckBoxAlias = true;
            }
        }
    }

    FileDialog {
        id: resultsDirectoryDialog
        selectFolder: true;
        selectMultiple: false;
        //% "Flight results"
        title: qsTrId("path-configuration-dialog-title-filight-results")

        folder:  Qt.resolvedUrl("../../../..");

        onAccepted: {

            pathConfiguration.resultsFolder_user_defined = fileUrl;
        }

        onRejected: {

            // set to default - nothing selected
            if (pathConfiguration.resultsFolder_user_defined === "") {
                tabView.pathTabAlias.resultsFolderDefaultCheckBoxAlias = true;
            }
        }
    }


    MessageDialog {

        id: errMessageDialog
        icon: StandardIcon.Critical;
        standardButtons: StandardButton.Cancel

        signal showDialog();

        onShowDialog: {

            if(pathConfiguration.visible) {
                open();
            }
        }

        onButtonClicked: {

            visible = false;
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
        //% "Competition date"
        title: qsTrId("calendar-title-competiton-data")

        onAccepted: {

            pathConfiguration.setCompetitionTabDate(date);
        }
    }
}
