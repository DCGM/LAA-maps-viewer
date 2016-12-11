import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

ApplicationWindow {

    id: pathConfiguration
    width: 700;
    height: 500;
    minimumHeight: 500
    minimumWidth: 700
    modality: "WindowModal"
    //% "Configuration"
    title: qsTrId("path-configuration-dialog-title")
    color: "#ffffff"

    property bool autoConfirmFlag: false;

    property string igcDirectory_default: Qt.resolvedUrl("../../../igcFiles");
    property string igcDirectory_user_defined;

    property string trackFile_default: Qt.resolvedUrl("../../../track.json");
    property string trackFile_user_defined;

    property string resultsFolder_default: Qt.resolvedUrl("../../../results");
    property string resultsFolder_user_defined;

    property string contestantsFile: pathConfiguration.resultsFolder + "/" + contestantsFileName
    property string csvFile: pathConfiguration.resultsFolder + "/tucek.csv"
    property string tsFile: pathConfiguration.resultsFolder + "/tucek-settings.csv"
    property string assignFile: pathConfiguration.resultsFolder + "/assign.csv"
    property string csvResultsFile: pathConfiguration.resultsFolder + "/results.csv"

    property string contestantsFileName: "posadky.csv"

    property string igcDirectory;
    property string trackFile;
    property string resultsFolder;

    signal ok();
    signal cancel();

    property string contestantsDownloadedString: "";

    property bool online;   // changed when checkbox changed

    property string competitionName: "";
    property string competitionType: "0";
    property string competitionTypeText: getCompetitionTypeString(parseInt(pathConfiguration.competitionType));
    property string competitionDirector: "";
    property string competitionDirectorAvatar: "";
    property variant competitionArbitr: [""];
    property variant competitionArbitrAvatar: [""];
    property string competitionDate: "";

    property string api_key_get_url: F.base_url + "/apiKeys.php?action=create"

    property string prevApi_key: ""
    property string apiKeyStatus: "unknown" // ["unknown", "ok", "nok"]

    property bool contestantFileExist: false

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
    property string competitionDate_default: ""//Qt.formatDateTime(new Date(), "dd.MM.yyyy");

    property string selectedCompetition: "";

    property int onlineOfflineCheckBox: 0;
    property int trackCheckBox: 0;
    property int igcFolderCheckBox: 0;
    property int resultsFolderCheckBox: 0;

    onVisibleChanged: {

        // set current competition property
        if (visible) {

            // get last known api_key
            prevApi_key = config.get("api_key", "");

            // set previous enviroment tab values
            setFilesTabContent(pathConfiguration.selectedCompetition,
                               pathConfiguration.trackCheckBox,
                               pathConfiguration.igcFolderCheckBox,
                               pathConfiguration.resultsFolderCheckBox,
                               pathConfiguration.onlineOfflineCheckBox);

            // competition property
            setCompetitionTabContent(pathConfiguration.competitionName,
                                     pathConfiguration.competitionType,
                                     pathConfiguration.competitionDirector,
                                     pathConfiguration.competitionArbitr.join(", "),
                                     pathConfiguration.competitionDate);

            // folder status
            contestantFileExist = file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.contestantsFile));
        }
        else {
            autoConfirmFlag = false;
        }
    }

    // confirm and close automatically dialog - used when prev enviroment settings is loaded from DB
    onAfterSynchronizing: {

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

        ret.push(tabView.loginTabAlias.apiKeyAlias)

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setLoginTabValues(_api_key) {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "path");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("path");

        // competition property
        tabView.loginTabAlias.apiKeyAlias = _api_key;

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

    function setFilesTabContent(selectedCompetition, trackCheckBox, igcFolderCheckBox, resultsFolderCheckBox, onlineOfflineCheckBox) {

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

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        return ret;
    }

    function setCompetitionTabContent(competitionName, competitionType, competitionDirector, competitionArbitr, competitionDate) {

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
        tabView.competitionTabAlias.competitionDateTextAlias = competitionDate;

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
                                 competitionDate_default);

        competitionDirectorAvatar = competitionDirectorAvatar_default;
        competitionArbitrAvatar = competitionArbitrAvatar_default;

        contestantsDownloadedString = "";
    }


    TabView {
        id: tabView
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

                onOnlineOfflineDefaultCheckBoxAliasChanged: {

                    // remove downloaded data
                    if(onOnlineOfflineDefaultCheckBoxAliasChanged) {

                        initCompetitionPropertyOffline();
                        downloadedCompetitionNameAlias = "";
                    }

                    pathConfiguration.online = onlineOfflineUserDefinedCheckBoxAlias;
                }

                ///// Track
                ExclusiveGroup { id: trackGroup }

                NativeText {
                    //% "Track"
                    text: qsTrId("path-configuration-track")
                }

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
                        anchors.verticalCenter: parent.verticalCenter

                        onTextChanged: {
                            pathConfiguration.trackFile = text;
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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Spacer {}

                    RadioButton {
                        id: igc_user_defined
                        //% "User defined"
                        text: qsTrId("path-configuration-igc-folder-user-defined")
                        exclusiveGroup: igcGroup
                        anchors.verticalCenter: parent.verticalCenter

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
                        anchors.verticalCenter: parent.verticalCenter

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
                            anchors.verticalCenter: parent.verticalCenter
                            //% "Default"
                            text: qsTrId("path-configuration-flight-results-default")
                            checked: true
                        }
                    }

                    Item {
                        width: 25
                        height: 25
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: "./data/warningIcon.png"
                            opacity: 0.7
                            visible: (!contestantFileExist && contestantsDownloadedString === "")
                            // thanks to: http://wefunction.com/contact/
                            // https://www.iconfinder.com/icons/10375/alert_caution_exclamation_exclamation_mark_sign_triangle_warning_icon#size=48
                        }
                    }

                    NativeText {
                        //% "File %1 not found."
                        visible: (!contestantFileExist && contestantsDownloadedString === "")
                        text: qsTrId("path-configuration-warning-contestantsFile-not-found").arg(pathConfiguration.contestantsFileName);
                    }
                }

                RowLayout {
                    id: resultsFolderRow
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
                        anchors.verticalCenter: parent.verticalCenter

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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    Spacer {}

                    Item {

                        width: resultsFolder_user_defined.width
                        height: resultsFolderRow.height

                        RadioButton {
                            id: status_online
                            //% "Online"
                            text: qsTrId("path-configuration-competition-online")
                            exclusiveGroup: statusGroup
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {

                                if (checked && pathConfiguration.getEnviromentTabCompName() === "") {

                                    selectCompetitionOnlineDialog.show();
                                }
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
                        //% "Browse ..."
                        text: qsTrId("path-configuration-competition-connect");
                        enabled: status_online.checked
                        onClicked: {

                            selectCompetitionOnlineDialog.show();
                        }
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

                TextField {
                    id: competitionDate
                    //text: competitionDate_default
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    placeholderText: Qt.formatDateTime(new Date(), "dd.MM.yyyy");
                    readOnly: online

                    MouseArea {
                        anchors.fill: parent

                        onClicked:  {

                            if (!competitionDate.readOnly) {
                                celandar.visible = true;
                            }
                        }
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

                config.set("api_key", tabView.loginTabAlias.apiKeyAlias);
            }

            GridLayout {

                id: gridLayoutLoginTab
                anchors.fill: parent
                anchors.margins: 10
                columnSpacing: 10;
                columns: 3

                property alias apiKeyAlias: api_key.text;

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
                        visible: apiKeyStatus !== "unknown"
                        source: apiKeyStatus === "ok" ? "./data/ok.png" : "./data/nok.png"
                    }
                }

                TextField {
                    id: api_key
                    Layout.fillWidth:true;
                    Layout.preferredWidth: parent.width/2
                    text: config.get("api_key", "");
                }
                Button {
                    //% "Get API Key"
                    text: qsTrId("path-configuration-login-open-web");
                    onClicked: {
                        Qt.openUrlExternally(api_key_get_url)
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

                Button {
                    id: validButton
                    //% "Validate API Key"
                    text: qsTrId("path-configuration-login-validate");
                    enabled: (api_key.text !== "")
                    onClicked: {
                        validApiKey(F.base_url + "/apiKeyCheck.php", "GET", apiKeyAlias);
                    }
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
                    width: validButton.width
                }
            }
        }
    }

    /// Action Buttons

    RowLayout {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 10
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Row {

            Layout.fillWidth: true
            spacing: 10;

            Image {
                source: "./data/emblem_readonly.png"
                //http://findicons.com/icon/115472/emblem_readonly?id=115472#
                visible: online && tabView.competitionTabAlias.visible
            }

            NativeText {
                //% "Note: Online state - read-only"
                text: qsTrId("competition-configuration-read-only-note")
                font.italic: true
                color: "grey"
                anchors.verticalCenter: parent.verticalCenter
                visible: online && tabView.competitionTabAlias.visible
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
                    config.set("v2_competitionDate", competitionTabValues[5]);

                    var loginTabValues = getLoginTabValues()

                    config.set("api_key", loginTabValues[0]);

                    ok();
                    pathConfiguration.close();
                }
            }
            Button {
                //% "Cancel"
                text: qsTrId("path-configuration-ok-cancel")

                onClicked: {

                    config.set("api_key", prevApi_key); // restore api_key

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
        folder:  Qt.resolvedUrl("../../..");

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
        folder:  Qt.resolvedUrl("../../..");

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

        folder:  Qt.resolvedUrl("../../..");

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


    function validApiKey(url, method, api_key) {

        var http = new XMLHttpRequest();

        http.open(method, url + "?api_key=" + api_key, true);

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 5000; repeat: false; running: true;}", pathConfiguration, "MyTimer");
                        timer.triggered.connect(function(){

                            http.abort();
                        });

        http.onreadystatechange = function() {

            timer.running = false;

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("validApiKey request DONE: " + http.status)

                if (http.status === 200) {

                    try{

                        // todo parse response SET method for the tab
                        //apiKeyStatus = "ok"; //["unknown", "ok", "nok"]
                        //userNameValidity.text = "TODO";
                        //userKeyValidity.text = "FROM - TO";

                        /*
                        var result = (http.responseText);

                        var resultObject = JSON.parse(result);

                        for (var i = 0; i < resultObject.length; i++) {

                            model.append(resultObject[i])
                        }
                        */

                    } catch (e) {

                        console.log("ERR validApiKey: parse failed" + e)
                    }
                }
                // Connection error
                else {

                    console.log("ERR validApiKey http status: " + http.status)

                    // TODO
                    /*
                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("competitions-download-connection-error-dialog-title")
                    //% "Can not download competitions list from server. Please check the network connection and try it again."
                    errMessageDialog.text = qsTrId("competitions-download-connection-error-dialog-text")
                    errMessageDialog.standardButtons = StandardButton.Close
                    errMessageDialog.showDialog();
                    */
                }
            }
        }

        http.send()
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
