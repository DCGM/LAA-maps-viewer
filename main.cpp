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

void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;

    QFile outFile("viewer.log");
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);

    QTextStream std_out(stdout, QIODevice::WriteOnly);
    QTextStream std_err(stderr, QIODevice::WriteOnly);


    switch (type) {
    case QtDebugMsg:

        txt = QString("Debug: [%1:%2@%3]: %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl;
        break;
    case QtWarningMsg:
        txt = QString("Warning: [%1:%2@%3]: %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl;
        break;
    case QtCriticalMsg:
        txt = QString("Critical: [%1:%2@%3]: %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;
    case QtFatalMsg:
        txt = QString("Fatal: [%1:%2@%3]: %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        abort();
    default:
        txt = QString("Other: [%1:%2@%3]: %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;

    }
    ts << txt << endl;

    outFile.close();

}


int main(int argc, char *argv[])
{
    QLoggingCategory::setFilterRules("qt.network.ssl.warning=false");  // disable SSL warnings

    QApplication app(argc, argv);

    qInstallMessageHandler(myMessageHandler);

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

    // used for standart buttons
    if (qtTranslator.load(QLocale::system(), "qt", "_", "./")) {
        qDebug() << "qtTranslator ok";
        app.installTranslator(&qtTranslator);
    }
    if (qtBaseTranslator.load("qtbase_" + QLocale::system().name(), "./")) {
        qDebug() << "qtBaseTranslator ok";
        app.installTranslator(&qtBaseTranslator);
    }

    // custom components
    if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
    } else {
        qDebug() << "translation.load() failed - falling back to English";

        if (translator.load(QLatin1String("viewer_en_US")   , "./")) {
            app.installTranslator(&translator);
        }
        engine.rootContext()->setContextProperty("locale","en");
    }
    engine.rootContext()->setContextProperty("builddate", QString::fromLocal8Bit(__DATE__));
    engine.rootContext()->setContextProperty("buildtime", QString::fromLocal8Bit(__TIME__));

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
