import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "functions.js" as F

Item {

    function uploadFile(baseUrl, id, method, data, fileName) {

        var http = new XMLHttpRequest();

        http.open(method, baseUrl + "?id=" + id + "&viewer=caf9b7d9f300d3dfcf746b1c0bb564d7", true);

        http.onreadystatechange = function() {

            if (http.readyState === XMLHttpRequest.DONE) {

                console.log("DONE: " + http.status)

                if (http.status === 200) {

                    try{
                        console.log(http.responseText)
                        console.log("1")

                    } catch (e) {
                        console.log("ERR: " + e)
                    }
                    console.log("2")
                }
                // Connection error
                else {
                    console.log("ERR: " + http.status)
                }
                console.log("3")
            }
            console.log("4")
        }
        console.log("5")

        var boundary = '---------------------------';
        boundary += Math.floor(Math.random()*32768);
        boundary += Math.floor(Math.random()*32768);
        boundary += Math.floor(Math.random()*32768);
        http.setRequestHeader("Content-Type", 'multipart/form-data; boundary=' + boundary);
        var body = '';
        body += 'Content-Disposition: form-data; name="files"; filename="' + fileName + '"';
        body += '\r\n'
        body += 'Content-Type: text/csv '
        body += '\r\n\r\n'
        body += data
        body += '\r\n'
        body += '--' + boundary + '--'
        body += '\r\n'
        console.log (body)
        http.setRequestHeader('Content-length', body.length);

        http.send()
    }
}
