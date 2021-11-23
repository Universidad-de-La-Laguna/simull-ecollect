import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import QtQml.StateMachine as DSM

import ecollect
import ecollect.Dialogs
import ecollect.Layouts
import ecollect.Reactions
import ecollect.Utils

ApplicationWindow {

    MainWindowLayout {
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        rightSidebar: Reactions {
            model: Constants.reactions
            enabled: false
        }
    }

    WelcomeDialog {
        id: welcomeDialog
        anchors.centerIn: parent
        visible: welcomeState.active
    }

    Camera {
        id: camera
    }

    DSM.StateMachine {
        id: appStateMachine
        initialState: welcomeState

        running: true

        DSM.State {
            id: welcomeState

            DSM.SignalTransition {
                targetState: tutorialState
                signal: welcomeDialog.accepted
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: welcomeDialog.rejected
            }
        }

        DSM.State {
            id: tutorialState
        }

        DSM.State {
            id: runningExperimentState
        }

        DSM.State {
            id: uploadingResultsState
        }

        DSM.FinalState {
            id: finishState
        }

        onFinished: Qt.quit()
    }
}
