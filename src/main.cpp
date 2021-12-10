#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "uuid.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    app.setOrganizationDomain("ull.es");
    app.setOrganizationName("Universidad de La Laguna");

    QPointer<Uuid> uuid = new Uuid;
    qmlRegisterSingletonInstance("ecollect.Native", 1, 0, "Uuid", uuid.get());

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
