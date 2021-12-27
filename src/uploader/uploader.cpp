#include "uploaderawss3impl.h"
#include "uploader.h"

Uploader::Uploader(QObject *parent)
    : QObject{parent}
{
#if defined(AWS_UPLOAD_DISABLED)
    uploaderImpl = new UploaderMockImpl(this);
#else
    uploaderImpl_ = new UploaderAwsS3Impl(this);
#endif
}

Uploader::State Uploader::state() const
{
    return uploaderImpl_->state();
}

Uploader::Error Uploader::error() const
{
    return uploaderImpl_->error();
}

QString Uploader::errorString() const
{
    return uploaderImpl_->errorString();
}

void Uploader::cancel()
{
    uploaderImpl_->cancel();
}

void Uploader::uploadDirectory(const QUrl& directoryUrl) const
{
    uploadDirectory(directoryUrl.toLocalFile());
}

void Uploader::uploadDirectory(const QString& directoryPath) const
{
    uploaderImpl_->uploadDirectory(directoryPath);
}
