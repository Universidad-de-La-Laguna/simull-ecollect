#include <QDebug>

#include "filelog.h"

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
    QFile file(fileLocation_.toLocalFile());
    if (!file.open(QFile::WriteOnly | QIODeviceBase::Append | QIODevice::Text))
    {
        qWarning() << QStringLiteral("ERROR: Cannot open file to write: %1. Caused by (%2) %3")
                      .arg(fileLocation_.toString()).arg(file.error()).arg(file.errorString());
    }

    QTextStream(&file) << str << Qt::endl;
}
