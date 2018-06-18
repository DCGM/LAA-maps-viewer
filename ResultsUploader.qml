import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import "functions.js" as F
import cz.mlich 1.0

Item {

    id: resultsUploader
    property string trackFileName: "track.json";
    property var csvFilesToExport: ["results.csv", "tucek.csv", "tucek-settings.csv", "posadky.csv"];

    property variant filesToUpload: [];
    property int filesToUploadIterator: 0;

    property int destinationCompetitionId;

    property string fileUploadURL: F.base_url + "/competitionFilesAjax.php"

    MessageDialog {

         id: errMessageDialog
         icon: StandardIcon.Critical;
         standardButtons: StandardButton.Cancel

         signal showDialog();

         onShowDialog: {

             if(uploaderDialog.visible)
                open();
         }

         onButtonClicked: {

            filesToUpload = [];
            visible = false;
            resultsUploader.visible = false;
         }
     }

    // create list of files to upload
    function getFilesToUploadList() {

        filesToUpload = [];
        filesToUploadIterator = 0;

        // track file
        var trackFileUrlArray = pathConfiguration.trackFile.split("/");

        // rename track file name to defined name: resultsUploaderComponent.trackFileName
        if(trackFileUrlArray[trackFileUrlArray.length - 1] !== resultsUploaderComponent.trackFileName) {

            trackFileUrlArray[trackFileUrlArray.length - 1] = resultsUploaderComponent.trackFileName;
            file_reader.copy_file(Qt.resolvedUrl(pathConfiguration.trackFile), Qt.resolvedUrl(trackFileUrlArray.join("/")));
        }
        filesToUpload.push({"fileUrl": trackFileUrlArray.join("/"), "fileName": resultsUploaderComponent.trackFileName});

        // csv files: csvFilesToExport
        for (var i = 0; i < csvFilesToExport.length; i++) {

            if (file_reader.file_exists(Qt.resolvedUrl(pathConfiguration.resultsFolder + "/" + csvFilesToExport[i]))) {
                filesToUpload.push({"fileUrl": pathConfiguration.resultsFolder + "/" + csvFilesToExport[i], "fileName": csvFilesToExport[i]});
            }
        }

        // igc files
        for (var i = 0; i < igcFolderModel.count; i++) {

            filesToUpload.push({"fileUrl": Qt.resolvedUrl(igcFolderModel.get(i, "fileURL")), "fileName": igcFolderModel.get(i, "fileName")});
        }

        // html files
        for (var i = 0; i < contestantsListModel.count; i++) {

            var contestant = contestantsListModel.get(i);
            var fileName = F.getContestantResultFileName(contestant.name, contestant.category);

            if (contestant.scorePoints != -1 && file_reader.file_exists(pathConfiguration.resultsFolder + "/"+ fileName + ".html")) {
                filesToUpload.push({"fileUrl": pathConfiguration.resultsFolder + "/" + fileName + ".html", "fileName": fileName + ".html"});
            }
        }

        return filesToUpload;
    }

    function uploadResults(id) {

        // remove all files and inti upload
        var api_key_value = config.get("api_key", "");

        initCompetitionFileStorage(F.base_url + "/competitionFilesInit.php", id, api_key_value)
    }

    // init uploading procedure
    function uploadResultsFiles(id) {

        // get list of files to upload
        filesToUpload = getFilesToUploadList();

        destinationCompetitionId = id;

        if(filesToUpload.length > 0) {

            uploaderDialog.filesCount = filesToUpload.length;
            uploaderDialog.processedFiles = 0;
            uploaderDialog.filesListModelAlias.clear();

            uploaderDialog.show();

            var fileData = file_reader.read(filesToUpload[0].fileUrl);
            var api_key_value = config.get("api_key", "");

            // start uploading in another thread           
            uploader.sendFile(fileUploadURL, file_reader.toLocal(filesToUpload[0].fileUrl), destinationCompetitionId, api_key_value);
        }
    }

    function initCompetitionFileStorage(url, compId, api_key) {

        var http = new XMLHttpRequest();

        http.open("POST", url + "?id=" + compId + "&api_key=" + api_key, true);
        console.log("http request: " + url + "?id=" + compId + "&api_key=" + api_key)

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 5000; repeat: false; running: true;}", resultsUploader, "MyTimer");
                        timer.triggered.connect(function(){

                            http.abort();
                        });

        http.onreadystatechange = function() {

            var status;

            timer.running = false;

            if (http.readyState === XMLHttpRequest.DONE) {

                if (http.status === 200) {

                    try{

                        var response = JSON.parse(http.responseText);
                        if (response.status !== undefined) {
                            status = parseInt(response.status, 10);

                            // ok - init upload of files
                            if (status === 0) {
                                uploadResultsFiles(compId);
                            }
                            // competition read only
                            else if (status === 5) {

                                // Set and show error dialog
                                //% "Results upload error dialog title"
                                errMessageDialog.title = qsTrId("results-upload-readonly-error-dialog-title")
                                //% "Selected competition is read only. Please check the settings and try it again."
                                errMessageDialog.text = qsTrId("results-upload-readonly-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Close
                                //errMessageDialog.showDialog();
                                errMessageDialog.open();
                            }
                            // err
                            else {

                                console.log("ERR initCompetitionFileStorage: " + http.responseText)

                                // Set and show error dialog
                                //% "Results upload error dialog title"
                                errMessageDialog.title = qsTrId("results-upload-start-error-dialog-title")
                                //% "Unable to start the upload of the files. Please check the api key, destination competition and try it again."
                                errMessageDialog.text = qsTrId("results-upload-start-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Close
                                //errMessageDialog.showDialog();
                                errMessageDialog.open();
                            }
                        }
                        // unknown err
                        else {

                            console.log("ERR initCompetitionFileStorage: " + http.responseText)

                            // Set and show error dialog
                            //% "Results upload error dialog title"
                            errMessageDialog.title = qsTrId("results-upload-start-error-dialog-title")
                            //% "Unable to start the upload of the files. Please check the api key, destination competition and try it again."
                            errMessageDialog.text = qsTrId("results-upload-start-error-dialog-text")
                            errMessageDialog.standardButtons = StandardButton.Close
                            //errMessageDialog.showDialog();
                            errMessageDialog.open();
                        }
                    } catch (e) {

                        console.log("ERR initCompetitionFileStorage: parse failed" + e)                        
                    }
                }
                // Connection error
                else {

                    console.log("ERR initCompetitionFileStorage http status: " + http.status)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("results-upload-connection-error-dialog-title")
                    //% "Unable to connect to the server. Please check the network connection and try it again."
                    errMessageDialog.text = qsTrId("results-upload-connection-error-dialog-text")
                    errMessageDialog.standardButtons = StandardButton.Close
                    //errMessageDialog.showDialog();
                    errMessageDialog.open();
                }
            }
        }

        http.send()
    }


    function callUploadFinish(url, compId, api_key) {

        var http = new XMLHttpRequest();

        http.open("GET", url + "?id=" + compId + "&api_key=" + api_key, true);

        console.log("callUploadFinish: " + url + "?id=" + compId + "&api_key=" + api_key)

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 15000; repeat: false; running: true;}", resultsUploader, "MyTimer");
                        timer.triggered.connect(function(){
                            console.log("callUploadFinish: http.abort() called")
                            http.abort();
                        });

        http.onreadystatechange = function() {

            var status;

            if (http.readyState === XMLHttpRequest.DONE) {

                timer.running = false;

                if (http.status === 200) {


                    try{

                        var response = JSON.parse(http.responseText);
                        if (response.status !== undefined) {
                            status = parseInt(response.status, 10);

                            // ok - init upload of files
                            if (status === 0) {

                            }
                            else {

                                console.log("ERR callUploadFinish: " + http.responseText)

                                // Set and show error dialog
                                //% "Results upload error dialog title"
                                errMessageDialog.title = qsTrId("results-upload-finishing-error-dialog-title")
                                //% "Unable to complete the results upload. Please check the api key, destination competition, uploaded files and try it again."
                                errMessageDialog.text = qsTrId("results-upload-finishing-error-dialog-text")
                                errMessageDialog.standardButtons = StandardButton.Close
                                errMessageDialog.showDialog();
                            }
                        }
                    } catch (e) {

                        console.log("ERR callUploadFinish: parse failed" + e)
                    }
                }
                // Connection error
                else {

                    console.log("ERR callUploadFinish http status: " + http.status)

                    // Set and show error dialog
                    //% "Connection error dialog title"
                    errMessageDialog.title = qsTrId("results-upload-connection-error-dialog-title")
                    //% "Unable to connect to the server. Please check the network connection and try it again."
                    errMessageDialog.text = qsTrId("results-upload-connection-error-dialog-text")
                    errMessageDialog.standardButtons = StandardButton.Close
                    errMessageDialog.showDialog();
                }
            }
        }

        http.send()
    }


    Uploader {
        id: uploader;

        onUploadFinished: {
            var status = uploader.errorCode

            console.log("Uploader ()" + status + ") response: " + uploader.response )

            try{
                var response = JSON.parse(uploader.response);
                if (response.status !== undefined) {
                    status = parseInt(response.status, 10);
                    //console.log( "response.status = " + status )
                }  else {
                    status = -1;
                }

            } catch (e) {
                status = -2;
            }



            // add current file into list od processed files
            uploaderDialog.filesListModelAlias.append({"fileName" : filesToUpload[filesToUploadIterator].fileName, "uploadState" : status});

            // upload next file
            filesToUploadIterator++;
            uploaderDialog.processedFiles = filesToUploadIterator;
            var api_key_value = config.get("api_key", "");

            if (filesToUploadIterator < filesToUpload.length && uploaderDialog.visible && !errMessageDialog.visible) {
                uploader.sendFile(fileUploadURL, file_reader.toLocal(filesToUpload[filesToUploadIterator].fileUrl), destinationCompetitionId, api_key_value);
            }
            else {

                // init evaluation of the uploaded files on the server
                callUploadFinish(F.base_url + "/competitionFilesFinish.php", destinationCompetitionId, api_key_value);
            }

        }
    }

}