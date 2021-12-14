#include "uploader.h"

Uploader::Uploader(QObject *parent)
    : QObject{parent}
{

}

void Uploader::upload(QList<QUrl> fileList)
{
    emit finished();
}
