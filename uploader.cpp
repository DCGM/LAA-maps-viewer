#include "uploader.h"
#include <QtCore>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QHttpPart>

Uploader::Uploader(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    manager->setRedirectPolicy(QNetworkRequest::SameOriginRedirectPolicy);
    connect (manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));
}

QHttpPart Uploader::part_parameter(QString key, QString value) {
    QHttpPart part;
    part.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"" + key + "\""));
    part.setBody(value.toLatin1());
    return part;
}

void Uploader::sendFile(QUrl api_url, QString fileName, int compId, QString api_key) {

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart filePart;
    QFileInfo fileinfo = QFileInfo(fileName);

    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/octet-stream"));
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"files\"; filename=\"" + fileinfo.fileName() + "\""));
    QFile *file = new QFile(fileName);
    file->open(QIODevice::ReadOnly);
    filePart.setBodyDevice(file);
    file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart

    multiPart->append(filePart);

    multiPart->append(part_parameter("id", QString("%1").arg(compId)));
    multiPart->append(part_parameter("api_key", api_key));

    QUrl url(api_url);
    QNetworkRequest request(url);

    QNetworkReply *reply = manager->post(request, multiPart);
    lastReply = reply;
    reply->ignoreSslErrors();

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(slotError(QNetworkReply::NetworkError)));

}


void Uploader::abortLastReply() {
    if (lastReply != NULL) {
        lastReply->abort();
    }
}

void Uploader::finished(QNetworkReply *reply) {
    lastReply = NULL;
    m_lastErrorCode = reply->error();

    if (m_lastErrorCode != QNetworkReply::NoError) {
        qDebug() << reply->errorString();
    }

    m_response = reply->readAll();
    emit uploadFinished();
}


void Uploader::slotError(QNetworkReply::NetworkError e) {

    qDebug() << "QNetworkReply::NetworkError e = " << e;
    m_lastErrorCode = e;
    switch(e) {
    case QNetworkReply::NoError: m_lastError = tr(""); break;
    case QNetworkReply::ConnectionRefusedError: m_lastError = tr("Connection Refused"); break;
    case QNetworkReply::RemoteHostClosedError: m_lastError = tr("Remote Host Closed"); break;
    case QNetworkReply::HostNotFoundError: m_lastError = tr("Host Not Found"); break;
    case QNetworkReply::TimeoutError: m_lastError = tr("Timeout"); break;
    case QNetworkReply::OperationCanceledError: m_lastError = tr("Operation Canceled"); break;
    case QNetworkReply::SslHandshakeFailedError: m_lastError = tr("Ssl Handshake Failed"); break;
    case QNetworkReply::TemporaryNetworkFailureError: m_lastError = tr("Temporary Network Failure"); break;
    case QNetworkReply::ProxyConnectionRefusedError: m_lastError = tr("Proxy Connection Refused"); break;
    case QNetworkReply::ProxyConnectionClosedError: m_lastError = tr("Proxy Connection Closed"); break;
    case QNetworkReply::ProxyNotFoundError: m_lastError = tr("Proxy Not Found"); break;
    case QNetworkReply::ProxyTimeoutError: m_lastError = tr("Proxy Timeout"); break;
    case QNetworkReply::ProxyAuthenticationRequiredError: m_lastError = tr("Proxy Authentication Required"); break;
    case QNetworkReply::ContentAccessDenied: m_lastError = tr("Access Denied"); break;
    case QNetworkReply::ContentOperationNotPermittedError: m_lastError = tr("Operation Not Permitted"); break;
    case QNetworkReply::ContentNotFoundError: m_lastError = tr("Not Found"); break;
    case QNetworkReply::AuthenticationRequiredError: m_lastError = tr("Authentication Required"); break;
    case QNetworkReply::ContentReSendError: m_lastError = tr("Content Re Send"); break;
    case QNetworkReply::ProtocolUnknownError: m_lastError = tr("Unknown protocol"); break;
    case QNetworkReply::ProtocolInvalidOperationError: m_lastError = tr("Invalid Operation"); break;
    case QNetworkReply::UnknownNetworkError: m_lastError = tr("Unknown Network Error"); break;
    case QNetworkReply::UnknownProxyError: m_lastError = tr("Unknown Proxy Error"); break;
    case QNetworkReply::UnknownContentError: m_lastError = tr("Unknown Content Error"); break;
    case QNetworkReply::ProtocolFailure: m_lastError = tr("Protocol Failure"); break;
        default: m_lastError = tr("Other Error %1").arg(e); break;
    }

    emit errorOccured();


}
