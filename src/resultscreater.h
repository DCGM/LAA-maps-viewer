#ifndef RESULTSCREATER_H
#define RESULTSCREATER_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QString>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonDocument>
#include <QTime>
#include <QDate>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>

#include <QQuickView>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QFile>

#include "filereader.h"

class ResultsCreater : public QObject
{
    Q_OBJECT

public:

    explicit ResultsCreater(QObject *parent = 0);

    Q_INVOKABLE void createContestantResultsHTML(const QString &filename,
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
                                                 const int utc_offset_sec);

    Q_INVOKABLE void createContinuousResultsHTML(const QString &filePath,
                                                 const QStringList &res,
                                                 const int recordSize,
                                                 const QString &competitionName,
                                                 const QString &competitionType,
                                                 const QString &competitionDirector,
                                                 const QString &competitionDirectorAvatar,
                                                 const QStringList &competitionArbitr,
                                                 const QStringList &competitionArbitrAvatar,
                                                 const QString &competitionDate,
                                                 const QString &competitionRound,
                                                 const QString &competitionGroupName);

    Q_INVOKABLE QString pointFlagToString(const unsigned int f);

    Q_INVOKABLE void createStartListHTML(const QString &filename,
                                         const QStringList &cntList,
                                         const QString &competitionName,
                                         const int utc_offset_sec);



private:

    FileReader file;


    static const QString LAA_LOG_BASE64;
    static const QString FIT_LOG_BASE64;
    static const QString BLANK_USER_BASE64;

    const inline QString getHTMLHeader(const QString title);
    const inline QString getHTMLBodyScript();
    const inline QString getImageBase64(const QUrl &image);
    const inline QString getHTMLResponsiveImage(const QString &base64);
    const inline QString getHTMLRoundedImage(const QString &base64, const QString heightPx, const QString widthPx);
    const inline QString getHTMLStartTableTag();
    const inline QString getHTMLEndTableTag();
    const inline QString getBoldText(const QString text);
    const inline QString getItalicText(const QString text);
    const QString getItalicGreyText(const QString text);
    const inline QString getHTMLSpace(const int spaceInPx);
    const QString getHTMLHorizontalTable(QVector<QStringList> &rows, const QVector<double> &preferedColumnsWidth = QVector<double>());
    const QString getHTMLVerticalTable(QVector<QStringList> &rows);

    const inline QString getHTMLH1(const QString text);
    const inline QString getHTMLH2(const QString text);
    const inline QString getHTMLH3(const QString text);
    const QString getResultsHTMLBodyHead(const QString &competitionName,
                                         const QString &competitionType,
                                         const QString &competitionDirector,
                                         const QString &competitionDirectorAvatar,
                                         const QStringList &competitionArbitr,
                                         const QStringList &competitionArbitrAvatar,
                                         const QString &competitionDate,
                                         const QString &competitionRound,
                                         const QString &competitionGroupName);

    const inline QString getUserTableRowRecordWithAvatar(const QString &avatarBase64, const QString &name);
    const QStringList getTranslatedStringList(QStringList sourceList);
    const QString getTranslatedString(QString sourceString);

    int addUtcToTime(const int timeSec, const int utcOffsetSec);
    int addUtcToTime(const QTime &time, const int utcOffsetSec);
    int subUtcFromTime(const int timeSec, const int utcOffsetSec);
    int subUtcFromTime(const QTime &time, const int utcOffsetSec);

    int timeToSec(const QTime &time);

    const inline QString getFontColorStartTag(QString color);
    const inline QString getFontColorEndTag();
    const inline QString getHeaderItemWithHelp(const QString shortcut, const QString help);
    const inline QString getPrintOnlyText(const QString text);
};



#endif // RESULTSCREATER_H
