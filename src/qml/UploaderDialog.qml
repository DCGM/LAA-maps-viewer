import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "./components"

ApplicationWindow {

    id: dialogWindow
    width: 500
    height: 400
    minimumWidth: 400
    minimumHeight: 200
    modality: Qt.ApplicationModal
    visible: false
    color: "#edeceb"

    //% "Uploader dialog title"
    title: qsTrId("uploader-window-dialog-title")

    property alias progressBarValue: progressBar.value

    property double processedFiles;
    property double filesCount;
    property bool finishRunning: false;

    property alias filesListModelAlias: filesListModel

    onProcessedFilesChanged: {

        progressBarValue = (processedFiles/filesCount) * 100;
    }

    onVisibleChanged: {

        if (visible) {

            progressBarValue = 0.0;
            processedFiles = 0;
        }
    }

    ListModel {

        id: filesListModel

        // sort by status - files with errr code move to the top
        onCountChanged: {

            for (var i = 0; i < count; i++) {

                var item = get(i);
                if(item.uploadState < 0){
                    move(i, 0, 1);
                }
            }
        }
    }

    Rectangle {

        id: contentRectangle
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: rowButtonLayout.top
        anchors.bottomMargin: 10

        ColumnLayout {

            anchors.fill: parent
            anchors.topMargin: 20
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 10

            RowLayout {
                Layout.fillWidth: true;


                NativeText {

                    Layout.alignment: Qt.AlignLeft
                    anchors.leftMargin: 2


                    text: (processedFiles !== filesCount) ?
                              //% "Uploading file %1"
                              qsTrId("uploader-window-dialog-text").arg(processedFiles + "/" + filesCount) :
                              (dialogWindow.finishRunning ?
                                   //% "Processing results ..."
                                   qsTrId("uploader-window-dialog-processing") :
                                   //% "Done"
                                   qsTrId("done")
                               )

                }
            }

            ProgressBar {

                id: progressBar
                minimumValue: 0
                maximumValue: 100
                value: 0
                Layout.fillWidth: true;
            }

            Rectangle {

                height: 10
                Layout.fillWidth: true;
            }

            ScrollView {

                Layout.fillWidth: true;
                Layout.fillHeight: true;

                ListView {

                    model: filesListModel

                    delegate: RowLayout {
                        Layout.fillWidth: true;
                        height: filenameText.paintedHeight;

                        NativeText {
                            id: filenameText
                            text: fileName;
                            Layout.alignment: Qt.AlignLeft;
                            Layout.fillWidth: true;
                            Layout.leftMargin: 5
                        }

                        Image {
                            id: okImg
                            Layout.maximumHeight: 15;
                            Layout.maximumWidth: 15;

                            Layout.alignment: Qt.AlignRight
                            Layout.margins: 2
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                            source: (parseInt(uploadState, 10) === 0) ? "qrc:///images/ic_check_circle_black_48dp_1x.png"
                                                                      : "qrc:///images/ic_error_red_48dp_1x.png"
                        }
                    }
                }

            }
        }
    }

    HorizontalDelimeter {

        width: parent.width
        anchors.top: contentRectangle.bottom
    }


    RowLayout {

        id: rowButtonLayout
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10

        Button {

            id: cancelButtonSettings
            //% "Close"
            text: qsTrId("uploader-dialog-close-button")
            enabled: !finishRunning;

            onClicked: {

                close();
            }
        }
    }
}
