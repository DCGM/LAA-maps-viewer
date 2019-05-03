#include <QApplication>
#include <QtDebug>
#include <QFile>
#include <QTextStream>
#include <QObject>

#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickWindow>
#include <QLoggingCategory>


//#include "qtquick2applicationviewer.h"
//#include "igc.h"
#include "igcfiltered.h"
#include "filereader.h"
#include "networkaccessmanagerfactory.h"
#include "imagesaver.h"
#include "pdfwriter.h"
#include "sortfilterproxymodel.h"
#include "resultscreater.h"
#include "worker.h"
#include "uploader.h"


// turns on logging of context (file+line number) in c++
#define QT_MESSAGELOGCONTEXT

void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;

    QDateTime now = QDateTime::currentDateTime();
    int offset = now.offsetFromUtc();
    now.setOffsetFromUtc(offset);

#if defined(Q_OS_LINUX)
    if (!QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).exists()) {
        QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    }
    QFile outFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator() +"viewer.log");
#elif (defined (Q_OS_WIN) || defined (Q_OS_WIN32) || defined (Q_OS_WIN64))
    QFile outFile("viewer.log");
#else
    QFile outfile("viewer.log");
#endif
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);

    QTextStream std_out(stdout, QIODevice::WriteOnly);
    QTextStream std_err(stderr, QIODevice::WriteOnly);

    switch (type) {
    case QtDebugMsg:
        txt = QString("%1 [D] %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl ;
        break;
    case QtWarningMsg:
        txt = QString("%1 [W]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl;
        break;
    case QtCriticalMsg:
        txt = QString("%1 [C]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;
    case QtFatalMsg:
        txt = QString("%1 [F]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        abort();
    default:
        txt = QString("%1 [O]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;

    }
    ts << txt;
#if (defined (Q_OS_WIN) || defined (Q_OS_WIN32) || defined (Q_OS_WIN64))
    ts << ('\r');
#endif
    ts << endl;

    outFile.close();
}


int main(int argc, char *argv[])
{
    QLoggingCategory::setFilterRules("qt.network.ssl.warning=false");  // disable SSL warnings

    QApplication app(argc, argv);

    qInstallMessageHandler(myMessageHandler);

    app.setOrganizationName("Brno University of Technology");
    app.setOrganizationDomain("fit.vutbr.cz");
    app.setApplicationName("LAA Maps Viewer");

    QQmlApplicationEngine engine;

    qmlRegisterType<IgcFiltered>("cz.mlich", 1, 0, "IgcFile");
    qmlRegisterType<FileReader>("cz.mlich", 1, 0, "FileReader");
    qmlRegisterType<ImageSaver>("cz.mlich", 1, 0, "ImageSaver");
    qmlRegisterType<PdfWriter>("cz.mlich", 1, 0, "PdfWriter");
    qmlRegisterType<ResultsCreater>("cz.mlich", 1, 0, "ResultsCreater");
    qmlRegisterType<Worker>("cz.mlich", 1, 0, "CppWorker");
    qmlRegisterType<Uploader>("cz.mlich", 1, 0, "Uploader");

    QTranslator translator;
    QTranslator qtTranslator;
    QTranslator qtBaseTranslator;

    // custom components
    if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
    } else if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
    } else {
        qDebug() << "translation.load() failed - falling back to English";

        if (translator.load(QLatin1String("viewer_en_US"), "./")) {
            app.installTranslator(&translator);
        } else if (translator.load(QLatin1String("viewer_en_US"), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
            app.installTranslator(&translator);
        }

        engine.rootContext()->setContextProperty("locale","en");
    }
    engine.rootContext()->setContextProperty("builddate", QString::fromLocal8Bit(__DATE__));
    engine.rootContext()->setContextProperty("buildtime", QString::fromLocal8Bit(__TIME__));
    engine.rootContext()->setContextProperty("version", QString::fromLocal8Bit(GIT_VERSION));

    qDebug() << "Starting build " << QString::fromLocal8Bit(GIT_VERSION) << " "<< QString::fromLocal8Bit(__DATE__) << " " <<  QString::fromLocal8Bit(__TIME__);
    qDebug() << QSslSocket::supportsSsl() << QSslSocket::sslLibraryBuildVersionString() << QSslSocket::sslLibraryVersionString();

    NetworkAccessManagerFactory namFactory;

    engine.setNetworkAccessManagerFactory(&namFactory);
    engine.rootContext()->setContextProperty("QStandardPathsHomeLocation", QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0]);
    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath() );

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    //engine.setOfflineStoragePath( QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath());
    //QString str = engine.offlineStoragePath();
    //qDebug() << "setOfflineStoragePath: " << str;

    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    window->setIcon(QIcon(":/viewer64.png"));
    window->show();
    return app.exec();

}
