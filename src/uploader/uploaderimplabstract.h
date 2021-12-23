#pragma once

#include "uploader.h"

class UploaderImplAbstract : public QObject
{
    Q_OBJECT
public:
    explicit UploaderImplAbstract(Uploader *parent) {}
    virtual ~UploaderImplAbstract() {};

    virtual Uploader::Status status() const = 0;
    virtual Uploader::Error error() const = 0;
    virtual QString errorString() const = 0;

public slots:
   virtual void cancel() = 0;
   virtual void uploadDirectory(const QString& directory) = 0;
};
