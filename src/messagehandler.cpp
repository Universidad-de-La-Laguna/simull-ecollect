#include <QDir>
#include <QStandardPaths>
#include <QString>
#include <QTextStream>

#include "messagehandler.h"

namespace MessageHandler
{
    const char LOG_FILENAME[] = "main.log";
    const char MESSAGE_PATTERN[] = "[%{time}] "
                                   "%{if-debug}[dbug] %{endif}"
                                   "%{if-info}[info] %{endif}"
                                   "%{if-warning}[warn] %{endif}"
                                   "%{if-critical}[crit] %{endif}"
                                   "%{if-fatal}[ftal] %{endif}"
                                   "%{message}";

    QtMessageHandler defaultMessageHandler = nullptr;

    QString getLogFileName()
    {
        auto appDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        return QDir(appDataLocation).absoluteFilePath(LOG_FILENAME);
    }

    void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
    {
        QString message = qFormatLogMessage(type, context, msg);

        QFile log(getLogFileName());
        if (log.open(QIODeviceBase::WriteOnly | QIODeviceBase::Append | QIODevice::Text))
        {
            QTextStream(&log) << message << '\n';
        }
        else
        {
            QTextStream(stdout) << "ERROR: Cannot open log file: " << getLogFileName() << '\n';
        }

#if defined(QT_DEBUG)
        defaultMessageHandler(type, context, msg);
#endif
    }

    void install()
    {
        qSetMessagePattern(QString(MESSAGE_PATTERN));

        auto logFileName = getLogFileName();
        auto logFileDirname = QFileInfo(logFileName).dir();
        if (!logFileDirname.mkpath("."))
        {
            qWarning() << "ERROR: Cannot create log file parent directory: " << logFileDirname;
        }

        defaultMessageHandler = qInstallMessageHandler(messageHandler);
    }
}
