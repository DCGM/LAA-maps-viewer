#ifndef UPLOADER_H
#define UPLOADER_H

#include <QHttpMultiPart>
#include <QHttpPart>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QtCore>
#include <QtNetwork>

class Uploader : public QObject {
    Q_OBJECT

public:
    explicit Uploader(QObject* parent = 0);
    Q_INVOKABLE void sendFile(QUrl api_url, QString fileName, int compId, QString api_key);
    Q_INVOKABLE void abortLastReply();
    Q_PROPERTY(QString response READ response())
    Q_PROPERTY(int errorCode READ errorCode())
    Q_PROPERTY(QString errorMessage READ errorMessage())

    int errorCode() { return m_lastErrorCode; }
    QString errorMessage() { return m_lastError; }
    QString response() { return m_response; }

public slots:

    void finished(QNetworkReply* reply);
    void slotError(QNetworkReply::NetworkError);

signals:
    void uploadFinished();
    void errorOccured();

private:
    QHttpPart part_parameter(QString key, QString value);
    QNetworkAccessManager* manager;

    QString m_lastError;
    int m_lastErrorCode;
    QString m_response;

    QNetworkReply* lastReply;
};

#endif // UPLOADER_H
