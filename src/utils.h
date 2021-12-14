#pragma once

#include <QObject>

class Utils : public QObject
{
    Q_OBJECT
public:
    explicit Utils(QObject *parent = nullptr);

    Q_INVOKABLE QString createUuid() const;
    Q_INVOKABLE bool makeFilesystemPath(const QUrl& localUrl) const;

signals:

};
