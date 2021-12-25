#include <QDir>
#include <QFileInfo>

#include <fstream>
#include <ranges>

#include <aws/core/auth/AWSCredentials.h>
#include <aws/s3/S3Client.h>

#include <simplecrypt/simplecrypt.h>

#include "awsconfig.h"
#include "uploadererror.h"
#include "uploaderawss3impl.h"

#undef GetMessage

static const char CLASS_TAG[] = "UploaderAwsS3Impl";

UploaderAwsS3Impl::UploaderAwsS3Impl(Uploader *parent)
    : UploaderImplAbstract{parent}, uploader_{parent}
{
#if defined(AWS_LOG_LEVEL_DEBUG)
    awsOptions_.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Debug;
#elif defined(AWS_LOG_LEVEL_INFO)
    awsOptions_.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Info;
#endif
    Aws::InitAPI(awsOptions_);

    SimpleCrypt crypto(AWS_CRYPTO_KEY);
    Aws::Auth::AWSCredentials awsCredentials(
                AwsConfig::ACCESS_KEY_ID,
                crypto.decryptToString(QByteArray(AwsConfig::SECRET_ACCESS_KEY.data())).toStdString());

    Aws::Client::ClientConfiguration s3ClientConfiguration;
    s3ClientConfiguration.region = AwsConfig::REGION;
    auto s3Client = Aws::MakeShared<Aws::S3::S3Client>(CLASS_TAG, awsCredentials, s3ClientConfiguration);

    awsExecutor_ = Aws::MakeUnique<Aws::Utils::Threading::DefaultExecutor>(CLASS_TAG);
    Aws::Transfer::TransferManagerConfiguration transferManagerConfig(awsExecutor_.get());
    transferManagerConfig.s3Client = s3Client;
    transferManagerConfig.transferInitiatedCallback = [this](auto manager, auto handle) {
        handleTransferInitiated(manager, handle);
    };
    transferManagerConfig.transferStatusUpdatedCallback = [this](auto manager, auto handle) {
        handleTransferStatusUpdated(manager, handle);
    };
    awsTransferManager_ = Aws::Transfer::TransferManager::Create(transferManagerConfig);
}

UploaderAwsS3Impl::~UploaderAwsS3Impl()
{
    Aws::ShutdownAPI(awsOptions_);
}


void UploaderAwsS3Impl::cancel()
{
    Uploader::Status stoppedStatus = Uploader::Status::StoppedStatus;
    if (status_.compare_exchange_strong(stoppedStatus, Uploader::Status::CancelingStatus))
    {
        transfersList_.cancelPendingTransfers();
    }
}

void UploaderAwsS3Impl::uploadDirectory(const QString& directory)
{
    Uploader::Status stoppedStatus = Uploader::Status::StoppedStatus;
    if (status_.compare_exchange_strong(stoppedStatus, Uploader::Status::StartingStatus))
    {
        transfersList_.clear();
        unsetError();
        QMetaObject::invokeMethod(uploader_, "statusChanged", Qt::QueuedConnection);
    }

    auto path = QDir(directory).absolutePath();
    auto objectNamePrefix = QFileInfo(path).fileName();
    auto metadata = Aws::Map<Aws::String, Aws::String>();
    awsTransferManager_->UploadDirectory(path.toStdString(),
                                         AwsConfig::BUCKET_NAME,
                                         objectNamePrefix.toStdString(),
                                         metadata);
}

void UploaderAwsS3Impl::setState(Uploader::Status status)
{
    if (status_.exchange(status) != status)
    {
        QMetaObject::invokeMethod(uploader_, "statusChanged", Qt::QueuedConnection);
    }
}

void UploaderAwsS3Impl::setError(Uploader::Error errorCode,
                                 const std::optional<Aws::Client::AWSError<Aws::S3::S3Errors>> awsS3Error)
{
    if (error_.hasErrors()) return;

    auto errorString = getUploaderErrorString(errorCode);
    if (awsS3Error.has_value())
    {
        auto awsErrorCode = static_cast<int>(awsS3Error.value().GetErrorType());
        auto awsErrorMessage = QString::fromStdString(awsS3Error.value().GetMessage());
        errorString += QString(": AWS Error(%1): %2").arg(awsErrorCode).arg(awsErrorMessage);
    }

    {
        std::lock_guard lock(error_.mutex);
        error_.code = errorCode;
        error_.string = errorString;
    }
    QMetaObject::invokeMethod(uploader_, "errorChanged", Qt::QueuedConnection);
}

void UploaderAwsS3Impl::unsetError()
{
    if (!error_.hasErrors()) return;

    {
        std::lock_guard lock(error_.mutex);
        error_.code = Uploader::Error::NoError;
        error_.string.clear();
    }
    QMetaObject::invokeMethod(uploader_, "errorChanged", Qt::QueuedConnection);
}

void UploaderAwsS3Impl::handleTransferInitiated(const Aws::Transfer::TransferManager *manager,
                                                const std::shared_ptr<const Aws::Transfer::TransferHandle> handle)
{
    std::unique_lock lock(transfersList_.mutex);
    transfersList_.handles.push_back(std::const_pointer_cast<Aws::Transfer::TransferHandle>(handle));
}

void UploaderAwsS3Impl::handleTransferStatusUpdated(const Aws::Transfer::TransferManager *manager,
                                                    const std::shared_ptr<const Aws::Transfer::TransferHandle> handle)
{
    switch (handle->GetStatus()) {
    case Aws::Transfer::TransferStatus::IN_PROGRESS:
    {
        Uploader::Status startingStatus = Uploader::Status::StartingStatus;
        if (status_.compare_exchange_strong(startingStatus, Uploader::Status::TransferringStatus))
        {
            QMetaObject::invokeMethod(uploader_, "statusChanged", Qt::QueuedConnection);
        }
        break;
    }

    case Aws::Transfer::TransferStatus::FAILED:
    {
        auto awsError = handle->GetLastError();
        setError(awsError.GetErrorType() == Aws::S3::S3Errors::NO_SUCH_UPLOAD
                 ? Uploader::Error::FileAccessError : Uploader::Error::TransferError, awsError);
    }

    case Aws::Transfer::TransferStatus::CANCELED:
        if (handle->IsMultipart())
        {
            const_cast<Aws::Transfer::TransferManager*>(manager)->AbortMultipartUpload(
                        std::const_pointer_cast<Aws::Transfer::TransferHandle>(handle));
        }

    case Aws::Transfer::TransferStatus::ABORTED:
    case Aws::Transfer::TransferStatus::COMPLETED:
        if (transfersList_.isEveryTransferFinished())
        {
            if (status_.exchange(Uploader::Status::StoppedStatus) == Uploader::Status::CancelingStatus)
            {
                QMetaObject::invokeMethod(uploader_, "canceled", Qt::QueuedConnection);
            }
            else if (!error_.hasErrors())
            {
                QMetaObject::invokeMethod(uploader_, "finished", Qt::QueuedConnection);
            }
        }
    }
}

auto UploaderAwsS3Impl::TransfersList::queryPending() const
{
    return handles | std::views::filter([](auto handle) {
        auto status = handle->GetStatus();
        return status == Aws::Transfer::TransferStatus::NOT_STARTED
                || status == Aws::Transfer::TransferStatus::IN_PROGRESS;
    });
}

bool UploaderAwsS3Impl::TransfersList::isEveryTransferFinished() const
{
    auto multipartFailedOrCanceled = handles | std::views::filter([](auto handle){
        auto status = handle->GetStatus();
        return handle->IsMultipart()
                && (status == Aws::Transfer::TransferStatus::CANCELED
                    || status == Aws::Transfer::TransferStatus::FAILED);
    });

    std::lock_guard lock(mutex);
    return std::ranges::empty(queryPending()) && std::ranges::empty(multipartFailedOrCanceled);
}

void UploaderAwsS3Impl::TransfersList::cancelPendingTransfers() const
{
    std::lock_guard lock(mutex);
    for (auto& handle: queryPending())
    {
        handle->Cancel();
    }
}

void UploaderAwsS3Impl::TransfersList::clear()
{
    std::unique_lock lock(mutex);
    handles.clear();
}
