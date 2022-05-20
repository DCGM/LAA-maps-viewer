import QtQuick 2.9
// import "uiconstants.js" as UI

Image {
    id: item
    property variant targetPoint
    property string waypointType: "Diamond_Blue";
    property real azimuth: 0
    property real mapx;
    property real mapy;
//    width: 46
//    height: 46
    x: mapx + targetPoint[0] - width/2
    y: mapy + targetPoint[1] - height/2
    source: "qrc:///images/"+waypointType+".png"

    transform: Rotation {
        origin.x: item.width/2
        origin.y: item.height - item.width/2
        angle: azimuth
    }
}


