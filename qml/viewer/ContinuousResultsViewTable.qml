import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Rectangle {

    property variant model;

    Layout.fillWidth: true
    Layout.minimumWidth: 1000
    Layout.preferredWidth: continuousResultsScrollView.viewport.width - 10
    Layout.preferredHeight: Math.max(listView.rowHeight, (model.count + 1) * listView.rowHeight + 2);
    border.color: "grey"
    border.width: 1
    visible: listView.model.count > 0

    ListView {

        id: listView
        anchors.fill: parent
        anchors.margins: 1
        model: parent.model
        interactive: false
        delegate: contResDelegate
        header: headerDelegate

        property int rowHeight: 30
        property int rowWidth: parent.width

        Component {
                id: headerDelegate

                ContinuousResultsViewTableRow {

                    id: headerDelegateRow
                    recWidth: listView.rowWidth - 2;
                    recHeight: listView.rowHeight;
                    verticalLines: true;
                    horizontalLine: false;
                    color: "transparent"
                    col1: qmlTranslator.myTranslate("html-continuous-results-order")
                    col2: qmlTranslator.myTranslate("html-continuous-results-name")
                    col3: qmlTranslator.myTranslate("html-results-ctnt-category")
                    col4: qmlTranslator.myTranslate("html-results-ctnt-startTime")
                    col5: qmlTranslator.myTranslate("html-results-ctnt-speed")
                    col6: qmlTranslator.myTranslate("html-results-ctnt-aircraft-registration")
                    col7: qmlTranslator.myTranslate("html-results-ctnt-aircraft-type")
                    col8: qmlTranslator.myTranslate("html-results-ctnt-score-points")
                    col9: qmlTranslator.myTranslate("html-results-ctnt-score-points1000")
                }
        }

        Component {
            id: contResDelegate

            ContinuousResultsViewTableRow {

                recWidth: listView.rowWidth - 2;
                recHeight: listView.rowHeight;
                verticalLines: false;
                horizontalLine: false;
                color: order % 2? "#fff" : "#eee"
                col1: order
                col2: name
                col3: category
                col4: startTime
                col5: speed
                col6: planeReg
                col7: planeType
                col8: points
                col9: points1000
            }
        }
    }
}
