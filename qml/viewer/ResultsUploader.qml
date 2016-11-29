import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

Item {

    property string trackFileName: "track.json";
    property var csvFilesToExport: ["results.csv", "tucek.csv", "tucek-settings.csv", "posadky.csv"];

    property variant filesToUpload: [];
    property int filesToUploadIterator: 0;

    property int destinationCompetitionId;

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

        return filesToUpload;
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
            sendFile(filesToUpload[0].fileName, String(fileData), id, api_key_value);

        }
    }

    function sendFile(fileName, fileData, compId, api_key) {

        var status = 0;

        var http = new XMLHttpRequest();

        //    http.open("POST", F.base_url + "/competitionFilesAjax.php", true);
        http.open("POST", "https://pcmlich.fit.vutbr.cz/ppt/competitionFilesAjax.php", true);

        http.onreadystatechange = function() {

            var status;

            if (http.readyState === XMLHttpRequest.DONE) {

                if (http.status === 200) {

                    try{

                        var response = JSON.parse(http.responseText);
                        if (response.status !== undefined) {
                            status = parseInt(response.status, 10);
                            console.log( "response.status = " + status )
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

                if (filesToUploadIterator < filesToUpload.length && uploaderDialog.visible) {

                    var api_key_value = config.get("api_key", "");
                    var fileData = file_reader.read(filesToUpload[filesToUploadIterator].fileUrl);

                    sendFile(filesToUpload[filesToUploadIterator].fileName, String(fileData), destinationCompetitionId, api_key_value);
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
