import QtQuick 2.0
import QtCharts 2.0

PieSlice {

    property int mVal: 0
    property string mLabelShortcut: ""
    property string  mLabelDetail: ""
    property bool mAbs: false
    property real armLengthFactor: 0.4

    value: mAbs ? Math.abs(mVal) : mVal;
    labelArmLengthFactor: (value !== 0 && value !== -1 ) ? armLengthFactor : 0 ;

    onHovered: {
        exploded = !exploded;
        label = (value !== 0 && value !== -1 ) ? (exploded && mLabelDetail !== "" ? (mLabelDetail) : ((mLabelShortcut + ": " + String(value)))) : "";
    }

    onValueChanged: {
        label = (value !== 0 && value !== -1 ) ? (exploded && mLabelDetail !== "" ? (mLabelDetail) : ((mLabelShortcut + ": " + String(value)))) : "";
    }
}

