import QtQuick
import QtQuick.Controls

import ecollect

Window {
    width: Constants.width
    height: Constants.height
    title: Constants.applicatioName
    visible: true
    visibility: Utils.showFullscreen() ? Window.FullScreen : Window.AutomaticVisibility

    Pane {
        anchors.fill: parent
    }
}
