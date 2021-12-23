#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "uploader/uploader.h"
#include "utils.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    app.setOrganizationDomain("ull.es");
    app.setOrganizationName("Universidad de La Laguna");

    QPointer<Utils> utils = new Utils;
    QPointer<Uploader> uploader = new Uploader;
    qmlRegisterSingletonInstance("ecollect.Native", 1, 0, "Utils", utils.get());
    qmlRegisterSingletonInstance("ecollect.Native", 1, 0, "Uploader", uploader.get());

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
