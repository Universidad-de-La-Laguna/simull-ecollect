#include <QGuiApplication>
#include <QLocale>
#include <QStringList>
#include <QTranslator>

#include "translator.h"

using namespace Qt::Literals;

namespace Translator
{
    const auto TRANSLATION_DIRECTORY = u":/i18n"_s;
    const auto TRANSLATION_FIILENAME = u"ecollect"_s;
    const auto TRANSLATION_FIILENAME_SEP = u"_"_s;
    const auto FALLBACK_LOCALE_NAME = u"en"_s;

    const QString QT_TRANSLATION_FILES[] = {
        u"qtbase"_s,
        u"qtdeclarative"_s,
        u"qtmultimedia"_s,
    };

    void installQtTranslations(const QLocale& locale = QLocale())
    {
        for (auto& filename: QT_TRANSLATION_FILES)
        {
            QTranslator translator;
            if (translator.load(locale, filename, TRANSLATION_FIILENAME_SEP,
                                TRANSLATION_DIRECTORY))
            {
                qApp->installTranslator(&translator);
            }
            else
            {
                qDebug() << u"ERROR: Cannot load '%1' translation of '%2'"_s
                            .arg(locale.name(), filename);
            }
        }
    }

    void installTranslations(const QLocale& locale = QLocale())
    {
        QTranslator translator;
        if (translator.load(locale, TRANSLATION_FIILENAME,
                            TRANSLATION_FIILENAME_SEP, TRANSLATION_DIRECTORY))
        {
            qApp->installTranslator(&translator);
        }
        else
        {
            qDebug() << u"ERROR: Cannot load '%1' translation of '%2'"_s
                        .arg(locale.name(), TRANSLATION_FIILENAME);
        }
    }

    void install()
    {
        QLocale fallbackLocale(FALLBACK_LOCALE_NAME);

        installQtTranslations(fallbackLocale);
        installQtTranslations();

        installTranslations(fallbackLocale);
        installTranslations();
    }
}
