#include <QApplication>
#include <QtDebug>
#include <QFile>
#include <QTextStream>
#include <QObject>
#include <QTranslator>

#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickWindow>
#include <QLoggingCategory>
#include <QtWidgets>

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
    QTextStream std_out(stdout, QIODevice::WriteOnly);
    QTextStream std_err(stderr, QIODevice::WriteOnly);

    if (!outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        std_err << "Cannot open log file" << endl;
    }
    QTextStream ts(&outFile);


    switch (type) {
    case QtDebugMsg:
        txt = QString("%1 [D] %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl;
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
    ts << txt << endl;

    outFile.close();
}


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    app.setOrganizationName("Brno University of Technology");
    app.setOrganizationDomain("fit.vutbr.cz");
    app.setApplicationName("LAA Maps Viewer");

    qInstallMessageHandler(myMessageHandler);

    qDebug() << "Starting build " << QString::fromLocal8Bit(GIT_VERSION) << " "<< QString::fromLocal8Bit(__DATE__) << " " <<  QString::fromLocal8Bit(__TIME__) << "Qt:" << qVersion();
    qDebug() << "supportsSsl" <<QSslSocket::supportsSsl() << "build version:"<< QSslSocket::sslLibraryBuildVersionString() << "library version:" << QSslSocket::sslLibraryVersionString();
    if (!QSslSocket::supportsSsl()) {
        QMessageBox::critical(NULL, QMessageBox::tr("Error"), QMessageBox::tr("SSL is not installed"), QMessageBox::Ok);
        qFatal("SSL is not installed");
    }

#if defined(Q_OS_LINUX)
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator() + "viewer.log";
#endif

    QQmlApplicationEngine engine;

    qmlRegisterType<IgcFiltered>("cz.mlich", 1, 0, "IgcFile");
    qmlRegisterType<FileReader>("cz.mlich", 1, 0, "FileReader");
    qmlRegisterType<ImageSaver>("cz.mlich", 1, 0, "ImageSaver");
    qmlRegisterType<PdfWriter>("cz.mlich", 1, 0, "PdfWriter");
    qmlRegisterType<ResultsCreater>("cz.mlich", 1, 0, "ResultsCreater");
    qmlRegisterType<Worker>("cz.mlich", 1, 0, "CppWorker");
    qmlRegisterType<Uploader>("cz.mlich", 1, 0, "Uploader");

    QTranslator translator;

    // custom components
    if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
        qDebug() << QLocale::system().name() << QLocale::system().bcp47Name();
    } else if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
        qDebug() << QLocale::system().name() << QLocale::system().bcp47Name() << QLibraryInfo::location(QLibraryInfo::TranslationsPath);
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
