import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

import ecollect
import ecollect.Dialogs
import ecollect.MediaViewer

Window {
    width: Constants.width
    height: Constants.height
    title: Constants.applicatioName
    visible: true

    Pane {
        anchors.fill: parent
    }

    PageLayout {
        MediaViewer {
            id: mediaViewer

            reactions.model: Constants.reactions
            reactions.enabled: false
        }
    }

    IntroDialog {
        id: introDialog
        anchors.centerIn: parent

        onAccepted: camera.videoOutput = MediaPlayer.videoOutput
    }

    Camera {
        id: camera
    }

    Component.onCompleted: introDialog.visible = true
}
