#include <QtGui/QGuiApplication>
#include <QtDebug>
#include <QFile>
#include <QTextStream>
#include <QObject>

#include <QQmlApplicationEngine>
#include <QtWidgets/QApplication>
#include <QtQml>
#include <QQuickWindow>


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

void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;
    switch (type) {
    case QtDebugMsg:

        txt = QString("Debug: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        abort();
    default:
        txt = QString("Other: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;

    }
    QFile outFile("viewer.log");
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    ts << txt << endl;
    outFile.close();

}


int main(int argc, char *argv[])
{

    QApplication app(argc, argv);
    //    QGuiApplication app(argc, argv);

    //    qInstallMessageHandler(myMessageHandler); // FIXME: timto se zapina vytvareni logu do souboru

    QQmlApplicationEngine engine;

    //    qDebug() << "app.libraryPaths() "  << app.libraryPaths();

    //    qmlRegisterType< QList<IgcEvent*> >("cz.mlich", 1, 0, "IgcEventList");
    //    qmlRegisterType<IgcEvent>("cz.mlich", 1, 0, "IgcEvent");
    qmlRegisterType<IgcFiltered>("cz.mlich", 1, 0, "IgcFile");
    qmlRegisterType<FileReader>("cz.mlich", 1, 0, "FileReader");
    qmlRegisterType<ImageSaver>("cz.mlich", 1, 0, "ImageSaver");
    qmlRegisterType<PdfWriter>("cz.mlich", 1, 0, "PdfWriter");
    qmlRegisterType<ResultsCreater>("cz.mlich", 1, 0, "ResultsCreater");
    qmlRegisterType<Worker>("cz.mlich", 1, 0, "CppWorker");

    qmlRegisterType<SortFilterProxyModel>("org.qtproject.example", 1, 0, "SortFilterProxyModel");   

    QTranslator translator;

    //    if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
    if (translator.load(QLatin1String("viewer_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());
    } else {
        qDebug() << "translation.load() failed - falling back to English";
        //        if (translator.load(QLatin1String("viewer_en_US") , QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        if (translator.load(QLatin1String("viewer_en_US")   , "./")) {
            app.installTranslator(&translator);
        }
        engine.rootContext()->setContextProperty("locale","en");
    }
    engine.rootContext()->setContextProperty("builddate", QString::fromLocal8Bit(__DATE__));
    engine.rootContext()->setContextProperty("buildtime", QString::fromLocal8Bit(__TIME__));

    //    IgcFile igc;
    //    igc.load("/home/imlich/workspace/tucek/igctest/laa31T01V1R1_laa31.igc");

    //    QQmlContext *ctx = engine.rootContext();
    //    ctx->setContextProperty("igc",&igc);

    NetworkAccessManagerFactory namFactory;

    engine.setNetworkAccessManagerFactory(&namFactory);
    engine.rootContext()->setContextProperty("QStandardPathsHomeLocation", QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0]);
    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath() );
    //    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().left(QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().size()-4) );

    engine.load(QUrl("qml/viewer/main.qml"));


    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    window->setIcon(QIcon(":/viewer64.png"));
    window->show();
    return app.exec();

}
