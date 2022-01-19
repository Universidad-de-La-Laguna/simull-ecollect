#pragma once

#include <QObject>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class UploaderImplAbstract;

class Uploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorChanged)
    QML_ELEMENT

public:
    enum class State {
        StoppedState,
        StartingState,
        TransferringState,
        CancelingState
    };
    Q_ENUM(State);

    enum class Error {
        NoError,
        FileAccessError,
        TransferError
    };
    Q_ENUM(Error);

    explicit Uploader(QObject *parent = nullptr);

    State state() const;
    Error error() const;
    QString errorString() const;

signals:
    void errorChanged();
    void errorOccurred(Uploader::Error errorCode, const QString& errorString);
    void finished();
    void stateChanged();

public slots:
    void cancel();
    void uploadDirectory(const QUrl& directoryUrl) const;
    void uploadDirectory(const QString& directoryPath) const;

private:
    UploaderImplAbstract* uploaderImpl_ = nullptr;
};
