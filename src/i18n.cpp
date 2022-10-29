#include <QGuiApplication>
#include <QLocale>
#include <QQmlEngine>
#include <QString>
#include <QTranslator>

#include <algorithm>

#include "i18n.h"

using namespace Qt::Literals;

const QString FALLBACK_LANGUAGE = u"en"_s;
const QStringList SUPPORTED_LANGUAGES = {
    u"en"_s,
    u"es"_s,
};

const QString TRANSLATIONS_DIRECTORY = u":/i18n"_s;
const QString TRANSLATIONS_FIILENAME_SEP = u"_"_s;

const QString MAIN_TRANSLATION_FILE = u"ecollect"_s;
const QString QT_TRANSLATION_FILES[] = {
    u"qtbase"_s,
    u"qtdeclarative"_s,
    u"qtmultimedia"_s,
};

int findInSupportedLanguages(const QString& language)
{
    auto it = std::find(SUPPORTED_LANGUAGES.constBegin(), SUPPORTED_LANGUAGES.constEnd(), language);
    if (it != SUPPORTED_LANGUAGES.constEnd())
    {
        return it - SUPPORTED_LANGUAGES.constBegin();
    }

    return -1;
}

int chooseBestLanguage()
{
    QString systemLocaleLanguage = QLocale::languageToCode(QLocale::system().language(), QLocale::ISO639Part1);

    int languageIndex = findInSupportedLanguages(systemLocaleLanguage);
    if (languageIndex >= 0)
    {
        return languageIndex;
    }

    languageIndex = findInSupportedLanguages(FALLBACK_LANGUAGE);
    Q_ASSERT_X(languageIndex < 0, "I18n::chooseBestLanguage",
               "fallback language is not in the supported languages list");

    return languageIndex;
}

I18n::I18n(QObject *parent)
    : QObject(parent), activeLanguageIndex_(-1)
{
    supportedLanguagesModel_ = new QStringListModel(SUPPORTED_LANGUAGES, this);
    activeLanguageIndex_ = chooseBestLanguage();
    setActiveLanguageIndex(activeLanguageIndex_);
}

I18n* I18n::instance()
{
    static I18n* instance = nullptr;

    if (! instance)
    {
        instance = new I18n;
    }

    return instance;
}

I18n* I18n::create(QQmlEngine* qmlEngine, QJSEngine* jsEngine)
{
    auto instance = I18n::instance();
    if (! instance->parent())
    {
        instance->setParent(qmlEngine);
    }

    return instance;
}

void I18n::setActiveLanguageIndex(int index)
{
    if (activeLanguageIndex_ != index && index >= 0 && index < SUPPORTED_LANGUAGES.size())
    {
        activeLanguageIndex_ = index;
        activateTranslation(SUPPORTED_LANGUAGES[activeLanguageIndex_]);
        QLocale::setDefault(QLocale(SUPPORTED_LANGUAGES[activeLanguageIndex_]));

        auto qmlEngine = qobject_cast<QQmlEngine*>(parent());
        if (qmlEngine)
        {
            qmlEngine->retranslate();
        }

        emit activeLanguageChanged();
    }
}

void I18n::activateTranslation(const QString &language)
{
    installQtTranslations(language);
    installTranslation(language, MAIN_TRANSLATION_FILE);
}

void I18n::installTranslation(const QString& language, const QString& filename)
{
    QTranslator* translator = translators_.value(filename, new QTranslator(this));
    if (translator->load(QLocale(language), filename, TRANSLATIONS_FIILENAME_SEP, TRANSLATIONS_DIRECTORY))
    {
        qApp->installTranslator(translator);
        translators_.insert(filename, translator);
    }
    else
    {
        qDebug() << u"ERROR: Cannot load the '%1' translation of '%2'"_s.arg(language, filename);
    }

}

void I18n::installQtTranslations(const QString &language)
{
    for (auto& filename: QT_TRANSLATION_FILES)
    {
        installTranslation(language, filename);
    }
}
