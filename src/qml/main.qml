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

    onClosing: function(close) {
        if (! (runningSessionState.active || cancelingUploadState.active))
            return

        close.accepted = false
        controller.cancelSession()
    }

    EcollectController {
        id: controller

        videoOutput: videoOutput
        recordingMediaFormat.fileFormat: Constants.recordingMediaFormat
        recordingMediaFormat.videoCodec: Constants.recordingVideoCodec
        recordingQuality: Constants.recordingQuality
        videoPlaylist: Constants.videoPlaylist
    }

    MainWindowLayout {
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        rightSidebar: Reactions {
            model: Constants.reactions
            enabled: controller.playingState === EcollectController.PlayingVideoState
        }
    }

    ErrorDialogController {
        id: errorDialog

        anchors.centerIn: parent
        appController: controller
    }

    WelcomeDialog {
        id: welcomeDialog
        visible: welcomeState.active
    }

    UploadingDialog {
        id: uploadingDialog
        visible: uploadingResultsState.active
    }

    CancelingUploadDialog {
        id: cancelingUploadDialog
        visible: cancelingUploadState.active
    }

    GoodbyeDialog {
        id: goodbyeDialog
        visible: goodbyeState.active
    }

    DSM.StateMachine {
        id: appStateMachine

        initialState: welcomeState
        running: true

        DSM.State {
            id: welcomeState

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: welcomeDialog.accepted
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: welcomeDialog.rejected
            }
        }

        DSM.State {
            id: tutorialState

            onEntered: controller.startCameraPreview()
            onExited: controller.stopCameraPreview()
        }

        DSM.State {
            id: runningSessionState
            initialState: doingSurveyState

            DSM.SignalTransition {
                targetState: errorState
                signal: controller.errorOcurred
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: controller.onPlayingStateChanged
                guard: controller.playingState === EcollectController.CancelingState
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: controller.onPlayingStateChanged
                guard: controller.playingState === EcollectController.StoppedState
            }

            DSM.State {
                id: doingSurveyState

                onEntered: controller.startSession()

                DSM.SignalTransition {
                    targetState: uploadingResultsState
                    signal: controller.onPlayingStateChanged
                    guard: controller.playingState === EcollectController.UploadingState
                }
            }

            DSM.State {
                id: uploadingResultsState

                DSM.SignalTransition {
                    targetState: goodbyeState
                    signal: controller.onPlayingStateChanged
                    guard: controller.playingState === EcollectController.StoppedState
                }
            }
        }

        DSM.State {
            id: errorState

            onEntered: errorDialog.show()

            DSM.SignalTransition {
                targetState: finishState
                signal: errorDialog.closed
                guard: controller.playingState === EcollectController.StoppedState
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: errorDialog.closed
                guard: controller.playingState === EcollectController.CancelingState
            }
        }

        DSM.State {
            id: cancelingUploadState

            DSM.SignalTransition {
                targetState: finishState
                signal: controller.onPlayingStateChanged
                guard: controller.playingState === EcollectController.StoppedState
            }
        }

        DSM.State {
            id: goodbyeState

            DSM.SignalTransition {
                targetState: finishState
                signal: goodbyeDialog.closed
            }
        }

        DSM.FinalState {
            id: finishState
        }

        onFinished: Qt.quit()
    }
}
