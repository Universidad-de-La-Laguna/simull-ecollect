#include <QObject>
#include <QString>

#include "uploadererror.h"

QString getUploaderErrorString(Uploader::Error errorCode)
{
    QString errorString;
    switch (errorCode) {
    case Uploader::Error::NoError:
        break;
    case Uploader::Error::FileAccessError:
        errorString = QObject::tr("Error trying to access to the file");
    case Uploader::Error::TransferError:
        errorString = QObject::tr("Error during file transfer");
    default:
        errorString = QObject::tr("Unkown error");
    }
    return errorString;
}
