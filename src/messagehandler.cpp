#include <QDir>
#include <QStandardPaths>
#include <QString>
#include <QTextStream>

#include "messagehandler.h"

using namespace Qt::Literals;

namespace MessageHandler
{
    const auto LOG_FILENAME = u"main.log"_s;
    const auto MESSAGE_PATTERN = u"[%{time}] "
                                   "%{if-debug}[dbug] %{endif}"
                                   "%{if-info}[info] %{endif}"
                                   "%{if-warning}[warn] %{endif}"
                                   "%{if-critical}[crit] %{endif}"
                                   "%{if-fatal}[ftal] %{endif}"
                                   "%{message}"_s;

    QtMessageHandler defaultMessageHandler = nullptr;

    QString getLogFileName()
    {
        auto appDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        return QDir(appDataLocation).absoluteFilePath(LOG_FILENAME);
    }

    void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
    {
        QString message = qFormatLogMessage(type, context, msg);

        QDir logFileDir = QFileInfo(getLogFileName()).dir();
        if (!logFileDir.exists())
        {
            QDir().mkpath(logFileDir.path());
        }

        QFile log(getLogFileName());
        if (log.open(QIODeviceBase::WriteOnly | QIODeviceBase::Append | QIODevice::Text))
        {
            QTextStream(&log) << message << '\n';
        }
        else
        {
            QTextStream(stdout) << u"ERROR: Cannot open log file: %1. Caused by (%2) %3\n"_s
                                   .arg(getLogFileName()).arg(log.error()).arg(log.errorString());
        }

#if defined(QT_DEBUG)
        defaultMessageHandler(type, context, msg);
#endif
    }

    void install()
    {
        qSetMessagePattern(MESSAGE_PATTERN);

        auto logFileName = getLogFileName();
        auto logFileDirname = QFileInfo(logFileName).dir();
        if (!logFileDirname.mkpath("."))
        {
            qWarning() << "ERROR: Cannot create log file parent directory: " << logFileDirname;
        }

        defaultMessageHandler = qInstallMessageHandler(messageHandler);
    }
}
