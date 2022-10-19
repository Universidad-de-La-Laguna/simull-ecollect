#include <QDebug>
#include <QDir>

#include "filelog.h"

using namespace Qt::Literals;

FileLog::FileLog(QObject *parent)
    : QObject{parent}
{

}

void FileLog::setFileLocation(const QUrl& location)
{
    fileLocation_ = location;
    emit fileLocationChanged();
}

void FileLog::log(const QString &str)
{
    QString localFileLocation = fileLocation_.toLocalFile();
    QDir fileLocationDir = QFileInfo(localFileLocation).dir();

    if (!fileLocationDir.exists())
    {
        QDir().mkpath(fileLocationDir.path());
    }

    QFile file(localFileLocation);
    if (!file.open(QFile::WriteOnly | QIODeviceBase::Append | QIODevice::Text))
    {
        qWarning() << u"ERROR: Cannot open file to write: %1. Caused by (%2) %3"_s
                      .arg(fileLocation_.toString()).arg(file.error()).arg(file.errorString());
    }

    QTextStream(&file) << str << Qt::endl;
}
