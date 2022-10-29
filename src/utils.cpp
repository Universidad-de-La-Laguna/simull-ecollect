#include "utils.h"

#include <QDir>
#include <QUrl>
#include <QUuid>

using namespace Qt::Literals;

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

QString Utils::UrlToFilePath(const QUrl &localUrl) const
{
    if (localUrl.isLocalFile())
    {
        return localUrl.toLocalFile();
    }
    else if (localUrl.scheme() == "qrc")
    {
        return ":" + localUrl.path(QUrl::FullyDecoded);
    }

    return QString();
}

QStringList Utils::readPlaylist(const QUrl &localUrl) const
{
    QStringList playlist;

    QString filePath = UrlToFilePath(localUrl);
    QFile playlistFile(filePath);
    if (! playlistFile.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << u"ERROR: Cannot open: %1 (%2)"_s.arg(localUrl.toString(), filePath);
        return playlist;
    }

    QTextStream stream(&playlistFile);
    for(QString line; stream.readLineInto(&line);)
    {
        playlist << line;
    }

    return playlist;
}

bool Utils::showFullscreen() const
{
#ifdef ECOLLECT_DISABLE_FULLSCREEN
    return true;
#else
    return false;
#endif
}
