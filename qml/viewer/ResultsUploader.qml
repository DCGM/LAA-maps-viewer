import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

Item {

    id: resultsUploader
    property string trackFileName: "track.json";
    property var csvFilesToExport: ["results.csv", "tucek.csv", "tucek-settings.csv", "posadky.csv"];

    property variant filesToUpload: [];
    property int filesToUploadIterator: 0;

    property int destinationCompetitionId;

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
            sendFile(F.base_url + "/competitionFilesAjax.php", filesToUpload[0].fileName, String(fileData), id, api_key_value);
        }
    }

    function initCompetitionFileStorage(url, compId, api_key) {

        var http = new XMLHttpRequest();

        http.open("POST", url + "?id=" + compId + "&api_key=" + api_key, true);

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 5000; repeat: false; running: true;}", resultsUploader, "MyTimer");
                        timer.triggered.connect(function(){

                            http.abort();
                        });

        http.onreadystatechange = function() {

            timer.running = false;

            if (http.readyState === XMLHttpRequest.DONE) {

                if (http.status === 200) {

                    try{

                        // ok - init upload of files
                        if (http.responseText.indexOf("\"status\": 0") != -1) {

                            uploadResultsFiles(compId);
                        }

                        // competition read only
                        else if (http.responseText.indexOf("\"status\": 5") != -1)  {

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

        // set timeout
        var timer = Qt.createQmlObject("import QtQuick 2.5; Timer {interval: 15000; repeat: false; running: true;}", resultsUploader, "MyTimer");
                        timer.triggered.connect(function(){
                            console.log("callUploadFinish: http.abort() called")
                            http.abort();
                        });

        http.onreadystatechange = function() {

            if (http.readyState === XMLHttpRequest.DONE) {

                timer.running = false;

                if (http.status === 200) {


                    try{

                        // ok - init upload of files
                        if (http.responseText.indexOf("\"status\": 0") != -1) {

                        }
                        // err
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

    function sendFile(url, fileName, fileData, compId, api_key) {

        var status = 0;

        var http = new XMLHttpRequest();

        http.open("POST", url, true);

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
                            //console.log( "response.status = " + status )
                        }  else {
                            status = -1;
                        }

                    } catch (e) {
                        status = -2;
                    }
                }
                // Connection error
                else {
                    status = -3;
                }

                // add current file into list od processed files
                uploaderDialog.filesListModelAlias.append({"fileName" : filesToUpload[filesToUploadIterator].fileName, "uploadState" : status});

                // upload next file
                filesToUploadIterator++;
                uploaderDialog.processedFiles = filesToUploadIterator;

                if (filesToUploadIterator < filesToUpload.length && uploaderDialog.visible && !errMessageDialog.visible) {

                    var api_key_value = config.get("api_key", "");
                    var fileData = file_reader.read(filesToUpload[filesToUploadIterator].fileUrl);

                    sendFile(url, filesToUpload[filesToUploadIterator].fileName, String(fileData), destinationCompetitionId, api_key_value);
                }
                else {

                    // init evaluation of the uploaded files on the server
                    callUploadFinish(F.base_url + "/competitionFilesFinish.php", compId, api_key);
                }
            }
        }

        var boundary = '---------------------------';
        boundary += Math.floor(Math.random()*32768);
        boundary += Math.floor(Math.random()*32768);
        boundary += Math.floor(Math.random()*32768);
        http.setRequestHeader("Content-Type", 'multipart/form-data; boundary=' + boundary);
        var body = '';
        body += '--' + boundary
        body += '\r\n'
        body += 'Content-Disposition: form-data; name="files"; filename="' + fileName + '"';
        body += '\r\n'
        body += 'Content-Type: text/csv'
        body += '\r\n\r\n'
        body += fileData
        body += '\r\n'

        body += '--' + boundary
        body += '\r\n'
        body += 'Content-Disposition: form-data; name="id"'
        body += '\r\n'
        body += '\r\n'
        body += compId
        body += '\r\n'

        body += '--' + boundary
        body += '\r\n'
        body += 'Content-Disposition: form-data; name="api_key"'
        body += '\r\n'
        body += '\r\n'
        body += api_key
        body += '\r\n'
        body += '--' + boundary + '--'
        body += '\r\n'

        http.setRequestHeader('Content-length', body.length);

        http.send(body)
        return status;
    }
}
