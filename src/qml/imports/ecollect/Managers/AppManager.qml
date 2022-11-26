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
    readonly property url recordingFileUrl: `${appManager.sessionDataLocation}/${Constants.recordingFilename}`
    readonly property url sessionDataFileUrl: `${appManager.sessionDataLocation}/${Constants.sessionDataFilename}`

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

        captureSession: captureSession
        videoOutputControl: videoOutput
        reactionsControl: reactions
        volumeControl: volumeControl
    }

    SessionManager {
        id: sessionManager
        captureSession: captureSession
    }

    ErrorDialogManager {
        id: errorDialog
    }

    // Multimedia components

    CaptureSession {
        id: captureSession

        camera: Camera {
            id: camera
            onErrorOccurred: (errorCode, errorString) =>
                             logError(EcollectManager.CameraError, errorCode, errorString)
        }

        recorder: MediaRecorder {
            id: recorder

            outputLocation: root.recordingFileUrl
            quality: Constants.recordingQuality
            mediaFormat.fileFormat: Constants.recordingMediaFormat
            mediaFormat.videoCodec: Constants.recordingVideoCodec
            onActualLocationChanged: console.log(`Session data location: ${actualLocation}`)
            onErrorOccurred: (errorCode, errorString) =>
                             logError(AppManager.RecorderError, errorCode, errorString)
        }

        function startCameraRecording() {
            captureSession.videoOutput = null
            camera.start()
            recorder.record()
        }

        function stopCameraRecording() {
            camera.stop()
            recorder.stop()
        }

        function startCameraPreview() {
            captureSession.videoOutput = videoOutput
            camera.start()
        }

        function stopCameraPreview() {
            camera.stop()
            captureSession.videoOutput = null
        }
    }

    // UI components

    MainWindowLayout {
        VideoOutput {
            id: videoOutput

            anchors.fill: parent

//            VideoProgressBar {
//                mediaPlayer: sessionManager.mediaPlayer
//                backgroundColor: Constants.videoProgressBarBackground
//                color: Constants.videoProgressBarColor
//                length: Constants.videoProgressBarLength
//                thick: Constants.videoProgressBarThick
//                visible: sessionManager.playingState === SessionManager.PlayingVideoState
//            }
        }

        rightSidebar: Reactions {
            id: reactions

            anchors.rightMargin: width * 0.3

            model: Constants.reactions
            enabled: sessionManager.playingState === SessionManager.PlayingVideoState
            useDefaultIcons: tutorialManager.aboutReactionsStateActive
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

    UserProfileDialog {
        id: userProfileDialog

        visible: sessionManager.playingState === SessionManager.RequestingUserProfileState
        onAccepted: {
            sessionManager.userProfile.gender = userProfileDialog.gender
            sessionManager.userProfile.age = userProfileDialog.age
            sessionManager.userProfile.nationality = userProfileDialog.nationality
            sessionManager.resume()
        }
        onRejected: sessionManager.cancel()
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
