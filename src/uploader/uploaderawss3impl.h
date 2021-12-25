#pragma once

#include <shared_mutex>

#include <aws/core/Aws.h>
#include <aws/core/utils/threading/Executor.h>
#include <aws/transfer/TransferHandle.h>
#include <aws/transfer/TransferManager.h>

#include "uploaderimplabstract.h"

class UploaderAwsS3Impl : public UploaderImplAbstract
{
    Q_OBJECT
public:
    UploaderAwsS3Impl(Uploader *parent);
    ~UploaderAwsS3Impl() override;

    Uploader::Status status() const final { return status_; }
    Uploader::Error error() const final { std::lock_guard lock(error_.mutex); return error_.code; }
    QString errorString() const final { std::lock_guard lock(error_.mutex); return error_.string; }

public slots:
    void cancel() final;
    void uploadDirectory(const QString& directory) final;

private:
    Uploader* uploader_ = nullptr;
    std::atomic<Uploader::Status> status_ = Uploader::Status::StoppedStatus;

    struct
    {
        mutable std::mutex mutex;
        Uploader::Error code = Uploader::Error::NoError;
        QString string;

        bool hasErrors() const { std::lock_guard lock(mutex); return code != Uploader::Error::NoError; }
    } error_;

    Aws::SDKOptions awsOptions_;
    Aws::UniquePtr<Aws::Utils::Threading::Executor> awsExecutor_;
    std::shared_ptr<Aws::Transfer::TransferManager> awsTransferManager_;

    struct TransfersList
    {
        mutable std::shared_mutex mutex;
        std::vector<std::shared_ptr<Aws::Transfer::TransferHandle>> handles;

        auto queryPending() const;
        bool isEveryTransferFinished() const;
        void cancelPendingTransfers() const;
        void clear();
    } transfersList_;

    void setState(Uploader::Status status);
    void setError(Uploader::Error errorCode,
                  const std::optional<Aws::Client::AWSError<Aws::S3::S3Errors>> awsS3Error = std::nullopt);
    void unsetError();

    void handleTransferInitiated(const Aws::Transfer::TransferManager* manager,
                                     const std::shared_ptr<const Aws::Transfer::TransferHandle> handle);
    void handleTransferStatusUpdated(const Aws::Transfer::TransferManager* manager,
                                     const std::shared_ptr<const Aws::Transfer::TransferHandle> handle);
};
