import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

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

                anchors.left: parent.left
                anchors.right: parent.right

                NativeText {

                    anchors.left: parent.left
                    anchors.leftMargin: 2

                                                            //% "Uploading file"
                    text: (processedFiles !== filesCount) ? qsTrId("uploader-window-dialog-text")
                                                            //% "Done"
                                                          : qsTrId("done")
                }
                NativeText {

                    anchors.right: parent.right
                    anchors.rightMargin: 5

                    text: (processedFiles + "/" + filesCount)
                }
            }

            ProgressBar {

                id: progressBar
                minimumValue: 0
                maximumValue: 100
                value: 0
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Rectangle {

                height: 10
                anchors.left: parent.left
                anchors.right: parent.right
            }

            ScrollView {

                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillHeight: true

                ListView {

                    model: filesListModel

                    delegate: Rectangle {

                        width: parent.width
                        height: 20

                        RowLayout {
                            anchors.fill: parent

                            NativeText {
                                text: fileName;
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                            }

                            Item {
                                height: parent.height
                                width: parent.height
                                anchors.right: parent.right
                                anchors.rightMargin: 5

                                Image {
                                    id: okImg

                                    anchors.fill: parent
                                    anchors.margins: 2
                                    fillMode: Image.PreserveAspectFit
                                    source: (parseInt(uploadState) === 0) ? "./data/ic_check_circle_black_48dp/ic_check_circle_black_48dp/web/ic_check_circle_black_48dp_1x.png"
                                                                          : "./data/ic_error_black_48dp/ic_error_black_48dp/web/ic_error_black_48dp_1x.png"
                                }
                            }
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

            onClicked: {

                close();
            }
        }
    }
}
