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
    return QUuid::createUuid().toString(QUuid::Id128);
}

bool Utils::makeFilesystemPath(const QUrl& localUrl) const
{
    if (! localUrl.isLocalFile()) return false;
    return QDir().mkpath(localUrl.toLocalFile());
}

bool Utils::removeFilesystemPath(const QUrl &localUrl) const
{
    if (! localUrl.isLocalFile()) return false;
    return QDir(localUrl.toLocalFile()).removeRecursively();

}

bool Utils::showFullscreen() const
{
#if ECOLLECT_ENABLE_FULLSCREEN == 1
    return true;
#else
    return false;
#endif
}
