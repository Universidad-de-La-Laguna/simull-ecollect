import QtMultimedia
import QtQuick
import QtQml.StateMachine as DSM
import Qt.labs.platform

import ecollect
import ecollect.Controls
import ecollect.Controls.Reactions
import ecollect.Dialogs
import ecollect.Layouts
import ecollect.Managers

Manager {
    id: root

    readonly property url sessionDataRootLocation: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
    readonly property url sessionDataLocation: `${sessionDataRootLocation}/${Utils.createUuid()}`

    enum Error {
        NoError,
        CameraError,
        RecorderError,
        PlayerError,
        UploadError
    }

    function close(closeEvent) {
        if (! sessionManager.active)
            return

        closeEvent.accepted = false
        sessionManager.cancel()
    }

    function logError(error, underlyingErrorCode, underlyingErrorString) {
        var tag = "Internal";
        switch(error) {
        case AppManager.CameraError:
            tag = "Camera"
            break

        case AppManager.RecorderError:
            tag = "Recorder"
            break

        case AppManager.PlayerError:
            tag = "MediaPlayer"
            break

        case AppManager.UploadError:
            tag = "Upload"
            break
        }

        var message = `[${tag}]`
        message += underlyingErrorCode !== undefined ? `: Error (${underlyingErrorCode})` : ""
        message += underlyingErrorString !== undefined ? `: ${underlyingErrorString}` : ""
        console.warn(message);
    }

    DSM.StateMachine {
        initialState: welcomeState
        running: true

        DSM.State {
            id: welcomeState

            DSM.SignalTransition {
                targetState: sessionState
                signal: welcomeDialog.accepted
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: welcomeDialog.rejected
            }
        }

        DSM.State {
            id: tutorialState

            initialState: playingTutorialState

            DSM.State {
                id: playingTutorialState

                onEntered: tutorialManager.start()

                DSM.SignalTransition {
                    targetState: tutorialErrorState
                    signal: tutorialManager.errorOccurred
                }

                DSM.SignalTransition {
                    targetState: sessionState
                    signal: tutorialManager.finished
                }

                DSM.SignalTransition {
                    targetState: finishState
                    signal: tutorialManager.canceled
                }
            }
        }

        DSM.State {
            id: tutorialErrorState

            onEntered: errorDialog.show(tutorialManager.error)

            DSM.SignalTransition {
                targetState: finishState
                signal: errorDialog.closed
            }
        }

        DSM.State {
            id: sessionState
            initialState: runningSessionState

            DSM.SignalTransition {
                targetState: sessionErrorState
                signal: sessionManager.errorOccurred
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: sessionManager.onPlayingStateChanged
                guard: sessionManager.playingState === SessionManager.CancelingState
            }

            DSM.SignalTransition {
                targetState: finishState
                signal: sessionManager.onPlayingStateChanged
                guard: sessionManager.playingState === SessionManager.StoppedState
            }

            DSM.State {
                id: runningSessionState

                onEntered: sessionManager.start()

                DSM.SignalTransition {
                    targetState: uploadingResultsState
                    signal: sessionManager.onPlayingStateChanged
                    guard: sessionManager.playingState === SessionManager.UploadingState
                }
            }

            DSM.State {
                id: uploadingResultsState

                DSM.SignalTransition {
                    targetState: goodbyeState
                    signal: sessionManager.onPlayingStateChanged
                    guard: sessionManager.playingState === SessionManager.StoppedState
                }
            }
        }

        DSM.State {
            id: sessionErrorState

            onEntered: errorDialog.show(sessionManager.error)

            DSM.SignalTransition {
                targetState: finishState
                signal: errorDialog.closed
                guard: sessionManager.playingState === SessionManager.StoppedState
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: errorDialog.closed
                guard: sessionManager.playingState === SessionManager.CancelingState
            }
        }

        DSM.State {
            id: cancelingUploadState

            DSM.SignalTransition {
                targetState: finishState
                signal: sessionManager.onPlayingStateChanged
                guard: sessionManager.playingState === SessionManager.StoppedState
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

    // Manager components

    TutorialManager {
        id: tutorialManager
        camera: camera
        videoOutput: videoOutput
    }

    SessionManager {
        id: sessionManager
        camera: camera
        videoOutput: videoOutput
    }

    ErrorDialogManager {
        id: errorDialog
    }

    // Multimeda components

    Camera {
        id: camera
        onErrorOccurred: (errorCode, errorString) =>
                         logError(EcollectManager.CameraError, errorCode, errorString)
    }

    // UI components

    MainWindowLayout {
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        rightSidebar: Reactions {
            model: Constants.reactions
            enabled: sessionManager.playingState === SessionManager.PlayingVideoState
            onReactionClicked: (name) => sessionManager.registerUserReaction(name)
        }

        footerContent: VolumeControl {
            id: volumeControl
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    WelcomeDialog {
        id: welcomeDialog
        visible: welcomeState.active
    }

    SessionPausedDialog {
        id: sessionPausedDialog

        visible: sessionManager.playingState === SessionManager.PausedState
        onAccepted: sessionManager.resume()
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
}
