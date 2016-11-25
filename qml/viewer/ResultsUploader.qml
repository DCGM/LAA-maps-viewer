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


    WorkerScript {
        id: myResultsWorker
        source: "workerscript.js"

        // file uploaded
        onMessage: {

            // get respons - 0 OK, <0 Err
            var respo = messageObject.status;

            // add current file into list od processed files
            uploaderDialog.filesListModelAlias.append({"fileName" : filesToUpload[filesToUploadIterator].fileName, "uploadState" : respo});

            // upload next file
            filesToUploadIterator++;
            uploaderDialog.processedFiles = filesToUploadIterator;

            if (filesToUploadIterator < filesToUpload.length && uploaderDialog.visible) {

                var fileData = file_reader.read(filesToUpload[filesToUploadIterator].fileUrl);

                sendMessage( { fileName: filesToUpload[filesToUploadIterator].fileName, fileData: fileData, compId: destinationCompetitionId } );
            }
        }
    }

    UploaderDialog {

        id: uploaderDialog
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
            file_reader.copy(Qt.resolvedUrl(pathConfiguration.trackFile), Qt.resolvedUrl(trackFileUrlArray.join("/")));
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
        var filesToUpload = getFilesToUploadList();

        destinationCompetitionId = id;

        if(filesToUpload.length > 0) {

            uploaderDialog.filesCount = filesToUpload.length;
            uploaderDialog.processedFiles = 0;
            uploaderDialog.filesListModelAlias.clear();

            uploaderDialog.show();

            var fileData = file_reader.read(filesToUpload[0].fileUrl);

            // start uploading in another thread
            myResultsWorker.sendMessage( { fileName: filesToUpload[0].fileName, fileData: fileData, compId: id } );
        }
    }
}
