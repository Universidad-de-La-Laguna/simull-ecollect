#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QtQml/qqmlregistration.h>

class Utils : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Utils(QObject *parent = nullptr);

    Q_INVOKABLE QString createUuid() const;
    Q_INVOKABLE bool makeFilesystemPath(const QUrl& localUrl) const;
    Q_INVOKABLE bool removeFilesystemPath(const QUrl& localUrl) const;
    Q_INVOKABLE bool showFullscreen() const;
};
