#include "uuid.h"

#include <QUuid>

Uuid::Uuid(QObject *parent)
    : QObject{parent}
{

}

QString Uuid::create()
{
    return QUuid::createUuid().toString();
}
