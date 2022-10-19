#include <QFontDatabase>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>

#include <messagehandler.h>
#include <translator.h>

using namespace Qt::Literals;

int main(int argc, char *argv[])
{
    MessageHandler::install();

    QGuiApplication app(argc, argv);
    app.setOrganizationDomain("ull.es");
    app.setOrganizationName("Universidad de La Laguna");

    // TODO: Sobrescribir locale por la línea de comandos.
    Translator::install();

    QQmlApplicationEngine engine;
    QFontDatabase::addApplicationFont(":/fonts/materialdesignicons-webfont.ttf");

    engine.addImportPath("qrc:/qml/imports");
    const QUrl url(u"qrc:/qml/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
