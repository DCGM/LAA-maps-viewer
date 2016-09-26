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
#include <QTextDocument>
#include <QPrinter>

#include "filereader.h"

class ResultsCreater : public QObject
{
    Q_OBJECT

public:

    explicit ResultsCreater(QObject *parent = 0);

    Q_INVOKABLE void createContestantResultsHTML(const QString &fileName,
                                                 const QString &cntJSON,
                                                 const QString &competitionName,
                                                 const QString &competitionType,
                                                 const QString &competitionDirector,
                                                 const QString &competitionDirectorAvatar,
                                                 const QStringList &competitionArbitr,
                                                 const QStringList &competitionArbitrAvatar,
                                                 const QString &competitionDate);

    Q_INVOKABLE void createContinuousResultsHTML(const QString &filePath,
                                                 const QStringList &res,
                                                 const int recordSize,
                                                 const QString &competitionName,
                                                 const QString &competitionType,
                                                 const QString &competitionDirector,
                                                 const QString &competitionDirectorAvatar,
                                                 const QStringList &competitionArbitr,
                                                 const QStringList &competitionArbitrAvatar,
                                                 const QString &competitionDate);

    Q_INVOKABLE QString pointFlagToString(const unsigned int f);



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
    const inline QString getHTMLSpace(const int spaceInPx);
    const QString getHTMLHorizontalTable(QVector<QStringList> &rows, const QVector<double> &preferedColumnsWidth = QVector<double>());
    const QString getHTMLVerticalTable(QVector<QStringList> &rows, const int headerPercentWidth);

    const inline QString getHTMLH1(const QString text);
    const inline QString getHTMLH2(const QString text);
    const inline QString getHTMLH3(const QString text);
    const QString getResultsHTMLBodyHead(const QString &competitionName,
                                         const QString &competitionType,
                                         const QString &competitionDirector,
                                         const QString &competitionDirectorAvatar,
                                         const QStringList &competitionArbitr,
                                         const QStringList &competitionArbitrAvatar,
                                         const QString &competitionDate);

    const inline QString getUserTableRowRecordWithAvatar(const QString &avatarBase64, const QString &name);
    const QStringList getTranslatedStringList(QStringList sourceList);
    const QString getTranslatedString(QString sourceString);

    const inline QString getFontColorStartTag(QString color);
    const inline QString getFontColorEndTag();
};



#endif // RESULTSCREATER_H
