#include "utils.h"

#include <QDir>
#include <QUrl>
#include <QUuid>

Utils::Utils(QObject *parent)
    : QObject{parent}
{

}

QString Utils::createUuid() const
{
    return QUuid::createUuid().toString();
}

bool Utils::makeFilesystemPath(const QUrl& localUrl) const
{
    if (! localUrl.isLocalFile()) return false;
    return QDir().mkpath(localUrl.toLocalFile());
}
