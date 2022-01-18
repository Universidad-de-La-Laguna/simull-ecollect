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

    awsOptions_.loggingOptions.logLevel = static_cast<Aws::Utils::Logging::LogLevel>(AWS_LOGGING_LOGLEVEL);
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
    transferManagerConfig.errorCallback = [this](auto manager, auto handle, auto error) {
        handleTransferError(manager, handle, error);
    };
    awsTransferManager_ = Aws::Transfer::TransferManager::Create(transferManagerConfig);
}

UploaderAwsS3Impl::~UploaderAwsS3Impl()
{
    Aws::ShutdownAPI(awsOptions_);
}


void UploaderAwsS3Impl::cancel()
{
    // Enter in canceling state. Return if we are stopped or already canceling
    Uploader::State previousState;
    do
    {
        previousState = state_.load();
        if (previousState == Uploader::State::CancelingState
                || previousState == Uploader::State::StoppedState)
        {
            return;
        }
    } while(!state_.compare_exchange_weak(previousState, Uploader::State::CancelingState));
    QMetaObject::invokeMethod(uploader_, "stateChanged", Qt::QueuedConnection);

    cancelPendingTransfers();
}

void UploaderAwsS3Impl::uploadDirectory(const QString& directory)
{
    auto stoppedState = Uploader::State::StoppedState;
    if (!state_.compare_exchange_strong(stoppedState, Uploader::State::StartingState))
    {
        return;
    }

    transfersList_.clear();
    unsetError();
    QMetaObject::invokeMethod(uploader_, "stateChanged", Qt::QueuedConnection);

    auto path = QDir(directory).absolutePath();
    auto objectNamePrefix = QFileInfo(path).fileName();
    auto metadata = Aws::Map<Aws::String, Aws::String>();
    awsTransferManager_->UploadDirectory(path.toStdString(),
                                         AwsConfig::BUCKET_NAME,
                                         objectNamePrefix.toStdString(),
                                         metadata);
}

void UploaderAwsS3Impl::setError(Uploader::Error errorCode,
                                 const std::optional<Aws::Client::AWSError<Aws::S3::S3Errors>> awsS3Error)
{
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
    QMetaObject::invokeMethod(uploader_, "errorOccurred", Qt::QueuedConnection, Q_ARG(Uploader::Error, errorCode),
                              Q_ARG(QString, errorString));
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

void UploaderAwsS3Impl::handleTransferError(const Aws::Transfer::TransferManager* manager,
                                            const std::shared_ptr<const Aws::Transfer::TransferHandle> handle,
                                            const Aws::Client::AWSError<Aws::S3::S3Errors> &error)
{
    switch(error.GetErrorType())
    {
        case static_cast<Aws::S3::S3Errors>(Aws::Client::CoreErrors::USER_CANCELLED):
            break;

        case Aws::S3::S3Errors::NO_SUCH_UPLOAD:
            setError(Uploader::Error::FileAccessError, error);
            break;

        case Aws::S3::S3Errors::REQUEST_TIMEOUT:
        case Aws::S3::S3Errors::NETWORK_CONNECTION:
            if (handle->IsMultipart())
            {
                // Try to abort upload
                awsTransferManager_->AbortMultipartUpload(std::const_pointer_cast<Aws::Transfer::TransferHandle>(handle));
            }

        default:
            setError(Uploader::Error::TransferError, error);
    }
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
    auto transferStatus = handle->GetStatus();
    if (transferStatus == Aws::Transfer::TransferStatus::IN_PROGRESS)
    {
        Uploader::State startingState = Uploader::State::StartingState;
        if (state_.compare_exchange_strong(startingState, Uploader::State::TransferringState))
        {
            QMetaObject::invokeMethod(uploader_, "stateChanged", Qt::QueuedConnection);
        }

        return;
    }

    if (transfersList_.isEveryTransferFinished())
    {
        state_ = Uploader::State::StoppedState;
        QMetaObject::invokeMethod(uploader_, "stateChanged", Qt::QueuedConnection);
        QMetaObject::invokeMethod(uploader_, "finished", Qt::QueuedConnection);
    }
}

auto UploaderAwsS3Impl::TransfersList::queryPending() const
{
    return handles | std::views::filter([](auto handle) {
        auto state = handle->GetStatus();
        return state == Aws::Transfer::TransferStatus::NOT_STARTED
                || state == Aws::Transfer::TransferStatus::IN_PROGRESS
                || handle->HasPendingParts();
    });
}

bool UploaderAwsS3Impl::TransfersList::isEveryTransferFinished() const
{
    std::lock_guard lock(mutex);
    return std::ranges::empty(queryPending());
}

void UploaderAwsS3Impl::TransfersList::clear()
{
    std::unique_lock lock(mutex);
    handles.clear();
}

void UploaderAwsS3Impl::cancelPendingTransfers() const
{
    std::lock_guard lock(transfersList_.mutex);
    for (auto& handle: transfersList_.queryPending())
    {
        cancelTransfer(handle);
    }
}

void UploaderAwsS3Impl::cancelTransfer(const std::shared_ptr<Aws::Transfer::TransferHandle> handle) const
{
    handle->Cancel();
    if (handle->IsMultipart())
    {
        awsTransferManager_->AbortMultipartUpload(handle);
    }
}
