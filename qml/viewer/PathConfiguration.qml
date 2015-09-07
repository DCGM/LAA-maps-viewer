import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1

ApplicationWindow {
    id: pathConfiguration
    width: 600;
    height: 400;
    modality: "WindowModal"
    //% "Environment configuration"
    title: qsTrId("path-configuration-dialog-title")
    color: "#ffffff"

    property alias igcDirectory: igcDirectoryTextField.text
//    property string igcDirectory_default: "file:///home/jmlich/workspace/tucek/2015-kotvrdovice/vysledky/igcFiles"
    property string igcDirectory_default: "file:///home/imlich/workspace/tucek/testovaci_data/igcFiles"
    //    property string igcDirectory_default: "file:///"+ QStandardPathsApplicationFilePath + "/igcFiles"

    property alias trackFile: trackFileTextField.text
//    property string trackFile_default: "file:///home/jmlich/workspace/tucek/2015-kotvrdovice/2015-kotv2.json";
    property string trackFile_default: "file:///var/www/html/tucek2/2012-KOTV.json";
//    property string trackFile_default: "file:///var/www/html/tucek2/2014-LKHK-50bodu.json";
    //    property string trackFile_default: "file:///"+ QStandardPathsApplicationFilePath + "/track.json";

    property alias resultsFolder: resultsFolderTextField.text;
//    property string resultsFolder_default: "file:///home/jmlich/workspace/tucek/2015-kotvrdovice/vysledky/results"
    property string resultsFolder_default: "file:///home/imlich/workspace/tucek/testovaci_data/results"
    //    property string resultsFolder_default: "file:///"+ QStandardPathsApplicationFilePath +"/results";
    //    property string resultsFolder_default: "../../results"


    property string contestantsFile: resultsFolderTextField.text + "/posadky.csv"
    property string csvFile: resultsFolderTextField.text + "/tucek.csv"
    property string tsFile: resultsFolderTextField.text + "/tucek-settings.csv"
    property string assignFile: resultsFolderTextField.text + "/assign.csv"

    signal ok();
    signal cancel();

    FileDialog {
        id: igcFolderDialog
        selectFolder: true;
        selectMultiple: false
        //% "IGC Folder"
        title: qsTrId("path-configuration-dialog-title-igc-folder")
    }

    FileDialog {
        id: trackFileDialog
        selectFolder: false;
        selectMultiple: false
        //% "Track"
        title: qsTrId("path-configuration-dialog-title-")
        nameFilters: [ "Tucek json (*.json)", "All files (*)" ]

    }

    FileDialog {
        id: resultsDirectoryDialog
        selectFolder: true;
        selectMultiple: false;
        //% "Flight results"
        title: qsTrId("path-configuration-dialog-title-filight-results")
    }


    Column {
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: actionButtons.top;
        anchors.margins: 10
        spacing: 10;


        ///// Track json file
        ExclusiveGroup { id: trackGroup }


        NativeText {
            //% "Track"
            text: qsTrId("path-configuration-track")
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                exclusiveGroup: trackGroup
                //% "Default"
                text: qsTrId("path-configuration-track-default")
                checked: true
            }
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: track_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-track-user-defined")
                exclusiveGroup: trackGroup
            }
            TextField {
                id: trackFileTextField
                text: track_user_defined.checked ? trackFileDialog.fileUrl : trackFile_default
                readOnly: !track_user_defined.checked
                width: 250;
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-track-browse");
                enabled: track_user_defined.checked
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

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                exclusiveGroup: igcGroup
                //% "Default"
                text: qsTrId("path-configuration-igc-folder-default")
                checked: true
            }
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: igc_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-igc-folder-user-defined")
                exclusiveGroup: igcGroup
            }
            TextField {
                id: igcDirectoryTextField
                text: igc_user_defined.checked ? igcFolderDialog.fileUrl : igcDirectory_default
                readOnly: !igc_user_defined.checked
                width: 250;
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-igc-folder-browse-button");
                enabled: igc_user_defined.checked
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

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                exclusiveGroup: resultsFolderGroup
                //% "Default"
                text: qsTrId("path-configuration-flight-results-default")
                checked: true
            }
        }

        Row {
            spacing: 10;
            Spacer {}

            RadioButton {
                id: resultsFolder_user_defined
                //% "User defined"
                text: qsTrId("path-configuration-flight-results-user-defined")
                exclusiveGroup: resultsFolderGroup
            }
            TextField {
                id: resultsFolderTextField
                text: resultsFolder_user_defined.checked ? resultsDirectoryDialog.fileUrl : resultsFolder_default
                readOnly: !resultsFolder_user_defined.checked
                width: 250;
            }
            Button {
                //% "Browse ..."
                text: qsTrId("path-configuration-flight-results-browse");
                enabled: resultsFolder_user_defined.checked
                onClicked: {
                    resultsDirectoryDialog.open();
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
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("path-configuration-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {
                ok();
                pathConfiguration.close()
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
