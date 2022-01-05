import QtQuick
import QtQuick.Controls

import ecollect
import ecollect.Managers

ApplicationWindow {

    onClosing: (closeEvent) => appManager.close(closeEvent)

    AppManager {
        id: appManager
    }
}
