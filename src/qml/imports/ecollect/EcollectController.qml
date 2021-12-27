import QtQuick
import QtMultimedia
import QtQml.StateMachine as DSM
import Qt.labs.platform

import ecollect.Native

Item {
    id: root

    property string recordingFilename: Constants.recordingFilename
    property alias recordingMediaFormat: recorder.mediaFormat
    property alias recordingQuality: recorder.quality
    property string sessionDataFilename: Constants.sessionDataFilename
    property url transitionVideoUrl: Constants.transitionVideoUrl
    property VideoOutput videoOutput
    property var videoPlaylist: []

    readonly property alias error: internal.error
    readonly property alias playingState: internal.playingState
    readonly property alias currentVideoIndex: internal.currentVideoIndex
    readonly property alias currentVideoReplay: internal.currentVideoReplay

    readonly property url sessionDataRootLocation: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
    readonly property url currentSessionDataLocation: `${sessionDataRootLocation}/${Utils.createUuid()}`
    readonly property url recordingFileUrl: `${currentSessionDataLocation}/${recordingFilename}`
    readonly property url sessionDataFileUrl: `${currentSessionDataLocation}/${sessionDataFilename}`

    signal onErrorOcurred

    enum PlayingState {
        StoppedState,
        CameraPreviewState,
        PausedState,
        PlayingTransitionState,
        PlayingVideoState,
        UploadingState,
        CancelingUploadState
    }

    enum Error {
        NoError,
        CameraError,
        RecorderError,
        PlayerError,
        UploadError
    }

    function startCameraPreview() {
        internal.onStartCameraPreview()
    }

    function stopCameraPreview() {
        internal.onStopCameraPreview()
    }

    function startSession() {
        internal.onStartSession()
    }

    function continueSession() {
        internal.onContinueSession()
    }

    function stopSession() {
        internal.onStopSession()
    }

    CaptureSession {
        id: captureSession

        camera: Camera {
            id: camera

            onErrorOccurred: (errorCode, errorString) =>
                             internal.handleError(EcollectController.CameraError, errorString, errorCode)
        }

        recorder: MediaRecorder {
            id: recorder

            outputLocation: root.recordingFileUrl
            onActualLocationChanged: console.log(`Session data location: ${actualLocation}`)
            onErrorOccurred: (errorCode, errorString) =>
                             internal.handleError(EcollectController.RecorderError, errorString, errorCode)
        }
    }

    MediaPlayer {
        id: mediaPlayer

        audioOutput: AudioOutput {}
        onErrorOccurred: (errorCode, errorString) =>
                         internal.handleError(EcollectController.PlayerError, errorString, errorCode)
    }

    DSM.StateMachine {
        id: stateMachine

        initialState: stoppedState
        running: true

        DSM.State {
            id: stoppedState

            onEntered: internal.playingState = EcollectController.StoppedState

            DSM.SignalTransition {
                targetState: cameraPreviewState
                signal: internal.onStartCameraPreview
            }

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: internal.onStartSession
            }
        }

        DSM.State {
            id: cameraPreviewState

            onEntered: function() {
                camera.start()
                captureSession.videoOutput = videoOutput
                internal.playingState = EcollectController.CameraPreviewState
            }
            onExited: function() {
                camera.stop()
                captureSession.videoOutput = null
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: internal.onStopCameraPreview
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: root.onErrorOcurred
            }
        }

        DSM.State {
            id: runningSessionState
            initialState: playingTransitionState

            onEntered: function() {
                Utils.makeFilesystemPath(currentSessionDataLocation)
                internal.currentVideoIndex = 0
                internal.currentVideoReplay = 0
                mediaPlayer.videoOutput = videoOutput
                camera.start()
                recorder.record()
            }

            onExited: function() {
                mediaPlayer.videoOutput = null
                camera.stop()
                recorder.stop()
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: internal.onStopSession
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: root.onErrorOcurred
            }

            DSM.State {
                id: playingTransitionState

                onEntered: function() {
                    internal.playingState = EcollectController.PlayingTransitionState
                    mediaPlayer.source = root.transitionVideoUrl
                    mediaPlayer.play()
                }

                DSM.SignalTransition {
                    targetState: playingVideoState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                }
            }

            DSM.State {
                id: playingVideoState

                onEntered: function() {
                    internal.playingState = EcollectController.PlayingVideoState
                    mediaPlayer.source = root.videoPlaylist[internal.currentVideoIndex]
                    mediaPlayer.play()
                }

                DSM.SignalTransition {
                    targetState: uploadingState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                        && ++internal.currentVideoIndex === root.videoPlaylist.length
                }

                DSM.SignalTransition {
                    targetState: playingTransitionState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                }
            }

            DSM.State {
                id: pausedState
            }
        }

        DSM.State {
            id: uploadingState

            onEntered: function() {
                internal.playingState = EcollectController.UploadingState
                Uploader.uploadDirectory(root.currentSessionDataLocation)
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: Uploader.onFinished
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: Uploader.errorOcurred
            }
        }

        DSM.State {
            id: cancelingUploadState

            onEntered: Uploader.cancel()

            DSM.SignalTransition {
                targetState: stoppedState
                signal: Uploader.canceled
            }
        }

        DSM.State {
            id: cleanupFilesState

            onEntered: function() {
                Utils.removeFilesystemPath(currentSessionDataLocation)
                internal.onCleanupFinished()
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: internal.onCleanupFinished
            }
        }
    }

    QtObject {
        id: internal

        property int error: EcollectController.NoError
        property int playingState: EcollectController.StoppedState
        property int currentVideoIndex: 0
        property int currentVideoReplay: 0

        signal onStartCameraPreview;
        signal onStopCameraPreview;
        signal onStartSession;
        signal onContinueSession;
        signal onStopSession;
        signal onCleanupFinished;

        function handleError(error, errorString, sourceErrorCode) {
            switch(error) {
            case EcollectController.CameraError:
                tag = "Camera"
                break

            case EcollectController.RecorderError:
                tag = "Recorder"
                break

            case EcollectController.PlayerError:
                tag = "MediaPlayer"
                break

            default:
                tag = "Controller"
            }

            var message = `[${tag}]: `
            message += error !== undefined ? `Error (${error}): ` : ""
            message += errorString !== undefined ? errorString : ""
            console.warn(message);

            internal.error = error;
            root.onErrorOcurred();
        }
    }
}
