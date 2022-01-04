#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "filelog.h"
#include "messagehandler.h"
#include "uploader/uploader.h"
#include "utils.h"

int main(int argc, char *argv[])
{
    MessageHandler::install();

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    app.setOrganizationDomain("ull.es");
    app.setOrganizationName("Universidad de La Laguna");

    QPointer<Utils> utils = new Utils;
    qmlRegisterSingletonInstance("ecollect.Native", 1, 0, "Utils", utils.get());
    qmlRegisterType<Uploader>("ecollect.Native", 1, 0, "Uploader");
    qmlRegisterType<FileLog>("ecollect.Native", 1, 0, "FileLog");

    auto a = QFontDatabase::addApplicationFont(":/fonts/materialdesignicons-webfont.ttf");

    engine.addImportPath("qrc:/qml/imports");
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
