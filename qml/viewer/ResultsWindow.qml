import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

import "functions.js" as F

ApplicationWindow {

    id: resultsMainWindow
    width: 1280;
    height: 860;
    modality: "WindowModal"
    title: (copilotName === "" ? pilotName : pilotName + " - " + copilotName) + "   " + category + "    " + speed + " km/h   " + startTime
    color: "#ffffff"

    property string wptScore;
    property string speedSections;
    property string altSections;
    property string spaceSections;

    property variant curentContestant: {
        "name": " - ",
        "category": "",
        "fullName": "undefined",
        "startTime": "",
        "filename": "",
        "speed": -1,
        "aircraft_type": "",
        "aircraft_registration": "",
        "crew_id": "",
        "pilot_id": "",
        "copilot_id": "",
        "markersOk": 0,
        "markersNok": 0,
        "markersFalse": 0,
        "markersScore": 0,
        "photosOk": 0,
        "photosNok": 0,
        "photosFalse": 0,
        "photosScore": 0,
        "startTimeMeasured": "",
        "startTimeDifference": "",
        "startTimeScore": 0,
        "landingScore": 0,
        "circlingCount": 0,
        "circlingScore": 0,
        "oppositeCount": 0,
        "oppositeScore": 0,
        "otherPoints": 0,
        "otherPenalty": 0,
        "pointNote": ""
    };

    // used only on ok() signal
    property string currentWptScoreString;
    property string currentSpeedSectionsScoreString;
    property string currentAltitudeSectionsScoreString;
    property string currentSpaceSectionsScoreString;

    property string pilotName;
    property string copilotName;
    property string category;
    property string speed;
    property string startTime;

    property int time_window_penalty;
    property int time_window_size;
    property int photos_max_score;
    property int oposite_direction_penalty;
    property int marker_max_score;
    property int gyre_penalty;

    property int totalPointsScore;

    property alias currentWptScoreListAlias:  currentWptScoreList
    property alias currentSpeedSectionsScoreListAlias:  currentSpeedSectionsScoreList
    property alias currentAltitudeSectionsScoreListAlias:  currentAltitudeSectionsScoreList
    property alias currentSpaceSectionsScoreListAlias:  currentSpaceSectionsScoreList

    // recalculate percent points
    onTotalPointsScoreChanged: {

        curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore);
        tabView.scrollView.startTimeScoreText = curentContestant.startTimeScore;

        curentContestant.circlingScore = getGyreScore(tabView.scrollView.circlingCountValue, gyre_penalty, totalPointsScore);
        tabView.scrollView.circlingScoreText = curentContestant.circlingScore;

        curentContestant.oppositeScore = getOppositeDirScore(tabView.scrollView.oppositeCountValue, oposite_direction_penalty, totalPointsScore);
        tabView.scrollView.oppositeScoreText = curentContestant.oppositeScore;

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

    function recalculateAltSpaceSecPoints() {

        var i;
        var item;

        // alt
        for (i = 0; i < currentAltitudeSectionsScoreList.count; i++) {

            item = currentAltitudeSectionsScoreList.get(i)
            item.altSecScore = getAltSecScore(item.manualAltMinEntriesCount, item.altMinEntriesCount, item.manualAltMaxEntriesCount, item.altMaxEntriesCount, item.penaltyPercent, totalPointsScore);
        }

        // space
        for (i = 0; i < currentSpaceSectionsScoreList.count; i++) {

            item = currentSpaceSectionsScoreList.get(i)
            item.spaceSecScore = getSpaceSecScore(item.manualEntries_out, item.entries_out, item.penaltyPercent, totalPointsScore);
        }
    }


    onVisibleChanged: {

        if (visible) {

            currentWptScoreList.clear();
            if (wptScore != "") {
                var arr = wptScore.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentWptScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentSpaceSectionsScoreList.clear();
            if (spaceSections != "") {
                arr = spaceSections.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentSpaceSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentAltitudeSectionsScoreList.clear();
            if (altSections != "") {
                arr = altSections.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentAltitudeSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            currentSpeedSectionsScoreList.clear();
            if (speedSections != "") {
                arr = speedSections.split("; ")
                for (var i = 0; i < arr.length; i++) {
                    currentSpeedSectionsScoreList.append(JSON.parse(arr[i]))
                }
            }

            pilotName = (curentContestant.name).split(' – ')[0];
            copilotName = (curentContestant.name).split(' – ')[1] === undefined ? "" : (curentContestant.name).split(' – ')[1];
            category = curentContestant.category;
            speed = curentContestant.speed;
            startTime = curentContestant.startTime;

            // load and recal values
            tabView.scrollView.startTimeDifferenceText = curentContestant.startTimeDifference;

            tabView.scrollView.landingScoreText = String(curentContestant.landingScore);

            tabView.scrollView.markersOkValue = curentContestant.markersOk;
            tabView.scrollView.markersNokValue = curentContestant.markersNok;
            tabView.scrollView.markersFalseValue = curentContestant.markersFalse;
            curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, marker_max_score);
            tabView.scrollView.markersScoreText = curentContestant.markersScore;

            tabView.scrollView.photosOkValue = curentContestant.photosOk;
            tabView.scrollView.photosNokValue = curentContestant.photosNok;
            tabView.scrollView.photosFalseValue = curentContestant.photosFalse;
            curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, photos_max_score);
            tabView.scrollView.photosScoreText = curentContestant.photosScore;

            tabView.scrollView.otherPointsText = String(curentContestant.otherPoints);
            tabView.scrollView.pointNoteText = curentContestant.pointNote;

            tabView.scrollView.otherPenaltyText = String(curentContestant.otherPenalty);

            listModelsToString();
            totalPointsScore = getScorePointsSum(curentContestant, resultsMainWindow.currentWptScoreString, resultsMainWindow.currentSpeedSectionsScoreString);
        }
    }

    function listModelsToString() {

        var item;
        var i;

        var arr = [];
        for(i = 0; i < currentWptScoreList.count; i++) {

            item = currentWptScoreList.get(i);
            arr.push(JSON.stringify(item));
        }
        currentWptScoreString = arr.join("; ");

        arr = [];
        for(i = 0; i < currentSpeedSectionsScoreList.count; i++) {

            item = currentSpeedSectionsScoreList.get(i);
            arr.push(JSON.stringify(item));
        }
        currentSpeedSectionsScoreString = arr.join("; ");

        arr = [];
        for(i = 0; i < currentAltitudeSectionsScoreList.count; i++) {

            item = currentAltitudeSectionsScoreList.get(i);
            arr.push(JSON.stringify(item));
        }
        currentAltitudeSectionsScoreString = arr.join("; ");

        arr = [];
        for(i = 0; i < currentSpaceSectionsScoreList.count; i++) {

            item = currentSpaceSectionsScoreList.get(i);
            arr.push(JSON.stringify(item));
        }
        currentSpaceSectionsScoreString = arr.join("; ");
    }

    signal ok();
    signal cancel();

    TabView {

        id: tabView;

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: actionButtons.top
        anchors.margins: 20

        property alias scrollView: manualValuesTab.item

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

                                text: curentContestant.startTime;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height
                            }
                        }
                        Item { Layout.preferredWidth: manualValuesTab.columnWidth; Layout.preferredHeight: 23;
                            MyEditableTextField {

                                id: startTimeMeasuredTextField

                                text: curentContestant.startTimeMeasured;
                                mwidth: manualValuesTab.columnWidth/2
                                mheight: parent.height

                                property string prevVal: "";

                                onAccepted: {

                                    var str = text;

                                    // remove start time
                                    if (str === "") {
                                        curentContestant.startTimeMeasured = curentContestant.startTime;
                                        text = curentContestant.startTimeMeasured;
                                        curentContestant.startTimeDifference = F.addTimeStrFormat(0);
                                        startTimeDifferenceTextField.text = F.addTimeStrFormat(0);
                                    }
                                    else {

                                        var validatedTime = F.strTimeValidator(str);
                                        if (validatedTime !== "") {

                                            curentContestant.startTimeMeasured = validatedTime;

                                            var refVal = F.timeToUnix(curentContestant.startTime);
                                            var diff = Math.abs(refVal - F.timeToUnix(validatedTime));
                                            curentContestant.startTimeDifference = F.addTimeStrFormat(diff);
                                            startTimeDifferenceTextField.text = curentContestant.startTimeDifference;
                                        }
                                        else {
                                            text = prevVal;
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

                                    // add penalty
                                    curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore);
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

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, marker_max_score)
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, marker_max_score);
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, marker_max_score);
                                    markersScoreTextField.text = curentContestant.markersScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);

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
                                    curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, photos_max_score);
                                    photosScoreTextField.text = curentContestant.photosScore;

                                    listModelsToString();
                                    totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
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
                                    curentContestant.circlingScore = getGyreScore(value, gyre_penalty, totalPointsScore);
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
                                    curentContestant.oppositeScore = getOppositeDirScore(value, oposite_direction_penalty, totalPointsScore);
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
                            Layout.preferredWidth: manualValuesTab.columnWidth

                            // others points
                            NativeText {
                                //% "Results window manual values extra points"
                                text: qsTrId("results-window-dialog-manual-values-extra-points")
                                font.bold : true
                            }

                            //% "other points"
                            NativeText {
                                text: qsTrId("score-table-other-points");
                                Layout.preferredWidth: manualValuesTab.columnWidth
                                anchors.left: parent.left
                                anchors.leftMargin: 30
                            }

                            Item {
                                Layout.preferredWidth: manualValuesTab.columnWidth;
                                Layout.preferredHeight: 23;
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                MyEditableTextField {
                                    id: otherPointsTextField
                                    text: curentContestant.otherPoints;
                                    validator: IntValidator{bottom: 0; top: 99999;}
                                    mwidth: manualValuesTab.columnWidth/2
                                    mheight: parent.height

                                    onEditingFinished: {
                                        curentContestant.otherPoints = parseInt(text);

                                        listModelsToString();
                                        totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
                                    }
                                }
                            }

                            // others penalty
                            NativeText {
                                //% "Results window manual values extra penalty"
                                text: qsTrId("results-window-dialog-manual-values-extra-penalty")
                                font.bold : true
                            }

                            //% "other penalty"
                            NativeText {
                                text: qsTrId("score-table-other-penalty");
                                Layout.preferredWidth: manualValuesTab.columnWidth
                                anchors.left: parent.left
                                anchors.leftMargin: 30
                            }

                            Item {
                                Layout.preferredWidth: manualValuesTab.columnWidth;
                                Layout.preferredHeight: 23;
                                anchors.left: parent.left
                                anchors.leftMargin: 30

                                MyEditableTextField {

                                    id: otherPenaltyTextField
                                    text: curentContestant.otherPenalty;
                                    validator: IntValidator{bottom: 0; top: 99999;}
                                    mwidth: manualValuesTab.columnWidth/2
                                    mheight: parent.height

                                    onEditingFinished: {
                                        curentContestant.otherPenalty = parseInt(text);

                                        listModelsToString();
                                        totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);
                                    }
                                }
                            }

                        }
                        ColumnLayout {

                            Layout.preferredWidth: manualValuesTab.columnWidth  * 3;
                            spacing: 10

                            Spacer { height: 1 }

                            //% "other points note"
                            NativeText {
                                text: qsTrId("score-table-other-points-note");
                                Layout.preferredWidth: manualValuesTab.columnWidth * 3
                                anchors.left: parent.left
                                anchors.leftMargin: 30
                            }


                            TextArea {
                                id: pointNoteTextField
                                text: curentContestant.pointNote;
                                Layout.preferredWidth: manualValuesTab.columnWidth  * 3;
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

                                calc_val = getAltScore(it.alt_manual, it.alt_measured, it.alt_min, it.alt_max, it.type, it.category_alt_penalty);
                                currentWptScoreList.setProperty(row, "alt_score", calc_val);
                                break;

                            default:
                                break;
                        }

                        listModelsToString();
                        totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);

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
                TableViewColumn {title: qsTrId("score-table-type"); role: "type"; width: 100;}

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

                        listModelsToString();
                        totalPointsScore = getScorePointsSum(curentContestant, currentWptScoreString, currentSpeedSectionsScoreString);

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
    }


    /// Action Buttons

    Row {
        id: actionButtons;
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10;

        Button {
            //% "Ok"
            text: qsTrId("path-configuration-ok-button")
            focus: true;
            isDefault: true;
            onClicked: {

                curentContestant.landingScore = parseInt(tabView.scrollView.landingScoreText) || 0;

                curentContestant.markersOk = tabView.scrollView.markersOkValue;
                curentContestant.markersNok = tabView.scrollView.markersNokValue;
                curentContestant.markersFalse = tabView.scrollView.markersFalseValue;
                curentContestant.markersScore = getMarkersScore(curentContestant.markersOk, curentContestant.markersNok, curentContestant.markersFalse, marker_max_score);

                curentContestant.photosOk = tabView.scrollView.photosOkValue;
                curentContestant.photosNok = tabView.scrollView.photosNokValue;
                curentContestant.photosFalse = tabView.scrollView.photosFalseValue;
                curentContestant.photosScore = getPhotosScore(curentContestant.photosOk, curentContestant.photosNok, curentContestant.photosFalse, photos_max_score);

                curentContestant.otherPoints = parseInt(tabView.scrollView.otherPointsText) || 0;
                curentContestant.otherPenalty = parseInt(tabView.scrollView.otherPenaltyText) || 0;

                curentContestant.pointNote = tabView.scrollView.pointNoteText;

                curentContestant.circlingCount = tabView.scrollView.circlingCountValue;

                curentContestant.oppositeCount = tabView.scrollView.oppositeCountValue;

                listModelsToString();

                totalPointsScore = getScorePointsSum(curentContestant, resultsMainWindow.currentWptScoreString, resultsMainWindow.currentSpeedSectionsScoreString);


                // validate and save start time
                var str = tabView.scrollView.startTimeText;
                if (str === "") {

                    curentContestant.startTimeMeasured = curentContestant.startTime;
                    curentContestant.startTimeDifference = F.addTimeStrFormat(0);
                    curentContestant.startTimeScore = 0;
                }
                else {

                    var validatedTime = F.strTimeValidator(str);
                    if (validatedTime !== "") {

                        curentContestant.startTimeMeasured = validatedTime;

                        var refVal = F.timeToUnix(curentContestant.startTime);
                        var tolerance = time_window_size;

                        var diff = Math.abs(refVal - F.timeToUnix(validatedTime));
                        curentContestant.startTimeDifference = F.addTimeStrFormat(diff);

                        // add penalty
                        if (diff > time_window_size)
                            curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore);
                        else
                            curentContestant.startTimeScore = 0;
                    }
                }

                curentContestant.startTimeScore = getTakeOffScore(tabView.scrollView.startTimeDifferenceText, time_window_size, time_window_penalty, totalPointsScore);
                curentContestant.circlingScore = getGyreScore(tabView.scrollView.circlingCountValue, gyre_penalty, totalPointsScore);
                curentContestant.oppositeScore = getOppositeDirScore(tabView.scrollView.oppositeCountValue, oposite_direction_penalty, totalPointsScore);


                // close window and confirm changes
                ok();
                resultsMainWindow.close()
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("path-configuration-ok-cancel")
            onClicked: {
                cancel();
                resultsMainWindow.close()
            }
        }
    }
}

