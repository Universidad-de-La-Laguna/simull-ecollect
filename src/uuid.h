#ifndef UUID_H
#define UUID_H

#include <QObject>

class Uuid : public QObject
{
    Q_OBJECT
public:
    explicit Uuid(QObject *parent = nullptr);

    Q_INVOKABLE QString create();

signals:

};

#endif // UUID_H
