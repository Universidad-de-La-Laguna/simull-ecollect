#pragma once

#include <QObject>
#include <QUrl>

class Uploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int progressValue READ progressValue NOTIFY progressValueChanged)

public:
    explicit Uploader(QObject *parent = nullptr);

    int progressValue() const { return progressValue_; }

    Q_INVOKABLE void upload(QList<QUrl> fileList=QList<QUrl>());

signals:
    void finished();
    void progressValueChanged(int);

private:
    int progressValue_;
};
