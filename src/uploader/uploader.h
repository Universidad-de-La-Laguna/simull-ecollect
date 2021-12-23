#pragma once

#include <QObject>
#include <QUrl>

class UploaderImplAbstract;

class Uploader : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorChanged)

public:
    enum class Status {
        StoppedStatus,
        StartingStatus,
        TransferringStatus,
        CancelingStatus
    };
    Q_ENUM(Status);

    enum class Error {
        NoError,
        FileAccessError,
        TransferError
    };
    Q_ENUM(Error);

    explicit Uploader(QObject *parent = nullptr);

    Status status() const;
    Error error() const;
    QString errorString() const;

signals:
    void canceled();
    void errorChanged();
    void errorOcurred(Uploader::Error errorCode, const QString& errorString);
    void finished();
    void statusChanged();

public slots:
    void cancel();
    void uploadDirectory(const QUrl& directoryUrl) const;
    void uploadDirectory(const QString& directoryPath) const;

private:
    UploaderImplAbstract* uploaderImpl_ = nullptr;
};
