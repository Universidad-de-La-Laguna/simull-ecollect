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

    QCoreApplication::setOrganizationDomain(u"ull.es"_s);
    QCoreApplication::setOrganizationName(u"Universidad de La Laguna"_s);
    QGuiApplication app(argc, argv);

    // Required by JSONListModel to avoid error:
    //  XMLHttpRequest: Using GET on a local file is disabled by default.
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");

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
