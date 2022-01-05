import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import QtQml.StateMachine as DSM

import ecollect
import ecollect.Managers
import ecollect.Dialogs
import ecollect.Layouts
import ecollect.Reactions

ApplicationWindow {

    onClosing: function(close) {
        if (! (runningSessionState.active || cancelingUploadState.active))
            return

        close.accepted = false
        appManager.cancelSession()
    }

    MainWindowLayout {
        id: currentView

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        rightSidebar: Reactions {
            model: Constants.reactions
            enabled: appManager.playingState === EcollectManager.PlayingVideoState
            onReactionClicked: (name) => appManager.registerUserReaction(name)
        }

        footerContent: Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                text: Math.round(volumeSlider.value * 100)
                width: 1
                anchors.verticalCenter: parent.verticalCenter
                rightPadding: Constants.spacingUnit * 0.5
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }

            Slider {
                id: volumeSlider

                from: 0.0;
                to: 1.0
                value: 1.0
            }

            Label {
                text: UiUtils.mapVolumeValueToIcon(volumeSlider.value)
                font.family: "Material Design Icons"
                font.pointSize: 18
                opacity: 0.75
                width: 1
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    WelcomeDialog {
        id: welcomeDialog
        visible: welcomeState.active
    }


    SessionPausedDialog {
        id: sessionPausedDialog

        visible: appManager.playingState === EcollectManager.PausedState
        onAccepted: appManager.continueSession()
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

    EcollectManager {
        id: appManager

        videoOutput: videoOutput
        recordingMediaFormat.fileFormat: Constants.recordingMediaFormat
        recordingMediaFormat.videoCodec: Constants.recordingVideoCodec
        recordingQuality: Constants.recordingQuality
        videoPlaylist: Constants.videoPlaylist
        audioOutputVolume: volumeSlider.value

        TutorialManager {
            id: tutorialManager
        }

        ErrorDialogManager {
            id: errorDialog
        }
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

            onEntered: tutorialManager.start()

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: tutorialManager.finished
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: tutorialManager.aborted
            }
        }

        DSM.State {
            id: runningSessionState
            initialState: doingSurveyState

            DSM.SignalTransition {
                targetState: errorState
                signal: appManager.errorOcurred
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: appManager.onPlayingStateChanged
                guard: appManager.playingState === EcollectManager.CancelingState
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: appManager.onPlayingStateChanged
                guard: appManager.playingState === EcollectManager.StoppedState
            }

            DSM.State {
                id: doingSurveyState

                onEntered: appManager.startSession()

                DSM.SignalTransition {
                    targetState: uploadingResultsState
                    signal: appManager.onPlayingStateChanged
                    guard: appManager.playingState === EcollectManager.UploadingState
                }
            }

            DSM.State {
                id: uploadingResultsState

                DSM.SignalTransition {
                    targetState: goodbyeState
                    signal: appManager.onPlayingStateChanged
                    guard: appManager.playingState === EcollectManager.StoppedState
                }
            }
        }

        DSM.State {
            id: errorState

            onEntered: errorDialog.show()

            DSM.SignalTransition {
                targetState: finishState
                signal: errorDialog.closed
                guard: appManager.playingState === EcollectManager.StoppedState
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: errorDialog.closed
                guard: appManager.playingState === EcollectManager.CancelingState
            }
        }

        DSM.State {
            id: cancelingUploadState

            DSM.SignalTransition {
                targetState: finishState
                signal: appManager.onPlayingStateChanged
                guard: appManager.playingState === EcollectManager.StoppedState
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
