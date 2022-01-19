#include <QFontDatabase>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QTranslator>
#include <QQmlApplicationEngine>

#include <messagehandler.h>

int main(int argc, char *argv[])
{
    MessageHandler::install();

    QGuiApplication app(argc, argv);
    app.setOrganizationDomain("ull.es");
    app.setOrganizationName("Universidad de La Laguna");

    QTranslator translator;
    if (translator.load(QLocale::system(), QStringLiteral("qtbase"), QStringLiteral("_"),
                        QStringLiteral(":/i18n")))
    {
        app.installTranslator(&translator);
    }

    QQmlApplicationEngine engine;
    QFontDatabase::addApplicationFont(":/fonts/materialdesignicons-webfont.ttf");

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
