#include <QFontDatabase>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>

#include <i18n.h>
#include <messagehandler.h>

using namespace Qt::Literals;

int main(int argc, char *argv[])
{
    MessageHandler::install();

    QGuiApplication app(argc, argv);
    app.setOrganizationDomain(u"ull.es"_s);
    app.setOrganizationName(u"Universidad de La Laguna"_s);

    auto i18n = I18n::instance();

    QQmlApplicationEngine engine;
    QFontDatabase::addApplicationFont(u":/fonts/materialdesignicons-webfont.ttf"_s);

    engine.addImportPath(u"qrc:/qml/imports"_s);
    const QUrl url(u"qrc:/qml/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
