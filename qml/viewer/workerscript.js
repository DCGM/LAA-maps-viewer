

function sendFile(fileName, fileData, compId) {

    var status = 0;

    var http = new XMLHttpRequest();

    http.open("POST", "https://pcmlich.fit.vutbr.cz/ppt/competitionFilesAjax.php", true);

    http.onreadystatechange = function() {

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
    body += 'fafcbb794117cda5bf5d4e4a636ee84a'
    body += '\r\n'
    body += '--' + boundary + '--'
    body += '\r\n'

    http.setRequestHeader('Content-length', body.length);

    http.send(body)
    return status;
}

WorkerScript.onMessage = function(message) {

    var retVal = sendFile(message.fileName, message.fileData, message.compId);

    console.log("WorkerScript.onMessage retVal = " + retVal);

    //Send result back to main thread
    WorkerScript.sendMessage( { 'status': retVal } );
}
