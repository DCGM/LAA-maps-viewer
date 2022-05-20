import QtGraphicalEffects 1.0

DropShadow {
    anchors.fill: zoomButtons
    cached: true
    horizontalOffset: 3
    verticalOffset: 3
    radius: 8
    samples: 16
    color: "#80000000"
    smooth: true
    source: zoomButtons
}
