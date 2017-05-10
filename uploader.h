#ifndef UPLOADER_H
#define UPLOADER_H

#include <QtCore>
#include <QObject>
#include <QNetworkAccessManager>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QNetworkReply>
#include <QtNetwork>


class Uploader : public QObject
{
    Q_OBJECT

public:
    explicit Uploader(QObject *parent = 0);
    Q_INVOKABLE void sendFile(QUrl api_url, QString fileName, int compId, QString api_key);

public slots:

    void finished(QNetworkReply *reply);
    void slotError(QNetworkReply::NetworkError);

private:
    QHttpPart part_parameter(QString key, QString value);
    QNetworkAccessManager* manager;

    QString m_lastError;
    QString m_response;
};

#endif // UPLOADER_H
