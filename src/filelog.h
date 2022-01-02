#pragma once

#include <QFile>
#include <QPointer>
#include <QTextStream>
#include <QUrl>

class FileLog : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl fileLocation READ fileLocation WRITE setFileLocation NOTIFY fileLocationChanged)

public:
    explicit FileLog(QObject *parent = nullptr);

    QUrl fileLocation() const { return fileLocation_; }
    void setFileLocation(const QUrl& location);

signals:
    void fileLocationChanged();

public slots:
    void log(const QString& str);

private:
    QUrl fileLocation_;
};
