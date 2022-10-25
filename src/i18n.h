#pragma once

#include <QStringListModel>
#include <QTranslator>
#include <QtQml/qqmlregistration.h>

class QJSEngine;
class QQmlEngine;

class I18n : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QStringListModel* supportedLanguages READ supportedLanguages CONSTANT)
    Q_PROPERTY(int activeLanguageIndex READ activeLanguageIndex WRITE setActiveLanguageIndex
               NOTIFY activeLanguageChanged)

public:
    static I18n* instance();
    static I18n* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine);

    QStringListModel* supportedLanguages() const { return supportedLanguagesModel_; }

    int activeLanguageIndex() const { return activeLanguageIndex_; };
    void setActiveLanguageIndex(int index);

signals:
    void activeLanguageChanged();

public slots:
    void activateTranslation(const QString& language);
    void installTranslation(const QString& language, const QString& filename);

private:
    int activeLanguageIndex_;
    QStringListModel* supportedLanguagesModel_;
    QMap<QString, QTranslator*> translators_;

    explicit I18n(QObject* parent = nullptr);

    void installQtTranslations(const QString& language);
};
