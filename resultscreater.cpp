#include "resultscreater.h"

const QString ResultsCreater::LAA_LOG_BASE64 = "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"
                                               "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"
                                               "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"
                                               "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"
                                               "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"
                                               "uXnlpvS5ecjiYPnM2dfWNN5KPpoiCjqJscxzQjM54FEPAqMEPA8LgAb/qcO7J5bLY7SqxaOTf0cUmHvQy3FdEI2HSqRRYLLjcbmw2hWw2SzqdIhaLkstm9WWBjSINuVzW1OQ7nE5SmvbfFIpRclab7Yq4IUUVqj+7XRXpq/eQL3zYZ7Fa74uEQyaLbldVVIMTyGazZsKQXbHjdLlRFP34Mhm9dJhit2PMuZehKw0vj8WiZNJpHIYSLhoJ/wrA4XR9Ix6LGunGeieXrwGnk5U2SXIcj0WXAmGH07UkmYiTSCb0qYExfRD7JRPxuyhcKPGA8SoUhDEgNWrwQ8foHH54MBVcWjLR5PH62qKR8FeAOvTRRmj6zQUJrEbhw3zudg7VrhdPtKuqmQEGmJ2CzWYjpWkqebIpBaT0jiFHxsgQA1DsdrRkchmFkmHF4XCacl+9bVvBIglKRpGOwUYsGvm9x+u7HMDpcgnSbJlxTrloJPw7j9f3lVQqhc1mIxoJ32d8RjIR/7XD6fwaQCqdwoIFq8WC1SAf5aQigxNwAznxHlBQGtpmlNZK5oVRIkVahEtHNt/4HwijI/wwYBB4ojBHBVADjAVq0aWpHvTROAvkPF7fLdFI+HbyWn47elLOFQCxaOT39GeTs+RlpXJlUzPjzeP13SJG+GgkLDyBFPmUTuHy5shXDxYZhA70EftrANFI+IGi05Tlq/J7ckaYkOjKhpfzeH3XyZmH0Uj4fkARHUk0Ev49+Zi42ITk11Z0nUTEJG6cUze6OEqsfd6LTtylR0f4oWPU4IcBqRy3A12KW4Vu9NXopJkL/UEVRiH2FUk5IjGlWH8vXuWQUqksL6FdF6nAQvuvGt8VmndRUy0jHasweCd5rYFcXkx0MqVKMMl11oVxCXmy+J6Ib1vIJybJEmWk/WSjF4UixPfMjtFoT2TpHURXyon1z2WXfvQhHiJGXfphoMQimyH0a5hFf/jEAnfC4GXDFNljslsqx/uh0NCEUcgFEuNSu27yxT1dxvsJ8pJRoU6zk5eLJshnsCkUrvwjUKqworxUscirt0ltCG9EGLxIURadnLyffG7yJtoUBm839hfJO0ILL8Jw4vdGMQyMGvzwIR7uJHlj0dANUsy7heGKkU4uwCmkusXFPaB/MQbZ4EWdc9ngRdqqWNQ+YRyHGOHTRtsu8nXX5AKgcpaaODfx28VJKqJ4hDB4kU1YbPBW8l6FV/o9i3R+Ig1VXv44K7UpG7xw60X+g0j1FYUhRzEMjLr0hwHJtbeTJ5SEBl+eA8spuGK0k11hOT0USqd8CoMQ+duy5yBSUN3kOx6RaBI1vi9cZbn4p5xBKHdAMm8gF4aQF08QMUGRhiwgDFBMY0SNAUG2ialO8QotIraeldoUXpBoV6yFLs7LrAY76s4PD6MGf5iQjF4ulW2lkIST6+yLxJyCBTQpnEfLZZNkw5PLJAujUskvzuEw2pFrpIv9IV8bQIycpXLQhcchr4dWqoSTPIcX35O9Git5YlOM7qJjkM9PnibI0wG5hBkULtIgPAKx7NKoSz9MjBr8EUCqtCMbr3xB5Xp7pebu5QxeLuAgj7IZ6XtygQ/hWhfXbhMGIUbOciv3FhtuMWlXvEHhecudXKljK8VRyOckE37FZGLxNMeMFIyO7sPHqMGPAIpq7MsodtstJT5Des0VbSXrpkltFo+GYg4up4fKIbTijqZ4G+z3odCwy51z8bGJ9osTW+TqNKXakX9vNAFmBDBq8O8BBugQBIof7kEfaKlN2ZBFG7lhtnFYxzBIm+VKf8ltmoY+asDvDf4/H+w11kQLfF4AAAAASUVORK5CYII=";

const QString ResultsCreater::FIT_LOG_BASE64 = "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"
                                               "S7s+N+ML3WosXNN1BFjB3JM1G2X4DvW5+oZ22+trBKlk6usQMeIXVOjQjaBW0ptKjIzPBsyc3K/OAquD3InsFGOho8ZCCPFoU7mnNyAPY1nYVfwQvtwvMkt52Li37rkvKamZO823wEjvvHww53iB3trFE+zzCSJESyzvziXyM2tC9/GHc0uWnFrsXv/6O/QWWGNbRkXH97wEFAPPe8NlcI9RvkDs6FiGYZCQspmxeXqW2+160bxhHuVPZGO2uUzzOMSCdXwoDViX+JYND8fNpuXlT85Ty4zHjCUjZOpH/VTyqowDY/9HbrgRO9lI0WOKDqtzfsh4Y9e6m+i45Cb0q1PDCutQ3mXEaUX910dVkO1nFEbQJxekpgKR70JtfuauXToQV7obY8GsFeMcO6b7VEnDulcB7Hs8ax1rx5YeQA/bza72b/zX0yPsNifIZwBcZ7WIyQ+qTcsBhBCIxIVggZIlkhZIhkhZAhkhVChvQYCGOEYxiSGzLzoZA+iGSFkCGSFRLDWwtLPlpe/sGSKfqGRCOSFRJAzcxJS6sKZhRn//pA/KMmyUMkKySA5V/Mb2jpu29n8xh8Lj3jegzw/Lqs1Hkc56ft0Vv2nFlfns2f2LRvpXWab6J8aAhN7ScR/hYNF6LNK4FHp2ENN6FL+/iV+Uu/YI72+tE77Ty20HFfmLE1V+kxAi9/2K1+34YKV6uhsX1+0ZyKIUMcI+cGYBdVnTme2uHTfWrQBP2GfCCuMJ+XI9JjEBD81moEkrqQlCfnxD8F6riVeH1FxY2X5mkZNi4o5RA/LoR3ISiRP+s1NT8eDqVOHWDfF3rdvLhMOxwWJKqfWqZEt1g0muhFK2FeZe7WJeXqXBvP3lxmPzXsqE4aR78hH4gr7PG5sgQyFsdIKWAJ4jFb++NeF1YoRRsjy+na1k2DXz1u6ohqRZHJDID31AF47NIKh0/xEe2m1w2OKefz4jkyeIYE2Msq61bpjcYeertVPRAPGB93Mk6yeHJR7FF96zlKwQqlaA81TnfcCta8ac5UhWXdwS7++LKWxz9uQ7yNwZk7cIcsqmvTjugfGnmNvbAvFYLStJhBNpOPvdsOl0M9UOCA2ISTKvUII2rw4JP18Y8gK9v9QlEJkLv31AFafF+3MhbbP9pebjGDHUq20ZxaMhDJurLy8nwKs6bF48FtWLEDZLq0dLUE+oyonWMdUfoE7h1zihI7dUBCcDu18SKJP1Dfn17sevABxwWb9NypB/xLCrOmhb4lO1LUEjxirH+613SU4SInduqAUeLnfht7kijZyB8Odv18h+OCTXru1AOtEzXS2m2qAW/UEnjWAjuwZLQVsr6k0HnKj7HH5/02xiRRsmHntcYeNdI62JNRLcE+H4wKTx1AcxmlAnSbqcGJqYBINjHguRlbO31EveUaPHWAfe5iRzzmS0wUdJsdPi2STRfeqZ5MK+vLs6nXM/A8U4T31AFql4L52syaO2OkoJ48ZwwK0XrlOPj73utKqCHIp5Y6iGRdefjmcjKcvFB6XUuUuqXQPqP0p5ZVULfl3uMXXp8Gw3GKjdpP4jPVbVxQSkekzyIY1qvUC/ks4HSqdaa3uIblmhtW9ypqqxXCbvrTzVFyTqYVZ++53fxSEp8a7Z4KiGRHDJ7g9+3UJ+6DiGsbur29VT/AY7aLA9aXZ9piRnrE7797xl4yBKp9neb+uha7pceO2F1LHC+SOCxmHPEYFiOMF/yY8oMMixHSB5GsEDJEskLIEMkKIUMkK4SMrFjMefiZIIwj0mMgpA8iWSFkiGSFkCGSFUKGSFYIGWaPgUfrTBBSDbGyQsgQyQohI2tgwPywtCCEBbGyQsgQyQohQyQrhIz/A8pmqnvX2M3fAAAAAElFTkSuQmCC";

const QString ResultsCreater::BLANK_USER_BASE64 = "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"
                                                  "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"
                                                  "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"
                                                  "tkv9p9vbq0XCgVFUeIY6UXX/SdYLnFIuBAQQoIx57zVal9cXjVb7cFgyBknhEB085plQwzDkHGWy+U21tZXV1fK5VKhUCjkc6Zpflzpd4/7nUzN9vFvgyBwXdey7X5v0Ol2a7V6s9WKIkoIURRyyx5QSjnnhqHn87nt7a1nu7u5XFYOO5bZrbeM4pDIytU0zff96tn5+flVfzhklMptgJOvdry5SDDKuOC6rq2vr+3u7FTK5VKpaJomhAghJLfHPbgw46wsnHPuul69Xq83mrV6o9lsyiXlyYtPGhtZRl1X19ZWXrzYX11ZAUAIPqeB0eewvOKQIAQBgGEYBYFfqzdOTs+6vT4AQCVELrPEB3VMhn1jjBVFkemUc7lcPp8rl0ulUiGXy+dyOXy3xipG58ULy7Zdx/VcbzAcdnrdXrdn205EKWOMjo6Sh7eOv4z7EcYYgnBjY31//9nKSkUfa2hpxxmTLLs4xLiLgRC5nttqt1utbqvd7g8GQRBihBWFTHpExvtiGKVMJhVSVaLrhmmapmlommYYhvxWPp8nBH9yO7K8iOe5YRhRymzHCYMgiiLP813Pc103iiI8Afj9zEUGZHDGM5nM2vrKSrlSqZSKhYKua4xzebTIktuMUT0suTgk0iQQQjDGruvWG83rWqPf73ueH0URm2i70sMEwO/2tnAu2/CoZ6CUKopSqZQJIR+LQ+6MEkLYtu04rhACIYwQRgjITD1x4rZ4d6f8olyRB4BjjA3DyJjmykp5e3trbXUFY+z7/iNaFZI8DnHcLjSENKLdXu+6Vq/VG8OhBaYMG28xaczvPiC9yx/HX4EQFvL558/3tne2MqYp+GhT62PoRm7zuMQhhAAQQkIwhDAKI9f3HccdDq1ut9tqd4fDYZyJK3ZW3nzz9/ypo/rjVn5ryCmXThjjQnBd08rlUrlcKhWLuVw2kzFN00AIUcqWze95dx6XOACYmIvGXX4Yhr1ev9PtDS3LcVzXdX3PD8MojEIZZ/XJjXF3SZYBxi1ejLNHym5KespVVdE1TdcNM2PmspliIV8qFvOFPCEkiqJ4b99jlMWoih6dOCa5cUVAiAkWQtiO02y2O52uZdmWZcvR381rfVA4O4SjQy8RgjJXHYLQMPRcLlsoFCrlyupqRdfVKGJSNxPfetw8bnHETGZipJQyRhnjUURt2xkOLdd1B7blOF4UhL7vM36/hEmYEN3QsxkzI+c8hpHNmvlsVmYdJYQQjCGE/KHiW1qeiDgmg2viKQUAMAxDz/PDMHQ9PwxDRml4/+QWCCFFVXVV1TRVommqqioAQMYY44wz/th7kE/yRMQxyeQMU05xkTQscqoLH+CuFoLLVRouD8kQN2dlwCd8pPKyLNnPkDiaRv6vnFNwCMEsUjP+8YLLE+MJiuNjZjgUeKpG4pP8JcTxl3qjM+Tp28aUB5OKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSpvL/AR/D/5D3nv3NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAABJRU5ErkJggg==";


ResultsCreater::ResultsCreater(QObject *parent) : QObject(parent) {

}


void ResultsCreater::createContinuousResultsHTML(const QString &filePath,
                                                 const QStringList &resList,
                                                 const int recordSize,
                                                 const QString &competitionName,
                                                 const QString &competitionType,
                                                 const QString &competitionDirector,
                                                 const QString &competitionDirectorAvatar,
                                                 const QStringList &competitionArbitr,
                                                 const QStringList &competitionArbitrAvatar,
                                                 const QString &competitionDate,
                                                 const QString &competitionRound,
                                                 const QString &competitionGroupName) {





    QString html = "";

    QVector<QStringList> rows;
    QStringList classesNames;
    QString categoryData;
    QStringList dataRow;
    QStringList header;

    // list size must be even
    // first half of the array are the classes names, second half is the content for each class
    if (resList.size() % 2)  {
        qDebug() << "ResultsCreater::createContinuousResultsHTML() resList.size() % 2 == 1" + QString::number(resList.size() % 2);
        return;
    }

    // get classes names
    int i;
    for (i = 0; i < resList.size()/2; i++) {

        classesNames.push_back(QString(resList.at(i)).remove("\""));
    }

    // create html
    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(getTranslatedString("html-continuous-results")) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";

    html += "<div class=\"container\">\n";

    // results file header
    html += getResultsHTMLBodyHead(competitionName, competitionType, competitionDirector, competitionDirectorAvatar, competitionArbitr, competitionArbitrAvatar, competitionDate, competitionRound, competitionGroupName);

    header = QStringList() << ("html-continuous-results-order")
                             << ("html-continuous-results-name")
                             << ("html-results-ctnt-tg-shortcut")
                             << ("html-results-ctnt-tp-shortcut")
                             << ("html-results-ctnt-sg-shortcut")
                             << ("html-results-ctnt-altLimits-shortcut")
                             << ("html-results-ctnt-speedSec-shortcut")
                             << ("html-results-ctnt-altSec-shortcut")
                             << ("html-results-ctnt-spaceSec-shortcut")
                             << ("html-results-ctnt-markersOk-shortcut")
                             << ("html-results-ctnt-markersNok-shortcut")
                             << ("html-results-ctnt-markersFalse-shortcut")
                             << ("html-results-ctnt-photosOk-shortcut")
                             << ("html-results-ctnt-photosNok-shortcut")
                             << ("html-results-ctnt-photosFalse-shortcut")
                             << ("html-results-ctnt-landing-shortcut")
                             << ("html-results-ctnt-takeOfF-shortcut")
                             << ("html-results-ctnt-circling-shortcut")
                             << ("html-results-ctnt-opposite-shortcut")
                             << ("html-results-ctnt-otherPoints-shortcut")
                             << ("html-results-ctnt-otherPenalty-shortcut")
                             << ("html-results-ctnt-points-shortcut")
                             << ("html-results-ctnt-points1000-shortcut");

    // create legend, skip first two columns - order and name
    int skipCols = 2;
    QStringList headerLegend;
    for (int i = skipCols; i < header.size(); i++) {
        headerLegend.push_back(header.at(i) + "-legend");    // add legend suffix for translation
    }

    // tr legend
    headerLegend = getTranslatedStringList(headerLegend);
    header = getTranslatedStringList(header);

    // add legend into legend array and header row
    for (int i = skipCols; i < header.size(); i++) {

        QString headerItem = header.at(i);
        QString legendItem = headerLegend.at(i - skipCols);

        headerLegend[i - skipCols] = headerItem + " - " + legendItem;
        header[i] = getHeaderItemWithHelp(headerItem, legendItem);
    }

    // results for each category
    for (int j = 0; i < resList.size(); i++, j++) {

        categoryData = resList.at(i);

        // no results for this class
        if (categoryData == "[]") {
            continue;
        }

        int row = 1;

        // add category label
        html += getHTMLH3(classesNames.at(j));

        // add category results header
        rows.append(header);

        // get category results data
        QRegularExpression rx("\\\".*?\\\"", QRegularExpression::DotMatchesEverythingOption);
        QRegularExpressionMatchIterator it = rx.globalMatch(categoryData);
        QString category;
        dataRow.clear();

        int col = 0;

        // get ctnt results data
        while (it.hasNext()) {

            // add row number (order)
            if (dataRow.size() == 0) {

                dataRow.push_back(QString::number(row));
                row++;
            }

            // get data from string
            QRegularExpressionMatch match = it.next();
            if (match.hasMatch()) {

                if (col != 1) { // skip class
                    dataRow.push_back(QString(match.captured(0)).remove("\"") == "-1" ? "" : QString(match.captured(0)).remove("\""));
                }
                else {
                   category = QString(match.captured(0)).remove("\"") == "-1" ? "" : QString(match.captured(0)).remove("\"");
                }
            }

            // add data to table struct
            if (!(dataRow.size() % (recordSize + 1))) {

                // change name to href for evaluated crews
                if (dataRow[dataRow.size() - 2] != "") {

                    dataRow[1] = "<a href=\"" + dataRow.at(1) + "_" + category + ".html" + "\" class=\"hidden-print\">" + dataRow.at(1) + "</a><div class=\"visible-print-block\">" + dataRow.at(1) + "</div>";
                }

                rows.append(dataRow);
                dataRow.clear();
                col = 0;
            }
            else {
                col++;
            }
        }

        // echo table and spacer
        html += getHTMLHorizontalTable(rows, QVector<double>{0.5,2.1,0.8,0.8,0.8,1.0,1.0,1.0,1.0});
     }


    // add legend to html
    html += getPrintOnlyText(headerLegend.join(", "));

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filePath + ".html"), html.toUtf8());
}


void ResultsCreater::createStartListHTML(const QString &filename,
                                         const QStringList &cntList,
                                         const QString &competitionName,
                                         const int utc_offset_sec) {

    QJsonDocument jsonResponse;
    QJsonObject jsonObject;
    QString html = "";
    QVector<QStringList> rows;

    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(getTranslatedString("html-start-list")) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";

    html += "<div class=\"container\">\n";
/*
    html += "<div class=\"row\">\n";
    html += "   <div class=\"col-md-6\">\n";
    html +=         competitionName + "\n";
    html += "   </div>\n";
    html += "   <div class=\"col-md-6\">\n";
    html += "       <span class=\"pull-right\">" + QDate().currentDate().toString("dd.MM.yyyy") + "  " + QTime().currentTime().toString("hh:mm:ss") + "</span>\n";
    html += "   </div>\n";
    html += "</div>\n";
*/

    html += getHTMLH1(getTranslatedString("html-start-list-title"));

    // track points header row
    rows.append(getTranslatedStringList(QStringList() << ("html-startList-order")
                                                      << ("html-continuous-results-name")
                                                      << ("html-results-ctnt-category")
                                                      << ("html-results-ctnt-aircraft-registration")
                                                      << ("html-results-ctnt-speed")
                                                      << ("html-startList-startTimePrepTime")
                                                      << ("html-results-ctnt-startTime")
                                                      << ("html-startList-startTimeVBT")
                                                      << ("html-results-note")
                                                      ));


    for (int i = 0; i < cntList.size(); ++i) {

        jsonResponse = QJsonDocument::fromJson(cntList.at(i).toUtf8());
        jsonObject = jsonResponse.object();

        rows.append(QStringList() << QString::number(i + 1)
                                  << jsonObject["name"].toString()
                                  << jsonObject["category"].toString()
                                  << jsonObject["aircraft_registration"].toString()
                                  << QString::number(jsonObject["speed"].toInt())
                                  << QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimePrepTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")
                                  << "<b>" + QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss") + "</b>"
                                  << QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimeVBT"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")
                                  << ""                
                    );
    }

    html += getHTMLHorizontalTable(rows, QVector<double>{0.2/9.0, 3.1/9.0, 0.4/9.0, 0.3/9.0, 0.4/9.0, 0.7/9.0, 0.7/9.0, 0.7/9.0, 2.5/9.0});

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filename + ".html"), html.toUtf8());
}

void ResultsCreater::createContestantResultsHTML(const QString &filename,
                                                 const QString &cntJSON,
                                                 const QString &competitionName,
                                                 const QString &competitionType,
                                                 const QString &competitionDirector,
                                                 const QString &competitionDirectorAvatar,
                                                 const QStringList &competitionArbitr,
                                                 const QStringList &competitionArbitrAvatar,
                                                 const QString &competitionDate,
                                                 const QString &competitionRound,
                                                 const QString &competitionGroupName,
                                                 const int utc_offset_sec) {
    QString html = "";
    QStringList trackPointsList;
    QVector<QStringList> rows;

    QJsonDocument jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    QJsonObject jsonObject = jsonResponse.object();

    // no results
    if (jsonObject["name"].toString().length() == 1) return;

    int tg_time_measured = 0;
    bool sg_hit_measured = false;
    bool tp_hit_measured = false;
    //QString point_alt_type = "";
    int alt_measured = 0;
    double ctntSpeed = jsonObject["speed"].toDouble();

    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(jsonObject["name"].toString()) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";
    html += "<div class=\"container\">\n";

    // results file header
    html += getResultsHTMLBodyHead(competitionName, competitionType, competitionDirector, competitionDirectorAvatar, competitionArbitr, competitionArbitrAvatar, competitionDate, competitionRound, competitionGroupName);

    // results header

    html += "<div class=\"row\">";
    html += "   <div class=\"col-md-4\">";
    html += getHTMLH3(getTranslatedString("html-results-crew-title"));

    QStringList names = jsonObject["name"].toString().split(" – ");
    if (names.length() >= 1) {

        rows.append(QStringList() << getTranslatedString("html-results-ctnt-pilot") << ("<table>" + getUserTableRowRecordWithAvatar(jsonObject["pilotAvatarBase64"].toString(), names[0]) + "</table>"));
    }
    if (names.length() >= 2) {

        rows.append(QStringList() << getTranslatedString("html-results-ctnt-copilot") << ("<table>" + getUserTableRowRecordWithAvatar(jsonObject["copilotAvatarBase64"].toString(), names[1]) + "</table>"));
    }

    rows.append(QStringList() << getTranslatedString("html-results-ctnt-category") << jsonObject["category"].toString());
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-startTime") << QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss"));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-speed") << QString::number(jsonObject["speed"].toDouble()));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-aircraft-registration") << jsonObject["aircraft_registration"].toString());
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-aircraft-type") << jsonObject["aircraft_type"].toString());

    rows.append(QStringList() << getTranslatedString("html-results-ctnt-classify") << (jsonObject["classify"].toDouble() == 0 ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-score-points") << (jsonObject["scorePoints"].toDouble() < 0 ? "" : QString::number(jsonObject["scorePoints"].toDouble())));
    //rows.append(QStringList() << getTranslatedString("html-results-ctnt-score-points1000") << (jsonObject["scorePoints1000"].toDouble() < 0 ? "" : QString::number(jsonObject["scorePoints1000"].toDouble())));
    //rows.append(QStringList() << getTranslatedString("html-results-ctnt-class-order") << (jsonObject["classOrder"].toDouble() < 0 ? "" : QString::number(jsonObject["classOrder"].toDouble())));
    html += getHTMLVerticalTable(rows);

    html += "   </div>";
    html += "   <div class=\"col-md-8\">";

    // trajectory
    QUrl trajectoryImgUrl = QUrl(filename + ".png");
    html += file.file_exists(trajectoryImgUrl) ? getHTMLResponsiveImage(getImageBase64(trajectoryImgUrl)) : "";

    html += "   </div>";
    html += "</div>";

    // manual values
    html += getHTMLH3(getTranslatedString("html-results-manual-values"));
    rows.append(QStringList() << getBoldText(getTranslatedString("html-results-point-type")) << getBoldText(getTranslatedString("html-results-inserted-value")) << getBoldText(getTranslatedString("html-results-score")));

    // markers
    rows.append(QStringList() << getTranslatedString("html-results-markers") + " " + getItalicGreyText(getTranslatedString("html-results-markers-legend")) <<
                QString::number(jsonObject["markersOk"].toDouble()) + " / " +
                QString::number(jsonObject["markersNok"].toDouble()) + " / " +
                QString::number(jsonObject["markersFalse"].toDouble()) <<
                QString::number(jsonObject["markersScore"].toDouble()));
    // photos
    rows.append(QStringList() << getTranslatedString("html-results-photos") + " " + getItalicGreyText(getTranslatedString("html-results-markers-legend")) <<
                QString::number(jsonObject["photosOk"].toDouble()) + " / " +
                QString::number(jsonObject["photosNok"].toDouble()) + " / " +
                QString::number(jsonObject["photosFalse"].toDouble()) <<
                QString::number(jsonObject["photosScore"].toDouble()));
    // take off
    rows.append(QStringList() << getTranslatedString("html-results-take-off") + " " + getItalicGreyText(getTranslatedString("html-results-take-off-legend")) <<
                QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss") + " / " +
                (jsonObject["startTimeMeasured"].toString() == "" ? " - " : QTime(0,0,0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimeMeasured"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")) + " / " +
                (jsonObject["startTimeDifference"].toString() == "" ? " - " : jsonObject["startTimeDifference"].toString()) <<
                QString::number(jsonObject["startTimeScore"].toDouble()));
    // landing accurancy
    rows.append(QStringList() << getTranslatedString("html-results-landing-accurancy") + " " + getItalicGreyText(getTranslatedString("html-results-point-legend")) <<
                QString::number(jsonObject["landingScore"].toDouble()) <<
                QString::number(jsonObject["landingScore"].toDouble()));
    // circling
    rows.append(QStringList() << getTranslatedString("html-results-circling") + " " + getItalicGreyText(getTranslatedString("html-results-count-legend")) <<
                QString::number(jsonObject["circlingCount"].toDouble()) <<
                QString::number(jsonObject["circlingScore"].toDouble()));
    // opposite dir flight
    rows.append(QStringList() << getTranslatedString("html-results-opposite") + " " + getItalicGreyText(getTranslatedString("html-results-count-legend")) <<
                QString::number(jsonObject["oppositeCount"].toDouble()) <<
                QString::number(jsonObject["oppositeScore"].toDouble()));
    // other points
    rows.append(QStringList() << getTranslatedString("html-results-other-points") + " " + getItalicGreyText(getTranslatedString("html-results-point-legend")) <<
                QString::number(jsonObject["otherPoints"].toDouble()) <<
                QString::number(jsonObject["otherPoints"].toDouble()));
    // other penalty
    rows.append(QStringList() << getTranslatedString("html-results-other-penalty") + " " + getItalicGreyText(getTranslatedString("html-results-point-legend")) <<
                QString::number(jsonObject["otherPenalty"].toDouble()) <<
                QString::number(jsonObject["otherPenalty"].toDouble() != 0 ? jsonObject["otherPenalty"].toDouble() * -1 : 0));
    // note
    rows.append(QStringList() << getTranslatedString("html-results-note") <<
                jsonObject["pointNote"].toString() <<
                "-");

    html += getHTMLVerticalTable(rows);

    // track points
    if(jsonObject["wptScoreDetails"].toString() != "") {

        trackPointsList = jsonObject["wptScoreDetails"].toString().split("; ");

        html += getHTMLH3(getTranslatedString("html-results-track-points"));

        // track points header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-point-name")
                                                          << ("html-results-point-type")
                                                          << ("html-results-point-distance")
                                                          << ("html-results-point-tg-expected")
                                                          << ("html-results-point-tg-measured")
                                                          //<< ("html-results-point-tg-difference")
                                                          //<< ("html-results-tg-score")
                                                          << ("html-results-point-tp-hit")
                                                          //<< ("html-results-tp-score")
                                                          << ("html-results-point-sg-hit")
                                                          //<< ("html-results-sg-score")
                                                          << ("html-results-point-alt-limit")
                                                          //<< ("html-results-point-alt-min")
                                                          //<< ("html-results-point-alt-max")
                                                          << ("html-results-point-alt-measured")
                                                          //<< ("html-results-alt-score")
                                                          << ("html-results-score")
                                                          ));

        // track points content
        for (int k = 0; k < trackPointsList.size(); ++k) {
            jsonResponse = QJsonDocument::fromJson(trackPointsList.at(k).toUtf8());
            jsonObject = jsonResponse.object();

            tg_time_measured = jsonObject["tg_time_manual"].toDouble() < 0 ? jsonObject["tg_time_measured"].toDouble() : jsonObject["tg_time_manual"].toDouble();
            sg_hit_measured = jsonObject["sg_hit_manual"].toDouble() < 0 ? jsonObject["sg_hit_measured"].toBool() : jsonObject["sg_hit_manual"].toBool();
            tp_hit_measured = jsonObject["tp_hit_manual"].toDouble() < 0 ? jsonObject["tp_hit_measured"].toBool() : jsonObject["tp_hit_manual"].toBool();
            alt_measured = jsonObject["alt_manual"].toDouble() < 0 ? jsonObject["alt_measured"].toDouble() : jsonObject["alt_manual"].toDouble();

            //check point type
            bool isTG = (int(jsonObject["type"].toDouble()) & 2) == 2;
            bool isTP = (int(jsonObject["type"].toDouble()) & 1) == 1;
            bool isSG = (int(jsonObject["type"].toDouble()) & 4) == 4;
            bool altLimit = ((jsonObject["alt_min"].toDouble() > 0) || (jsonObject["alt_max"].toDouble() > 0));

            rows.append(QStringList() << jsonObject["title"].toString()
                                      << pointFlagToString(jsonObject["type"].toDouble())
                                      << QString::number(jsonObject["distance_from_vbt"].toDouble() / 1000, 'f', 2)

                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + QTime(0,0,0).addSecs(addUtcToTime(jsonObject["tg_time_calculated"].toDouble(), utc_offset_sec)).toString("HH:mm:ss") + (isTG ? "" : getFontColorEndTag())
                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + QTime(0,0,0).addSecs(addUtcToTime(tg_time_measured, utc_offset_sec)).toString() + (isTG ? "" : getFontColorEndTag())
                                      << (isTP ? "" : getFontColorStartTag("#bfbfbf")) + (tp_hit_measured ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")) + (isTP ? "" : getFontColorEndTag())
                                      << (isSG ? "" : getFontColorStartTag("#bfbfbf")) + (sg_hit_measured ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")) + (isSG ? "" : getFontColorEndTag())
                                      << ((jsonObject["alt_min"].toDouble() < 0 ? "GND" : QString::number(jsonObject["alt_min"].toDouble())) + " - " + (jsonObject["alt_max"].toDouble() < 0 ? "FL 660" : QString::number(jsonObject["alt_max"].toDouble())))
                                      << (alt_measured < 0 ? "" : QString::number(alt_measured))

                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["tg_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["tg_score"].toDouble())) + (isTG ? "" : getFontColorEndTag())
                                      << (isTP ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["tp_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["tp_score"].toDouble())) + (isTP ? "" : getFontColorEndTag())
                                      << (isSG ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["sg_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["sg_score"].toDouble())) + (isSG ? "" : getFontColorEndTag())
                                      << (altLimit ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["alt_score"].toDouble() == -1 ? "0" : QString::number(jsonObject["alt_score"].toDouble())) + (altLimit ? "" : getFontColorStartTag("#bfbfbf"))
                        );
        }
        html += getHTMLHorizontalTable(rows);

    }

    // speed sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    QRegularExpression rx("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    QRegularExpressionMatchIterator i = rx.globalMatch(jsonObject["speedSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-speed-sections"));

        // speed sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-speed-sec-start-point")
                                                          << ("html-results-speed-sec-end-point")
                                                          << ("html-results-speed-sec-expected")
                                                          << ("html-results-speed-sec-measured")
                                                          << ("html-results-score")
                                                          ));


        // speed sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                 jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                 jsonObject = jsonResponse.object();

                  rows.append(QStringList() << jsonObject["startPointName"].toString()
                                            << jsonObject["endPointName"].toString()
                                            << QString::number(ctntSpeed)
                                            << (jsonObject["manualSpeed"].toDouble() < 0 ? QString::number(jsonObject["calculatedSpeed"].toDouble()) : QString::number(jsonObject["manualSpeed"].toDouble()))
                                            << QString::number(jsonObject["speedSecScore"].toDouble())
                                            );
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double>{1.0/7.0, 1.0/7.0, 1.0/7.0, 1.0/7.0, 1.0/7.0, 2.0/7.0});
    }

    // altitude sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    rx = QRegularExpression("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    i = rx.globalMatch(jsonObject["altitudeSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-altitude-sections"));

        // alt sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-alt-sec-start-point")
                                                          << ("html-results-alt-sec-end-point")
                                                          << ("html-results-alt-sec-min-count")
                                                          << ("html-results-alt-sec-min-time")
                                                          << ("html-results-alt-sec-max-count")
                                                          << ("html-results-alt-sec-max-time")
                                                          << ("html-results-score")
                                                          ));
        // alt sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                 jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                 jsonObject = jsonResponse.object();

                  rows.append(QStringList() << jsonObject["startPointName"].toString()
                                            << jsonObject["endPointName"].toString()
                                            << (jsonObject["manualAltMinEntriesCount"].toDouble() < 0 ? QString::number(jsonObject["altMinEntriesCount"].toDouble()) : QString::number(jsonObject["manualAltMinEntriesCount"].toDouble()))
                                            << (jsonObject["manualAltMinEntriesCount"].toDouble() < 0 ? (jsonObject["manualAltMinEntriesTime"].toDouble() < 0 ? QTime(0,0,0).addSecs(jsonObject["altMinEntriesTime"].toDouble()).toString("hh:mm:ss") : QTime(0,0,0).addSecs(jsonObject["manualAltMinEntriesTime"].toDouble()).toString("hh:mm:ss")) : "")
                                            << (jsonObject["manualAltMaxEntriesCount"].toDouble() < 0 ? QString::number(jsonObject["altMaxEntriesCount"].toDouble()) : QString::number(jsonObject["manualAltMaxEntriesCount"].toDouble()))
                                            << (jsonObject["manualAltMaxEntriesCount"].toDouble() < 0 ? (jsonObject["manualAltMaxEntriesTime"].toDouble() < 0 ? QTime(0,0,0).addSecs(jsonObject["altMaxEntriesTime"].toDouble()).toString("hh:mm:ss") : QTime(0,0,0).addSecs(jsonObject["manualAltMaxEntriesTime"].toDouble()).toString("hh:mm:ss")) : "")
                                            << QString::number(jsonObject["altSecScore"].toDouble())
                                            );
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double>{1, 1, 1, 1, 1, 1, 1});
    }

    // space sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    rx = QRegularExpression("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    i = rx.globalMatch(jsonObject["spaceSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-space-sections"));

        // alt sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-space-sec-start-point")
                                                          << ("html-results-space-sec-end-point")
                                                          << ("html-results-space-sec-entries-count")
                                                          << ("html-results-space-sec-entries-time")
                                                          << ("html-results-score")
                                                          ));
        // alt sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                 jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                 jsonObject = jsonResponse.object();

                  rows.append(QStringList() << jsonObject["startPointName"].toString()
                                            << jsonObject["endPointName"].toString()
                                            << (jsonObject["manualEntries_out"].toDouble() < 0 ? QString::number(jsonObject["entries_out"].toDouble()) : QString::number(jsonObject["manualEntries_out"].toDouble()))
                                            << (jsonObject["manualEntries_out"].toDouble() < 0 ? (jsonObject["manualTime_spent_out"].toDouble() < 0 ? QTime(0,0,0).addSecs(jsonObject["time_spent_out"].toDouble()).toString("hh:mm:ss") : QTime(0,0,0).addSecs(jsonObject["manualTime_spent_out"].toDouble()).toString("hh:mm:ss")) : "")
                                            << QString::number(jsonObject["spaceSecScore"].toDouble())
                                            );
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double>{1.0/7.0, 1.0/7.0, 1.0/7.0, 1.0/7.0, 3.0/7.0});
    }

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filename + ".html"), html.toUtf8());
}

const inline QString ResultsCreater::getFontColorStartTag(QString color) {

    return "<span style=\"color:" + color + "\">";
}

const inline QString ResultsCreater::getFontColorEndTag() {

    return "</span>";
}

const inline QString ResultsCreater::getBoldText(const QString text) {

    return "<b>" + text + "</b>";
}

const inline QString ResultsCreater::getItalicText(const QString text) {

    return "<i>" + text + "</i>";
}

const QString ResultsCreater::getItalicGreyText(const QString text) {

    return getItalicText(getFontColorStartTag("grey") + text + getFontColorEndTag());
}



const QString ResultsCreater::getResultsHTMLBodyHead(const QString &competitionName,
                                                     const QString &competitionType,
                                                     const QString &competitionDirector,
                                                     const QString &competitionDirectorAvatar,
                                                     const QStringList &competitionArbitr,
                                                     const QStringList &competitionArbitrAvatar,
                                                     const QString &competitionDate,
                                                     const QString &competitionRound,
                                                     const QString &competitionGroupName) {

    QString html = "";
    QVector<QStringList> rows;

    html += getHTMLH1(competitionName);
    html += "<div class=\"row\">\n";
    html += "   <div class=\"col-xs-4\">\n";

    if (competitionGroupName != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-group-name") << competitionGroupName);

    if (competitionRound != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-round") << competitionRound);

    if (competitionType != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-type") << competitionType);

    if (competitionDate != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-date") << competitionDate);

    html += getHTMLVerticalTable(rows);
    html += "   </div>\n";

    html += "   <div class=\"col-xs-4\">\n";

    if (competitionDirector != "") {
        rows.append(QStringList() << getTranslatedString("html-results-competition-director") << ("<table>" + getUserTableRowRecordWithAvatar(competitionDirectorAvatar, competitionDirector) + "</table>"));
    }


    // push each arbitr with avatar into table
    for(int i = 0; i < competitionArbitr.size(); i++) {

        QString avatar = i < competitionArbitrAvatar.size() ? competitionArbitrAvatar.at(i) : BLANK_USER_BASE64;
        QString label = (i == 0 ? getTranslatedString("html-results-competition-arbitr") : "");

        if (competitionArbitr.at(i) != "") {
            rows.append(QStringList() << label << ("<table>" + getUserTableRowRecordWithAvatar(avatar, competitionArbitr.at(i)) + "</table>"));
        }
    }

    html += getHTMLVerticalTable(rows);
    html += "   </div>\n";

    html += "   <div class=\"col-xs-4\">\n";
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">\n";
    html += getHTMLRoundedImage(ResultsCreater::LAA_LOG_BASE64, "50px", "auto");
    html += getHTMLRoundedImage(ResultsCreater::FIT_LOG_BASE64, "50px", "auto");
    html += "           </span>\n";
    html += "       </div>\n";
    html += getHTMLSpace(5);
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">" + QDate().currentDate().toString("yyyy-MM-dd ") + "</span>\n";
    html += "       </div>\n";
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">" + QTime().currentTime().toString("hh:mm:ss ") + "</span>\n";
    html += "       </div>\n";
    html += "   </div>\n";
    html += "</div>\n";

    return html;

}

const QString ResultsCreater::getHTMLHorizontalTable(QVector<QStringList> &rows, const QVector<double> &preferedColumnsWidth) {

    QString htmlTable = "";
    QStringList rowItem;
    QString columnWidthString = "";
    QString headerLastColColSpan = "";

    // calc colspan for header last column
    if ((rows.size() > 1) && (rows.at(0).size() < rows.at(1).size())) {
        headerLastColColSpan = " colspan=\"" + QString::number(rows.at(1).size() - rows.at(0).size() + 1) + "\"";
    }

    htmlTable += getHTMLStartTableTag() + "\n";

    for (int i = 0; i < rows.size(); ++i) {

        rowItem = QStringList(rows.at(i));

        // table content
        htmlTable += "<tr>\n";

        for (int j = 0; j < rowItem.size(); ++j) {

            if (preferedColumnsWidth.size() == rowItem.size()) {

                columnWidthString = " style=\"width: " + QString::number(preferedColumnsWidth.at(j) * 100/rowItem.size()) + "%\"";
            }

            if (i == 0)
                htmlTable += "   <th" + (columnWidthString != "" ? columnWidthString : (j == (rowItem.size()-1) ? headerLastColColSpan : "")) + ">" + rowItem.at(j) + "</th>\n";
            else
                htmlTable += "   <td" + columnWidthString + ">" + rowItem.at(j) + "</td>\n";

        }

        htmlTable += "</tr>\n";
    }

    htmlTable += getHTMLEndTableTag() + "\n";

    rows.clear();

    return htmlTable;
}

const QString ResultsCreater::getHTMLVerticalTable(QVector<QStringList> &rows) {

    QString htmlTable = "";
    QStringList rowItem;

    htmlTable += getHTMLStartTableTag() + "\n";

    for (int i = 0; i < rows.size(); ++i) {

        rowItem = QStringList(rows.at(i));

        // table content
        htmlTable += "<tr>\n";

        for (int j = 0; j < rowItem.size(); ++j) {

            htmlTable += "   <td>" + rowItem.at(j) + "</td>\n";

        }

        htmlTable += "</tr>\n";
    }

    htmlTable += getHTMLEndTableTag() + "\n";

    rows.clear();

    return htmlTable;
}

const inline QString ResultsCreater::getHTMLH1(const QString text) {

    return "<h1>" + text + "</h1>";
}

const inline QString ResultsCreater::getHTMLH2(const QString text) {

    return "<h2>" + text + "</h2>";
}

const inline QString ResultsCreater::getHTMLH3(const QString text) {

    return "<h3>" + text + "</h3>";
}

const inline QString ResultsCreater::getHTMLHeader(const QString title) {

    return
        "<head>\n"
          "<meta charset=\"UTF-8\">\n"
          "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
          "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" />\n"
          "<meta name=\"description\" content=\"\">\n"
          "<meta name=\"author\" content=\"Letecká Amaterská Asociace ČR\">\n"
          "<meta property=\"og:title\" content=\"" + title + "\"/>\n"

          "<title>" + title + "</title>\n"

          "<!-- Bootstrap core CSS -->\n"
          "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">\n"
          "<link href=\"../bin/viewer+/x64/www/css/style.css\" rel=\"stylesheet\">\n"
          "<link href=\"../bin/viewer+/x86/www/css/style.css\" rel=\"stylesheet\">\n"


        "<style>"
        "@media print {"
          ".table-startlist > tbody > tr > td, .table-startlist > tbody > tr > th, .table-startlist > tfoot > tr > td, .table-startlist > tfoot > tr > th, .table-startlist > thead > tr > td, .table-startlist > thead > tr > th"
          "{"
            "padding: 3px;"
          "}"
        "}"
        "</style>"

        "</head>\n"
        "\n"
    ;
}

const inline QString ResultsCreater::getHTMLBodyScript() {

    return
            "<!-- Placed at the end of the document so the pages load faster -->\n"

            "<script>\n"
            "<type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js\">\n"
            "<type=\"text/javascript\" src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\">\n"
            "<type=\"text/javascript\" src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/selectize.min.js\">\n"

            "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/jquery.min.js\">\n"
            "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/bootstrap.min.js\">\n"
            "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/selectize.min.js\">\n"

            "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/jquery.min.js\">\n"
            "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/bootstrap.min.js\">\n"
            "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/selectize.min.js\">\n"
            "</script>\n"

            "<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->\n"
            "\n"
    ;
}

const inline QString ResultsCreater::getImageBase64(const QUrl &image) {

    return QString(file.read(image).toBase64());
}

const inline QString ResultsCreater::getHTMLResponsiveImage(const QString &base64) {

    return "<img class=\"img-responsive\" src=\"data:image/png;base64," + base64 + "\">";
}

const inline QString ResultsCreater::getHTMLRoundedImage(const QString &base64, const QString heightPx, const QString widthPx) {

    return "<img style=\"height: " + heightPx + "; width: " + widthPx + ";\" class=\"img-rounded\" src=\"data:image/png;base64," + base64 + "\">";
}

const inline QString ResultsCreater::getHTMLStartTableTag() {

    return "<table class=\"table table-striped table-startlist\">";
}

const inline QString ResultsCreater::getHTMLEndTableTag() {

    return "</table>";
}

const inline QString ResultsCreater::getHTMLSpace(const int spaceInPx) {

    return "<div class=\"col-xs-12\" style=\"height:" + QString::number(spaceInPx) + "px;\"></div>";
}

const inline QString ResultsCreater::getUserTableRowRecordWithAvatar(const QString &avatarBase64,
                                                                     const QString &name) {

    QString avatar = avatarBase64 == "" ? BLANK_USER_BASE64 : avatarBase64;

    return "<tr><td style=\"width:50px; height:42px\">" + getHTMLRoundedImage(avatar, "40px", "40px") + "</td><td>" + name + "</td></tr>";
}

const inline QString ResultsCreater::getHeaderItemWithHelp(const QString shortcut, const QString help) {

    return "<abbr class=\"hidden-print\" title=\"" + help + "\">" + shortcut + "</abbr><span class=\"visible-print-inline\">" + shortcut + "</span>";
}

const inline QString ResultsCreater::getPrintOnlyText(const QString text) {

    return "<span class=\"visible-print-inline\">" + text + "</span>";
}


const QStringList ResultsCreater::getTranslatedStringList(QStringList sourceList) {

    // load qml component, used for localization
    QVariant returnedValue;
    QStringList translatedList;
    QQmlEngine engine;
    QQmlComponent component(&engine, QStringLiteral("qml/viewer/MyTranslator.qml"));
    QObject *object = component.create();

    for (int i = 0; i < sourceList.length(); i++) {

        QMetaObject::invokeMethod(object, "myTranslate", Q_RETURN_ARG(QVariant, returnedValue), Q_ARG(QVariant, sourceList.at(i)));
        translatedList.push_back(returnedValue.toString());
    }

    delete object;

    return translatedList;
}



const QString ResultsCreater::getTranslatedString(QString sourceString) {

    return getTranslatedStringList(QStringList() << sourceString).join("");
}


const int ResultsCreater::timeToSec(const QTime &time) {

    return QTime(0, 0, 0).secsTo(time);
}

const int ResultsCreater::addUtcToTime(const int timeSec, const int utcOffsetSec) {

    if (timeSec <= 0) {
        return 0;
    }
    else {
        return timeSec + utcOffsetSec;
    }
}

const int ResultsCreater::addUtcToTime(const QTime &time, const int utcOffsetSec) {

    int timeSec = timeToSec(time);

    if (timeSec <= 0) {
        return 0;
    }
    else {
        return timeSec + utcOffsetSec;
    }
}


const int ResultsCreater::subUtcFromTime(const int timeSec, const int utcOffsetSec) {

    if (timeSec <= 0) {
        return 0;
    }
    else {
        return timeSec - utcOffsetSec;
    }
}

const int ResultsCreater::subUtcFromTime(const QTime &time, const int utcOffsetSec) {

    int timeSec = timeToSec(time);

    if (timeSec <= 0) {
        return 0;
    }
    else {
        return timeSec - utcOffsetSec;
    }
}

QString ResultsCreater::pointFlagToString(const unsigned int f) {

    // original functions was in function.js and ScoreListTableDelegate.qml

    QStringList str;

    QVector<bool> arr;
    unsigned int nMask = f | 0x10000;

    // nMask must be between -2147483648 and 2147483647
    if (nMask > 0x7fffffff) {
        return "ERR - invalid mask value1";
    }
    for (int nShifted = nMask; nShifted; ) {

        arr.push_back(bool(nShifted & 1));
        nShifted >>= 1;
    }

    if (arr[0]) {
        // "TP"
        str.push_back("track-list-delegate-ob-short");
    }
    if (arr[1]) {
        // "TG"
        str.push_back("track-list-delegate-tg-short");
    }
    if (arr[2]) {
        // "SG"
        str.push_back("track-list-delegate-sg-short");
    }
    if (arr[3]){
        // "ALT_MIN"
        str.push_back("track-list-delegate-alt_min-short");
    }
    if (arr[4]) {
        // "ALT_MAX"
        str.push_back("track-list-delegate-alt_max-short");
    }
    if (arr[5]) {
        // "SPD_MIN"
        str.push_back("track-list-delegate-speed_min-short");
    }
    if (arr[6]) {
        // "SPD_MAX"
        str.push_back("track-list-delegate-speed_max-short");
    }
    if (arr[7]) {
        // "sss"
        str.push_back("track-list-delegate-section_speed_start-short");
    }
    if (arr[8]) {
        // "sse"
        str.push_back("track-list-delegate-section_speed_end-short");
    }
    if (arr[9]) {
        // "sas"
        str.push_back("track-list-delegate-section_alt_start-short");
    }
    if (arr[10]) {
        // "sae"
        str.push_back("track-list-delegate-section_alt_end-short");
    }
    if (arr[11]) {
        // "sws"
        str.push_back("track-list-delegate-section_space_start-short");
    }
    if (arr[12]) {
        // "swe"
        str.push_back("track-list-delegate-section_space_end-short");
    }
    if (arr[13]) {
        // "sec_tp"
        str.push_back("track-list-delegate-secret-turn-point-short");
    }
    if (arr[14]) {
        // "sec_tg"
        str.push_back("track-list-delegate-secret-time-gate-short");
    }
    if (arr[15]) {
        // "sec_sg"
        str.push_back("track-list-delegate-secret-space-gate-short");
    }

    return getTranslatedStringList(str).join(", ");
}
