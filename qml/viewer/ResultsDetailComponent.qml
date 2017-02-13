import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtCharts 2.0

import "functions.js" as F

Rectangle {

    id: resultsMainWindow

    property variant curentContestant;

    property string pilotName;
    property string copilotName;
    property string category;
    property string speed;
    property string startTime;

    property int totalPointsScore: -1;

    signal ok();
    signal okAndView();
    signal cancel();

    // recalculate percent points
    onTotalPointsScoreChanged: {

        // get tab status
        var previousActive = tabView.getActive();
        var tabPrevActived = (previousActive  === "manVals");

        // set tab active
        if (!tabPrevActived) tabView.activateTabByName("manVals");

        if (tabView.scrollView === null)
            return;

        curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, curentContestant.time_window_size, curentContestant.time_window_penalty, totalPointsScore);
        tabView.scrollView.startTimeScoreText = curentContestant.startTimeScore;

        curentContestant.circlingScore = getGyreScore(tabView.scrollView.circlingCountValue, curentContestant.gyre_penalty, totalPointsScore);
        tabView.scrollView.circlingScoreText = curentContestant.circlingScore;

        curentContestant.oppositeScore = getOppositeDirScore(tabView.scrollView.oppositeCountValue, curentContestant.oposite_direction_penalty, totalPointsScore);
        tabView.scrollView.oppositeScoreText = curentContestant.oppositeScore;

        // recover tab status
        if (!tabPrevActived) tabView.activateTabByName(previousActive)

        recalculateAltSpaceSecPoints();
    }

    ListModel {

        id: currentWptScoreList
    }

    ListModel {

        id: currentSpeedSectionsScoreList
    }

    ListModel {

        id: currentAltitudeSectionsScoreList
    }

    ListModel {

        id: currentSpaceSectionsScoreList
    }

    Component.onCompleted: {
        curentContestant = createBlankUserObject();
    }

    function listModelToString(model) {

        var item;
        var arr = [];
        for(var i = 0; i < model.count; i++) {

            item = model.get(i);
            arr.push(JSON.stringify(item));
        }

        return arr.join("; ");
    }

    function recalculateAltSpaceSecPoints() {

        var i;
        var item;

        var res = {
            "spaceSecScoreSum": 0,
            "altSecScoreSum": 0
        }

        // alt
        for (i = 0; i < currentAltitudeSectionsScoreList.count; i++) {

            item = currentAltitudeSectionsScoreList.get(i)
            item.altSecScore = getAltSecScore(item.manualAltMinEntriesCount, item.altMinEntriesCount, item.manualAltMaxEntriesCount, item.altMaxEntriesCount, item.penaltyPercent, totalPointsScore);
            res.altSecScoreSum += item.altSecScore;
        }

        // space
        for (i = 0; i < currentSpaceSectionsScoreList.count; i++) {

            item = currentSpaceSectionsScoreList.get(i)
            item.spaceSecScore = getSpaceSecScore(item.manualEntries_out, item.entries_out, item.penaltyPercent, totalPointsScore);
            res.spaceSecScoreSum += item.spaceSecScore;
        }

        curentContestant.altSecScoreSum = res.altSecScoreSum !== 0 ? res.altSecScoreSum : -1;
        curentContestant.spaceSecScoreSum = res.spaceSecScoreSum !== 0 ? res.spaceSecScoreSum : -1;
    }

    onVisibleChanged: {

        if (visible) {

            currentWptScoreList.clear();
            if (curentContestant.wptScoreDetails != "") {
                var arr = curentContestant.wptScoreDetails.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentWptScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentSpaceSectionsScoreList.clear();
            if (curentContestant.spaceSectionsScoreDetails != "") {
                arr = curentContestant.spaceSectionsScoreDetails.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentSpaceSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentAltitudeSectionsScoreList.clear();
            if (curentContestant.altitudeSectionsScoreDetails != "") {
                arr = curentContestant.altitudeSectionsScoreDetails.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentAltitudeSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentSpeedSectionsScoreList.clear();
            if (curentContestant.speedSectionsScoreDetails != "") {
                arr = curentContestant.speedSectionsScoreDetails.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentSpeedSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            pilotName = (curentContestant.name).split(' – ')[0];
            copilotName = (curentContestant.name).split(' – ')[1] === undefined ? "" : (curentContestant.name).split(' – ')[1];
            category = curentContestant.category;
            speed = curentContestant.speed;
            startTime = curentContestant.startTime;

            // get tab status
            var previousActive = tabView.getActive();
            var tabPrevActived = (previousActive  === "manVals");

            // set tab active
            if (!tabPrevActived) tabView.activateTabByName("manVals");

            // load and recal values
            tabView.scrollView.startTimeDifferenceText = curentContestant.startTimeDifference;

            tabView.scrollView.landingScoreText = String(curentContestant.landingScore);

            tabView.scrollView.markersOkValue = curentContestant.markersOk;
            tabView.scrollView.markersNokValue = curentContestant.markersNok;
            tabView.scrollView.markersFalseValue = curentContestant.markersFalse;
            curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, curentContestant.marker_max_score);
            tabView.scrollView.markersScoreText = curentContestant.markersScore;

            tabView.scrollView.photosOkValue = curentContestant.photosOk;
            tabView.scrollView.photosNokValue = curentContestant.photosNok;
            tabView.scrollView.photosFalseValue = curentContestant.photosFalse;
            curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, curentContestant.photos_max_score);
            tabView.scrollView.photosScoreText = curentContestant.photosScore;

            tabView.scrollView.otherPointsText = String(curentContestant.otherPoints);
            tabView.scrollView.pointNoteText = curentContestant.pointNote;

            tabView.scrollView.otherPenaltyText = String(curentContestant.otherPenalty);

            var res = getScorePointsSum(curentContestant)
            curentContestant.tgScoreSum = res.tgScoreSum;
            curentContestant.sgScoreSum = res.sgScoreSum;
            curentContestant.tpScoreSum = res.tpScoreSum;
            curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
            curentContestant.speedSecScoreSum = res.speedSecScoreSum;
            resultsMainWindow.totalPointsScore = res.sum;

            curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, curentContestant.time_window_size, curentContestant.time_window_penalty, totalPointsScore);
            tabView.scrollView.startTimeScoreText = curentContestant.startTimeScore;

            curentContestant.circlingScore = getGyreScore(tabView.scrollView.circlingCountValue, curentContestant.gyre_penalty, totalPointsScore);
            tabView.scrollView.circlingScoreText = curentContestant.circlingScore;

            curentContestant.oppositeScore = getOppositeDirScore(tabView.scrollView.oppositeCountValue, curentContestant.oposite_direction_penalty, totalPointsScore);
            tabView.scrollView.oppositeScoreText = curentContestant.oppositeScore;

            recalculateAltSpaceSecPoints();

            // recover tab status
            if (!tabPrevActived) tabView.activateTabByName(previousActive)

        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    RowLayout {
        id: resultsHeader;
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 10
        spacing: 30

        NativeText {
            text: curentContestant.name
            font.bold : true
        }
        NativeText {
            text: curentContestant.category
            Layout.minimumWidth: 50
        }
        NativeText {
            text: F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(curentContestant.startTime), applicationWindow.utc_offset_sec))
            Layout.minimumWidth: 50
        }
        NativeText {
            text: curentContestant.speed + " km/h"
            Layout.minimumWidth: 50
        }
        NativeText {
            text: curentContestant.aircraft_registration
        }
        NativeText {
            text: curentContestant.aircraft_type
        }
    }

    TabView {

        id: tabView;

        anchors.top: resultsHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: actionButtons.top
        anchors.margins: 20

        property alias scrollView: manualValuesTab.item

        function getActive() {
            if (manualValuesTab.visible) {
                return "manVals";
            }
            if (pointValuesTab.visible) {
                return "pointVals";
            }
            if (speedSecValuesTab.visible) {
                return "speedSecVals"
            }
            if (altSecValuesTab.visible) {
                return "altSecVals"
            }
            if (spaceSecValuesTab.visible) {
                return "spaceSecVals"
            }
            if (summaryTab.visible) {
                return "summaryTab"
            }
            return "";
        }

        function activateTabByName(name) {
            manualValuesTab.visible = false;
            pointValuesTab.visible = false;
            speedSecValuesTab.visible = false;
            altSecValuesTab.visible = false;
            spaceSecValuesTab.visible = false;
            switch (name) {
            case "manVals":
                manualValuesTab.visible = true;
                break;
            case "pointVals":
                pointValuesTab.visible = true;
                break;
            case "speedSecVals":
                speedSecValuesTab.visible = true;
                break;
            case "altSecVals":
                altSecValuesTab.visible = true;
                break;
            case "spaceSecVals":
                spaceSecValuesTab.visible = true;
                break;
            case "summaryTab":
                summaryTab.visible = true;
                break;
            default:
                break;
            }
        }

        Tab {

            id: manualValuesTab
            property int columnsCount: 4;
            property int columnWidth: resultsMainWindow.width / columnsCount - 40;

            //% "Results window manual values"
            title: qsTrId("results-window-dialog-manual-values")

            ScrollView {

                id: manualValuesTabScrollView
                anchors.fill: parent;
                anchors.margins: 15

                property alias startTimeText: startTimeMeasuredTextField.text;
                property alias startTimeDifferenceText: startTimeDifferenceTextField.text;
                property alias startTimeScoreText: startTimeScoreTextField.text;

                property alias landingScoreText: landingScoreTextField.text;

                property alias markersOkValue: markersOkSpinBox.value;
                property alias markersNokValue: markersNokSpinBox.value
                property alias markersFalseValue: markersFalseSpinBox.value;
                property alias markersScoreText: markersScoreTextField.text;

                property alias photosOkValue: photosOkSpinBox.value;
                property alias photosNokValue: photosNokSpinBox.value;
                property alias photosFalseValue: photosFalseSpinBox.value;
                property alias photosScoreText: photosScoreTextField.text;

                property alias circlingCountValue: circlingSpinBox.value;
                property alias circlingScoreText: circlingScoreTextField.text;

                property alias oppositeCountValue: oppositeSpinBox.value;
                property alias oppositeScoreText: oppositeScoreTextField.text;

                property alias otherPointsText: otherPointsTextField.text;
                property alias otherPenaltyText: otherPenaltyTextField.text;

                property alias pointNoteText: pointNoteTextField.text


                Column {

                    id: column
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 15;

                    //start time
                    NativeText {
                        //% "Results window manual values take of window"
                        text: qsTrId("results-window-dialog-manual-values-takeof-window")
                        font.bold : true
                    }

                    RowLayout {

                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        //% "takeof window measured"
                        NativeText { text: qsTrId("score-table-takeof-window-measured"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "takeof window inserted"
                        NativeText { text: qsTrId("score-table-takeof-window-manual"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "takeof window difference"
                        NativeText { text: qsTrId("score-table-takeof-window-difference"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "takeof window score"
                        NativeText { text: qsTrId("score-table-takeof-window-score"); Layout.preferredWidth: manualValuesTab.columnWidth}
                    }

                    RowLayout {

                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;

                            MyReadOnlyTextField {
                                text: F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(curentContestant.startTime), applicationWindow.utc_offset_sec))
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyEditableTextField {

                                id: startTimeMeasuredTextField

                                text: (curentContestant.startTimeMeasured !== "" ? F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(curentContestant.startTimeMeasured), applicationWindow.utc_offset_sec)) : "")
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height

                                property string prevVal: "";

                                onAccepted: {

                                    var str = text;

                                    // remove start time
                                    if (str === "") {
                                        curentContestant.startTimeMeasured = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(curentContestant.startTime), applicationWindow.utc_offset_sec));
                                        text = curentContestant.startTimeMeasured;
                                        curentContestant.startTimeDifference = F.addTimeStrFormat(0);
                                        startTimeDifferenceTextField.text = F.addTimeStrFormat(0);
                                    }
                                    else {

                                        var sec = F.strTimeValidator(str);
                                        var time;
                                        if (sec < 0) {
                                            text = prevVal;
                                        }
                                        else {

                                            time = F.addTimeStrFormat(F.subUtcFromTime(sec, applicationWindow.utc_offset_sec));

                                            curentContestant.startTimeMeasured = time;
                                            text = F.addTimeStrFormat(F.addUtcToTime(F.timeToUnix(curentContestant.startTimeMeasured), applicationWindow.utc_offset_sec));

                                            var refVal = F.timeToUnix(curentContestant.startTime);
                                            var diff = Math.abs(refVal - (F.subUtcFromTime(sec, applicationWindow.utc_offset_sec)));
                                            curentContestant.startTimeDifference = F.addTimeStrFormat(diff);
                                            startTimeDifferenceTextField.text = curentContestant.startTimeDifference;
                                        }
                                    }
                                }

                                onActiveFocusChanged: {

                                    if (focus)
                                        prevVal = text;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: startTimeDifferenceTextField;
                                text: curentContestant.startTimeDifference;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height

                                onTextChanged: {

                                    if (tabView.scrollView === null)
                                        return;

                                    // add penalty
                                    curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, curentContestant.time_window_size, curentContestant.time_window_penalty, totalPointsScore);
                                    startTimeScoreTextField.text = curentContestant.startTimeScore;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: startTimeScoreTextField;
                                text: curentContestant.startTimeScore;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        } // penalizace - zaporne cislo
                    }

                    //landing accurancy
                    NativeText {
                        //% "Results window manual values landing accurancy"
                        text: qsTrId("results-window-dialog-manual-values-landing-accurancy")
                        font.bold : true
                    }

                    //landing
                    GridLayout {

                        columns: 1
                        rows: 2
                        rowSpacing: 10
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        //% "Results window landing accurancy score"
                        NativeText { text: qsTrId("score-table-landing-accurancy-score"); Layout.preferredWidth: manualValuesTab.columnWidth;}

                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;

                            MyEditableTextField {
                                id: landingScoreTextField;
                                text: curentContestant.landingScore
                                validator: IntValidator{bottom: 0; top: 250;}
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height

                                onEditingFinished: {

                                    curentContestant.landingScore = parseInt(text);

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                    }

                    // markers
                    NativeText {
                        //% "Results window manual values markers"
                        text: qsTrId("results-window-dialog-manual-values-markers")
                        font.bold : true
                    }

                    RowLayout {

                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        //% "markers ok count"
                        NativeText { text: qsTrId("score-table-markers-ok"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "markers nok count"
                        NativeText { text: qsTrId("score-table-markers-nok"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "markers false count"
                        NativeText { text: qsTrId("score-table-markers-false"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "markers score"
                        NativeText { text: qsTrId("score-table-markers-score"); Layout.preferredWidth: manualValuesTab.columnWidth}
                    }

                    RowLayout {

                        id: markersRow
                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: markersOkSpinBox
                                value: curentContestant.markersOk;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.markersOk = value;
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, curentContestant.marker_max_score)
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: markersNokSpinBox
                                value: curentContestant.markersNok;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.markersNok = value;
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, curentContestant.marker_max_score);
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: markersFalseSpinBox
                                value: curentContestant.markersFalse
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.markersFalse = value;
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, curentContestant.marker_max_score);
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: markersScoreTextField ;
                                text: curentContestant.markersScore;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                    }

                    //photos
                    NativeText {
                        //% "Results window manual values photos"
                        text: qsTrId("results-window-dialog-manual-values-photos")
                        font.bold : true
                    }

                    RowLayout {

                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        //% "photos ok count"
                        NativeText { text: qsTrId("score-table-photos-ok"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "photos nok count"
                        NativeText { text: qsTrId("score-table-photos-nok"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "photos false count"
                        NativeText { text: qsTrId("score-table-photos-false"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "photos score"
                        NativeText { text: qsTrId("score-table-photos-score"); Layout.preferredWidth: manualValuesTab.columnWidth}
                    }

                    RowLayout {

                        id: photosRow
                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: photosOkSpinBox
                                value: curentContestant.photosOk;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.photosOk = value;
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, curentContestant.photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: photosNokSpinBox
                                value: curentContestant.photosNok;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.photosNok = value;
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, curentContestant.photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: photosFalseSpinBox
                                value: curentContestant.photosFalse;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.photosFalse = value;
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, curentContestant.photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    var res = getScorePointsSum(curentContestant)
                                    curentContestant.tgScoreSum = res.tgScoreSum;
                                    curentContestant.sgScoreSum = res.sgScoreSum;
                                    curentContestant.tpScoreSum = res.tpScoreSum;
                                    curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                    curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                    resultsMainWindow.totalPointsScore = res.sum;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: photosScoreTextField;
                                text: curentContestant.photosScore;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                    }

                    // circling and opposite dirrection
                    NativeText {
                        //% "Results window manual values circling and opposite dirrection"
                        text: qsTrId("results-window-dialog-manual-values-circling-opposite-dirrection")
                        font.bold : true
                    }

                    RowLayout {

                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        //% "circling on track count"
                        NativeText { text: qsTrId("score-table-circling-count"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "circling on track score"
                        NativeText { text: qsTrId("score-table-circling-score"); Layout.preferredWidth: manualValuesTab.columnWidth} //zaporne cislo
                        //% "opposite dirrection on track count"
                        NativeText { text: qsTrId("score-table-opposite-count"); Layout.preferredWidth: manualValuesTab.columnWidth}
                        //% "opposite dirrection on track score"
                        NativeText { text: qsTrId("score-table-opposite-score"); Layout.preferredWidth: manualValuesTab.columnWidth} //zaporne cislo
                    }
                    RowLayout {


                        spacing: 10;
                        anchors.leftMargin: 30
                        anchors.left: parent.left

                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: circlingSpinBox
                                value: curentContestant.circlingCount
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.circlingCount = value;
                                    curentContestant.circlingScore = getGyreScore(value, curentContestant.gyre_penalty, totalPointsScore);
                                    circlingScoreTextField.text = curentContestant.circlingScore;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: circlingScoreTextField;
                                text: curentContestant.circlingScore;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MySpinBox {
                                id: oppositeSpinBox
                                value: curentContestant.oppositeCount
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: 23

                                on__TextChanged: {
                                    curentContestant.oppositeCount = value;
                                    curentContestant.oppositeScore = getOppositeDirScore(value, curentContestant.oposite_direction_penalty, totalPointsScore);
                                    oppositeScoreTextField.text = curentContestant.oppositeScore;
                                }
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyReadOnlyTextField {
                                id: oppositeScoreTextField;
                                text: curentContestant.oppositeScore;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                    }


                    RowLayout {

                        spacing: 10;
                        anchors.left: parent.left

                        ColumnLayout {

                            id: colExtraPoints
                            spacing: 10
                            Layout.preferredWidth: manualValuesTab.columnWidth * 2

                            // others points
                            NativeText {
                                //% "Results window manual values extra points"
                                text: qsTrId("results-window-dialog-manual-values-extra-points")
                                font.bold : true
                            }

                            RowLayout {

                                anchors.left: parent.left
                                anchors.leftMargin: 30
                                spacing: parent.spacing

                                //% "other points"
                                NativeText {
                                    text: qsTrId("score-table-other-points");
                                    Layout.preferredWidth: manualValuesTab.columnWidth
                                }

                                //% "other points"
                                NativeText {
                                    text: qsTrId("score-table-other-points");
                                    Layout.preferredWidth: manualValuesTab.columnWidth
                                }
                            }

                            RowLayout {

                                spacing: parent.spacing
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                Item {
                                    Layout.preferredWidth: manualValuesTab.columnWidth;
                                    Layout.preferredHeight: 23;

                                    MyEditableTextField {
                                        id: otherPointsTextField
                                        text: curentContestant.otherPoints;
                                        validator: IntValidator{bottom: 0; top: 99999;}
                                        mwidth: manualValuesTab.columnWidth/2
                                        mheight: parent.height

                                        onEditingFinished: {
                                            curentContestant.otherPoints = parseInt(text);

                                            var res = getScorePointsSum(curentContestant)
                                            curentContestant.tgScoreSum = res.tgScoreSum;
                                            curentContestant.sgScoreSum = res.sgScoreSum;
                                            curentContestant.tpScoreSum = res.tpScoreSum;
                                            curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                            curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                            resultsMainWindow.totalPointsScore = res.sum;
                                        }

                                        onTextChanged: {
                                            otherPointsPointsTextField.text = isNaN(parseInt(text)) ? "" : parseInt(text);
                                        }
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: manualValuesTab.columnWidth;
                                    Layout.preferredHeight: 23;

                                    MyReadOnlyTextField {
                                        id: otherPointsPointsTextField
                                        text: (curentContestant.otherPoints);
                                        mwidth: manualValuesTab.columnWidth/2
                                        mheight: parent.height
                                    }
                                }
                            }


                            // others penalty
                            NativeText {
                                //% "Results window manual values extra penalty"
                                text: qsTrId("results-window-dialog-manual-values-extra-penalty")
                                font.bold : true
                            }

                            RowLayout {

                                spacing: parent.spacing
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                //% "other penalty"
                                NativeText {
                                    text: qsTrId("score-table-other-points");
                                    Layout.preferredWidth: manualValuesTab.columnWidth
                                }

                                //% "other penalty"
                                NativeText {
                                    text: qsTrId("score-table-other-penalty");
                                    Layout.preferredWidth: manualValuesTab.columnWidth
                                }
                            }

                            RowLayout {

                                spacing: parent.spacing
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                Item {
                                    Layout.preferredWidth: manualValuesTab.columnWidth;
                                    Layout.preferredHeight: 23;

                                    MyEditableTextField {

                                        id: otherPenaltyTextField
                                        text: curentContestant.otherPenalty;
                                        validator: IntValidator{bottom: 0; top: 99999;}
                                        mwidth: manualValuesTab.columnWidth/2
                                        mheight: parent.height

                                        onEditingFinished: {
                                            curentContestant.otherPenalty = parseInt(text);

                                            var res = getScorePointsSum(curentContestant)
                                            curentContestant.tgScoreSum = res.tgScoreSum;
                                            curentContestant.sgScoreSum = res.sgScoreSum;
                                            curentContestant.tpScoreSum = res.tpScoreSum;
                                            curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                                            curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                                            resultsMainWindow.totalPointsScore = res.sum;
                                        }

                                        onTextChanged: {
                                            otherPenaltyPointsTextField.text = isNaN(parseInt(text)) ? "" : parseInt(text) * -1;
                                        }
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: manualValuesTab.columnWidth;
                                    Layout.preferredHeight: 23;

                                    MyReadOnlyTextField {
                                        id: otherPenaltyPointsTextField
                                        text: (curentContestant.otherPenalty * -1);
                                        mwidth: manualValuesTab.columnWidth/2
                                        mheight: parent.height
                                    }
                                }
                            }
                        }
                        ColumnLayout {

                            Layout.preferredWidth: manualValuesTab.columnWidth  * 2;
                            spacing: 10

                            Spacer { height: 1 }

                            //% "other points note"
                            NativeText {
                                text: qsTrId("score-table-other-points-note");
                                Layout.preferredWidth: manualValuesTab.columnWidth * 2
                                anchors.left: parent.left
                                anchors.leftMargin: 30
                            }


                            TextArea {
                                id: pointNoteTextField
                                text: curentContestant.pointNote;
                                Layout.preferredWidth: manualValuesTab.columnWidth  * 2;
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                style: TextAreaStyle {
                                    renderType: Text.NativeRendering
                                }

                                onEditingFinished: {
                                    curentContestant.pointNote = text;

                                }
                            }
                        }
                    }

                    Spacer { height: 20 }
                }

            }
        }


        Tab {

            id: pointValuesTab

            //% "Results window points tab"
            title: qsTrId("results-window-dialog-points-table")

            TableView {

                id: newScoreTablePoints
                model: currentWptScoreList
                anchors.fill: parent
                visible: mainViewMenuTables.checked


                itemDelegate: ScoreListTableDelegate {

                    onChangeModel: {

                        if (row >= currentWptScoreList.count || row < 0 || row === undefined) {
                            return;
                        }

                        var calc_val;
                        var it;

                        currentWptScoreList.setProperty(row, role, value);
                        it = currentWptScoreList.get(row);

                        switch (role) {

                            case "tg_time_manual":

                                var tg_time_difference = it.tg_time_manual === -1 ? Math.abs(it.tg_time_calculated - it.tg_time_measured) : Math.abs(it.tg_time_calculated - it.tg_time_manual);
                                calc_val = Math.round(((it.type & (0x1 << 1)) ?  getTGScore(tg_time_difference, it.tg_category_max_score, it.tg_category_penalty, it.tg_category_time_tolerance)  : -1));
                                currentWptScoreList.setProperty(row, "tg_score", calc_val);
                                currentWptScoreList.setProperty(row, "tg_time_difference", tg_time_difference);
                                break;

                            case "tp_hit_manual":

                                calc_val = (it.type & (0x1 << 0)) ? getTPScore(it.tp_hit_manual, it.tp_hit_measured, it.tp_category_max_score) : -1;
                                currentWptScoreList.setProperty(row, "tp_score", calc_val);
                                break;

                            case "sg_hit_manual":

                                calc_val = (it.type & (0x1 << 2)) ? getSGScore(it.sg_hit_manual, it.sg_hit_measured, it.sg_category_max_score) : -1;
                                currentWptScoreList.setProperty(row, "sg_score", calc_val);
                                break;

                            case "alt_manual":

                                //calc_val = getAltScore(it.alt_manual, it.alt_measured, it.alt_min, it.alt_max, it.type, it.category_alt_penalty);
                                //currentWptScoreList.setProperty(row, "alt_score", calc_val);
                                break;

                            default:
                                break;
                        }

                        // recalc alt limits score
                        var gatePointSum = Math.max(it.tg_score, 0) + Math.max(it.tp_score, 0) + Math.max(it.sg_score, 0);
                        calc_val = getAltScore(it.alt_manual, it.alt_measured, it.alt_min, it.alt_max, it.type, it.category_alt_penalty);

                        currentWptScoreList.setProperty(row, "alt_score", ((calc_val === -1) ? -1 : (Math.abs(calc_val) > gatePointSum) ? gatePointSum * -1 : calc_val)); // min points for each gate is 0

                        curentContestant.wptScoreDetails = listModelToString(currentWptScoreList);

                        var res = getScorePointsSum(curentContestant)
                        curentContestant.tgScoreSum = res.tgScoreSum;
                        curentContestant.sgScoreSum = res.sgScoreSum;
                        curentContestant.tpScoreSum = res.tpScoreSum;
                        curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                        curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                        resultsMainWindow.totalPointsScore = res.sum;

                        newScoreTablePoints.selection.clear();
                        newScoreTablePoints.selection.select(row);
                        newScoreTablePoints.currentRow = row;

                    }
                }

                rowDelegate: Rectangle {
                    height: 30;
                    color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                }

                //% "Name"
                TableViewColumn {title: qsTrId("score-table-name"); role: "title"; width: 150;}

                //% "Type"
                TableViewColumn {title: qsTrId("score-table-type"); role: "type";}

                //% "Distance from VBT"
                TableViewColumn {title: qsTrId("score-table-distance_from_vbt"); role: "distance_from_vbt"; width: 100;}

                //% "TG calculated time"
                TableViewColumn {title: qsTrId("score-table-tg_time_calculated"); role: "tg_time_calculated"; width: 100;}

                //% "TG measured time"
                //TableViewColumn {title: qsTrId("score-table-tg_time_measured"); role: "tg_time_measured"; width: 100;}

                //% "TG manual time"
                TableViewColumn {title: qsTrId("score-table-tg_time_manual"); role: "tg_time_manual"; width: 100;}

                //% "TG time difference"
                TableViewColumn {title: qsTrId("score-table-tg_time_difference"); role: "tg_time_difference"; width: 100;}

                //% "TG score"
                TableViewColumn {title: qsTrId("score-table-tg_score"); role: "tg_score"; width: 100;}

                //% "TP hit auto"
                //TableViewColumn {title: qsTrId("score-table-tp_hit_measured"); role: "tp_hit_measured"; width: 100;}

                //% "TP hit manual"
                TableViewColumn {title: qsTrId("score-table-tp_hit_manual"); role: "tp_hit_manual"; width: 100;}

                //% "TP score"
                TableViewColumn {title: qsTrId("score-table-tp_score"); role: "tp_score"; width: 100;}

                //% "SG hit auto"
                //TableViewColumn {title: qsTrId("score-table-sg_hit_measured"); role: "sg_hit_measured"; width: 100;}

                //% "SG hit manual"
                TableViewColumn {title: qsTrId("score-table-sg_hit_manual"); role: "sg_hit_manual"; width: 100;}

                //% "SG score"
                TableViewColumn {title: qsTrId("score-table-sg_score"); role: "sg_score"; width: 100;}

                //% "Point altitude min"
                TableViewColumn {title: qsTrId("score-table-alt_min"); role: "alt_min"; width: 100;}

                //% "Point altitude max"
                TableViewColumn {title: qsTrId("score-table-alt_max"); role: "alt_max"; width: 100;}

                //% "Point altitude measured"
                //TableViewColumn {title: qsTrId("score-table-alt_measured"); role: "alt_measured"; width: 100;}

                //% "Point altitude manual"
                TableViewColumn {title: qsTrId("score-table-alt_manual"); role: "alt_manual"; width: 100;}

                //% "Point altitude score"
                TableViewColumn {title: qsTrId("score-table-alt_score"); role: "alt_score"; width: 100;}
            }
        }

        Tab {

            id: speedSecValuesTab

            //% "Results window speed sections tab"
            title: qsTrId("results-window-dialog-speed-sections-table")

            TableView {

                id: newScoreTableSpeedSecions
                model: currentSpeedSectionsScoreList
                anchors.fill: parent

                rowDelegate: Rectangle {
                    height: 30;
                    color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                }

                itemDelegate: ScoreListTableDelegate {

                    onChangeModel: {

                        if (row >= currentSpeedSectionsScoreList.count || row < 0 || row === undefined) {
                            return;
                        }

                        var it;

                        currentSpeedSectionsScoreList.setProperty(row, role, value);
                        it = currentSpeedSectionsScoreList.get(row);

                        switch (role) {

                            case "manualSpeed":

                                var diff = (value === -1 ? Math.abs(parseInt(resultsMainWindow.speed) - currentSpeedSectionsScoreList.get(row).calculatedSpeed) : Math.abs(parseInt(resultsMainWindow.speed) - value));
                                currentSpeedSectionsScoreList.setProperty(row, "speedDifference", diff);
                                currentSpeedSectionsScoreList.setProperty(row, "speedSecScore", getSpeedSectionScore(diff, it.speedTolerance, it.maxScore, it.speedPenaly));
                                break

                            default:
                        }

                        curentContestant.speedSectionsScoreDetails = listModelToString(currentSpeedSectionsScoreList);

                        var res = getScorePointsSum(curentContestant)
                        curentContestant.tgScoreSum = res.tgScoreSum;
                        curentContestant.sgScoreSum = res.sgScoreSum;
                        curentContestant.tpScoreSum = res.tpScoreSum;
                        curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                        curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                        resultsMainWindow.totalPointsScore = res.sum;

                        newScoreTableSpeedSecions.selection.clear();
                        newScoreTableSpeedSecions.selection.select(row);
                        newScoreTableSpeedSecions.currentRow = row;

                    }
                }

                //% "Speed sections start point name"
                TableViewColumn {title: qsTrId("speed-sections-score-table-start-name"); role: "startPointName"; width: 150;}

                //% "Speed sections end point name"
                TableViewColumn {title: qsTrId("speed-sections-score-table-end-name"); role: "endPointName"; width: 150;}

                //% "Speed sections measured speed"
                TableViewColumn {title: qsTrId("speed-sections-score-table-measured"); role: "manualSpeed"; width: 150;}

                //% "Speed sections speed difference"
                TableViewColumn {title: qsTrId("speed-sections-score-table-difference"); role: "speedDifference"; width: 150;}

                //% "Speed sections score points"
                TableViewColumn {title: qsTrId("speed-sections-score-table-score"); role: "speedSecScore"; width: 150;}
            }

        }

        Tab {

            id: altSecValuesTab

            //% "Results window altitude sections tab"
            title: qsTrId("results-window-dialog-altitude-sections-table")

            TableView {

                id: newScoreTableAltitudeSecions
                model: currentAltitudeSectionsScoreList
                anchors.fill: parent


                rowDelegate: Rectangle {
                    height: 30;
                    color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                }

                itemDelegate: ScoreListTableDelegate {

                    onChangeModel: {

                        if (row >= currentAltitudeSectionsScoreList.count || row < 0 || row === undefined) {
                            return;
                        }

                        currentAltitudeSectionsScoreList.setProperty(row, role, value);

                        recalculateAltSpaceSecPoints();

                        curentContestant.altitudeSectionsScoreDetails = listModelToString(currentAltitudeSectionsScoreList);

                        var res = getScorePointsSum(curentContestant)
                        curentContestant.tgScoreSum = res.tgScoreSum;
                        curentContestant.sgScoreSum = res.sgScoreSum;
                        curentContestant.tpScoreSum = res.tpScoreSum;
                        curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                        curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                        resultsMainWindow.totalPointsScore = res.sum;

                        newScoreTableAltitudeSecions.selection.clear();
                        newScoreTableAltitudeSecions.selection.select(row);
                        newScoreTableAltitudeSecions.currentRow = row;
                    }
                }

                //% "Alt sections start point name"
                TableViewColumn {title: qsTrId("alt-sections-score-table-start-name"); role: "startPointName"; width: 150;}

                //% "Alt sections end point name"
                TableViewColumn {title: qsTrId("alt-sections-score-table-end-name"); role: "endPointName"; width: 150;}

                //% "Alt sections min entries count"
                TableViewColumn {title: qsTrId("alt-sections-score-table-min-entries-count"); role: "manualAltMinEntriesCount"; width: 150;}

                //% "Alt sections min entries time"
                TableViewColumn {title: qsTrId("alt-sections-score-table-min-entries-time"); role: "manualAltMinEntriesTime"; width: 150;}

                //% "Alt sections max entries count"
                TableViewColumn {title: qsTrId("alt-sections-score-table-max-entries-count"); role: "manualAltMaxEntriesCount"; width: 150;}

                //% "Alt sections max entries time"
                TableViewColumn {title: qsTrId("alt-sections-score-table-max-entries-time"); role: "manualAltMaxEntriesTime"; width: 150;}

                //% "Alt sections score points"
                TableViewColumn {title: qsTrId("alt-sections-score-table-score"); role: "altSecScore"; width: 150;}
            }
        }

        Tab {

            id: spaceSecValuesTab

            //% "Results window space sections tab"
            title: qsTrId("results-window-dialog-space-sections-table")

            TableView {

                id: newScoreTableSpaceSecions
                model: currentSpaceSectionsScoreList
                anchors.fill: parent

                rowDelegate: Rectangle {
                    height: 30;
                    color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

                }

                itemDelegate: ScoreListTableDelegate {

                    onChangeModel: {

                        if (row >= currentSpaceSectionsScoreList.count || row < 0 || row === undefined) {
                            return;
                        }

                        currentSpaceSectionsScoreList.setProperty(row, role, value);

                        recalculateAltSpaceSecPoints();

                        curentContestant.spaceSectionsScoreDetails = listModelToString(currentSpaceSectionsScoreList);

                        var res = getScorePointsSum(curentContestant)
                        curentContestant.tgScoreSum = res.tgScoreSum;
                        curentContestant.sgScoreSum = res.sgScoreSum;
                        curentContestant.tpScoreSum = res.tpScoreSum;
                        curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                        curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                        resultsMainWindow.totalPointsScore = res.sum;

                        newScoreTableSpaceSecions.selection.clear();
                        newScoreTableSpaceSecions.selection.select(row);
                        newScoreTableSpaceSecions.currentRow = row;
                    }
                }

                //% "Space sections start point name"
                TableViewColumn {title: qsTrId("space-sections-score-table-start-name"); role: "startPointName"; width: 150;}

                //% "Space sections end point name"
                TableViewColumn {title: qsTrId("space-sections-score-table-end-name"); role: "endPointName"; width: 150;}

                //% "Space sections entries out count"
                TableViewColumn {title: qsTrId("space-sections-score-table-entries-count"); role: "manualEntries_out"; width: 150;}

                //% "Space sections entries out time"
                TableViewColumn {title: qsTrId("space-sections-score-table-entries-time"); role: "manualTime_spent_out"; width: 150;}

                //% "Space sections score points"
                TableViewColumn {title: qsTrId("space-sections-score-table-score"); role: "spaceSecScore"; width: 150;}
            }
        }

        Tab {
            id: summaryTab
            //% "Summary"
            title: qsTrId("summary-tab-title")

            onVisibleChanged:  {
                model = curentContestant;

                penaltySum = 0;
                penaltySum += summaryTab.model.startTimeScore !== -1 ? summaryTab.model.startTimeScore : 0;
                penaltySum += summaryTab.model.circlingScore !== -1 ? summaryTab.model.circlingScore : 0;
                penaltySum += summaryTab.model.oppositeScore !== -1 ? summaryTab.model.oppositeScore : 0;
                penaltySum += summaryTab.model.otherPenalty !== -1 ? summaryTab.model.otherPenalty : 0;
                penaltySum += summaryTab.model.spaceSecScoreSum !== -1 ? summaryTab.model.spaceSecScoreSum : 0;
                penaltySum += summaryTab.model.altSecScoreSum !== -1 ? summaryTab.model.altSecScoreSum : 0;
            }

            Component.onCompleted: {
                model = curentContestant;
            }

            property var model;
            property int penaltySum: 0;
            property int chartFontSize: 9
            property int chartLabelFontSize: 13
            property real pieSeriesSize: 0.5

            RowLayout {

                id: chartsRow
                anchors.fill: parent

                ChartView {

                    theme: ChartView.ChartThemeBlueNcs
                    antialiasing: true
                    legend.visible: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true;
                    animationOptions: ChartView.SeriesAnimations

                    //% "Points"
                    title: qsTrId("points-chart-title")
                    //titleFont.bold: true
                    titleFont.pointSize: summaryTab.chartLabelFontSize

                    PieSeries {
                        id: pieSeriesPositive
                        size: summaryTab.pieSeriesSize

                        property double armLengthFactor: 0.4

                        MPieSlice { mVal: getMarkersScore(summaryTab.model.markersOk, 0, 0, summaryTab.model.marker_max_score); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-markersOk-shortcut"); mLabelDetail: String(summaryTab.model.markersOk) + " x " + String(summaryTab.model.marker_max_score) + qmlTranslator.myTranslate("html-points-shortcut"); }
                        MPieSlice { mVal: getPhotosScore(summaryTab.model.photosOk, 0, 0, summaryTab.model.photos_max_score); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-photosOk-shortcut"); mLabelDetail: String(summaryTab.model.photosOk) + " x " + String(summaryTab.model.photos_max_score) + qmlTranslator.myTranslate("html-points-shortcut"); }
                        MPieSlice { mAbs: true; mVal: summaryTab.model.otherPoints; mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-otherPoints-shortcut"); }
                        MPieSlice { mAbs: true; mVal: summaryTab.model.tgScoreSum +
                                                   summaryTab.model.tpScoreSum +
                                                   summaryTab.model.sgScoreSum +
                                                   summaryTab.model.altLimitsScoreSum;
                                    mLabelShortcut: qmlTranslator.myTranslate("html-results-track-points");
                                    mLabelDetail: (qmlTranslator.myTranslate("html-results-ctnt-tg-shortcut") + ": " + String(summaryTab.model.tgScoreSum) + qmlTranslator.myTranslate("html-points-shortcut") + ", " +
                                                   qmlTranslator.myTranslate("html-results-ctnt-tp-shortcut") + ": " + String(summaryTab.model.tpScoreSum) + qmlTranslator.myTranslate("html-points-shortcut") + ", " +
                                                   qmlTranslator.myTranslate("html-results-ctnt-sg-shortcut") + ": " + String(summaryTab.model.sgScoreSum) + qmlTranslator.myTranslate("html-points-shortcut") + ", " +
                                                   qmlTranslator.myTranslate("html-results-ctnt-altLimits-shortcut") + ": " + String(summaryTab.model.altLimitsScoreSum) + qmlTranslator.myTranslate("html-points-shortcut") + ", " );
                        }
                        MPieSlice { mAbs: true; mVal: summaryTab.model.speedSecScoreSum; mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-speedSec-shortcut");}
                    }

                    Component.onCompleted: {
                        // Set the common slice properties dynamically for convenience
                        for (var i = 0; i < pieSeriesPositive.count; i++) {
                            pieSeriesPositive.at(i).labelPosition = PieSlice.LabelOutside;
                            pieSeriesPositive.at(i).labelVisible = true;
                            pieSeriesPositive.at(i).labelFont = Qt.font({pointSize: summaryTab.chartFontSize})
                        }
                    }
                }
                ChartView {

                    id: chartViewNegative
                    theme: ChartView.ChartThemeBlueNcs
                    antialiasing: true
                    legend.visible: false
                    Layout.fillHeight: true
                    Layout.preferredWidth: summaryTab.penaltySum !== 0 ? parent.width/2 : 0;
                    animationOptions: ChartView.SeriesAnimations

                    //% "Penalty"
                    title: qsTrId("penalty-chart-title")
                    titleFont.pointSize: summaryTab.chartLabelFontSize

                    PieSeries {
                        id: pieSeriesNegative
                        size: summaryTab.pieSeriesSize

                        property double armLengthFactor: 0.2

                        MPieSlice { mVal: (summaryTab.model.startTimeScore); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-takeOfF-shortcut"); mLabelDetail: String(summaryTab.model.startTimeDifference) + " " + String(summaryTab.model.time_window_penalty) + "%"; }
                        MPieSlice { mVal: (summaryTab.model.circlingScore); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-circling-shortcut"); mLabelDetail: String(summaryTab.model.circlingCount * summaryTab.model.gyre_penalty) + "%" ; }
                        MPieSlice { mVal: (summaryTab.model.oppositeScore); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-opposite-shortcut"); mLabelDetail: String(summaryTab.model.oppositeCount * summaryTab.model.oposite_direction_penalty) + "%"; }

                        MPieSlice { mVal: (getMarkersScore(0, summaryTab.model.markersNok, 0, summaryTab.model.marker_max_score)); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-markersNok-shortcut"); mLabelDetail: String(summaryTab.model.markersNok) + " x " + String(summaryTab.model.marker_max_score) + qmlTranslator.myTranslate("html-points-shortcut");}
                        MPieSlice { mVal: (getMarkersScore(0, 0, summaryTab.model.markersFalse, summaryTab.model.marker_max_score)); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-markersFalse-shortcut"); mLabelDetail: String(summaryTab.model.markersFalse) + " x " + String(summaryTab.model.marker_max_score) + qmlTranslator.myTranslate("html-points-shortcut");}

                        MPieSlice { mVal: (getPhotosScore(0, summaryTab.model.photosNok, 0, summaryTab.model.photos_max_score)); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-photosNok-shortcut"); mLabelDetail: String(summaryTab.model.photosNok) + " x " + String(summaryTab.model.photos_max_score) + qmlTranslator.myTranslate("html-points-shortcut");}
                        MPieSlice { mVal: (getPhotosScore(0, 0, summaryTab.model.photosFalse, summaryTab.model.photos_max_score)); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-photosFalse-shortcut"); mLabelDetail: String(summaryTab.model.photosFalse) + " x " + String(summaryTab.model.photos_max_score) + qmlTranslator.myTranslate("html-points-shortcut");}

                        MPieSlice { mVal: (summaryTab.model.otherPenalty); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-otherPenalty-shortcut");}

                        MPieSlice { mVal: (summaryTab.model.spaceSecScoreSum); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-spaceSec-shortcut");}
                        MPieSlice { mVal: (summaryTab.model.altSecScoreSum); mLabelShortcut: qmlTranslator.myTranslate("html-results-ctnt-altSec-shortcut");}
                    }

                    Component.onCompleted: {

                        // Set the common slice properties dynamically for convenience
                        for (var i = 0; i < pieSeriesNegative.count; i++) {
                            pieSeriesNegative.at(i).labelPosition = PieSlice.LabelOutside;
                            pieSeriesNegative.at(i).labelVisible  = true;
                            pieSeriesNegative.at(i).labelFont = Qt.font({pointSize: summaryTab.chartFontSize})
                        }
                    }
                }
            }
        }


    }


    /// Action Buttons

    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10;

        Button {
            //% "Ok & show"
            text: qsTrId("path-configuration-ok-show-button")
            onClicked: {

                // close window, confirm changes and show results
                okAndView();
                resultsMainWindow.visible = false;
            }
        }

        Button {
            //% "Confirm"
            text: qsTrId("path-configuration-confirm-button")
            focus: true;
            isDefault: true;
            onClicked: {

                // get tab status
                var previousActive = tabView.getActive();
                var tabPrevActived = (previousActive  === "manVals");

                // set tab active
                if (!tabPrevActived) tabView.activateTabByName("manVals");

                curentContestant.landingScore = parseInt(tabView.scrollView.landingScoreText) || 0;

                curentContestant.markersOk = tabView.scrollView.markersOkValue;
                curentContestant.markersNok = tabView.scrollView.markersNokValue;
                curentContestant.markersFalse = tabView.scrollView.markersFalseValue;
                curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, curentContestant.marker_max_score);

                curentContestant.photosOk = tabView.scrollView.photosOkValue;
                curentContestant.photosNok = tabView.scrollView.photosNokValue;
                curentContestant.photosFalse = tabView.scrollView.photosFalseValue;
                curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, curentContestant.photos_max_score);

                curentContestant.otherPoints = parseInt(tabView.scrollView.otherPointsText) || 0;
                curentContestant.otherPenalty = parseInt(tabView.scrollView.otherPenaltyText) || 0;

                curentContestant.pointNote = tabView.scrollView.pointNoteText;

                curentContestant.circlingCount = tabView.scrollView.circlingCountValue;

                curentContestant.oppositeCount = tabView.scrollView.oppositeCountValue;

                var res = getScorePointsSum(curentContestant)
                curentContestant.tgScoreSum = res.tgScoreSum;
                curentContestant.sgScoreSum = res.sgScoreSum;
                curentContestant.tpScoreSum = res.tpScoreSum;
                curentContestant.altLimitsScoreSum = res.altLimitsScoreSum;
                curentContestant.speedSecScoreSum = res.speedSecScoreSum;
                resultsMainWindow.totalPointsScore = res.sum;

                // validate and save start time
                var str = tabView.scrollView.startTimeText;
                if (str === "") {

                    curentContestant.startTimeMeasured = curentContestant.startTime;
                    curentContestant.startTimeDifference = F.addTimeStrFormat(0);
                    curentContestant.startTimeScore = 0;
                }
                else {

                    var sec = F.strTimeValidator(str);
                    var time;
                    if (sec >= 0) {

                        time = F.addTimeStrFormat(F.subUtcFromTime(sec, applicationWindow.utc_offset_sec));

                        curentContestant.startTimeMeasured = time;
                        var refVal = F.timeToUnix(curentContestant.startTime);
                        var diff = Math.abs(refVal - (F.subUtcFromTime(sec, applicationWindow.utc_offset_sec)));
                        curentContestant.startTimeDifference = F.addTimeStrFormat(diff);

                        // add penalty
                        if (diff > curentContestant.time_window_size)
                            curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, curentContestant.time_window_size, curentContestant.time_window_penalty, totalPointsScore);
                        else
                            curentContestant.startTimeScore = 0;
                    }
                }

                curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, curentContestant.time_window_size, curentContestant.time_window_penalty, totalPointsScore);
                curentContestant.circlingScore = getGyreScore(tabView.scrollView.circlingCountValue, curentContestant.gyre_penalty, totalPointsScore);
                curentContestant.oppositeScore = getOppositeDirScore(tabView.scrollView.oppositeCountValue, curentContestant.oposite_direction_penalty, totalPointsScore);

                // recover tab status
                if (!tabPrevActived) tabView.activateTabByName(previousActive)

                // close window and confirm changes
                ok();
                resultsMainWindow.visible = false;
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("path-configuration-ok-cancel")
            onClicked: {
                resultsMainWindow.visible = false;
            }
        }
    }
}

