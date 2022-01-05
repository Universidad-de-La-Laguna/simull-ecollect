import QtQuick
import QtMultimedia
import QtQml.StateMachine as DSM
import Qt.labs.platform

import ecollect
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
    property alias audioOutputVolume: mediaPlayerAudioOutput.volume

    readonly property alias error: internal.error
    readonly property alias playingState: internal.playingState
    readonly property alias currentVideoIndex: internal.currentVideoIndex
    readonly property alias currentVideoReplay: internal.currentVideoReplay

    readonly property url sessionDataRootLocation: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
    readonly property url currentSessionDataLocation: `${sessionDataRootLocation}/${Utils.createUuid()}`
    readonly property url recordingFileUrl: `${currentSessionDataLocation}/${recordingFilename}`
    readonly property url sessionDataFileUrl: `${currentSessionDataLocation}/${sessionDataFilename}`

    signal errorOcurred

    enum PlayingState {
        StoppedState,
        CameraPreviewState,
        PausedState,
        PlayingTransitionState,
        PlayingVideoState,
        UploadingState,
        CancelingState
    }

    enum Error {
        NoError,
        CameraError,
        RecorderError,
        PlayerError,
        UploadError
    }

    function startCameraPreview() {
        internal.startCameraPreviewRequested()
    }

    function stopCameraPreview() {
        internal.stopCameraPreviewRequested()
    }

    function startSession() {
        internal.startSessionRequested()
    }

    function continueSession() {
        internal.continueSessionRequested()
    }

    function cancelSession() {
        internal.cancelSessionRequested()
    }

    function registerUserReaction(reactionId) {
        sessionLog.log(`${recorder.duration}, ${reactionId}, ${internal.currentVideoIndex}, ` +
                       `${internal.currentVideoReplay}, ${mediaPlayer.position}`);
        internal.reactionsRegistered++;
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

    AudioOutput {
        id: mediaPlayerAudioOutput
    }

    MediaPlayer {
        id: mediaPlayer

        audioOutput: mediaPlayerAudioOutput
        onErrorOccurred: (errorCode, errorString) =>
                         internal.handleError(EcollectController.PlayerError, errorString, errorCode)
    }

    Uploader {
        id: uploader
        onErrorOcurred: (errorCode, errorString) =>
                        internal.handleError(EcollectController.UploadError, errorString, errorCode)
    }

    FileLog {
        id: sessionLog
        fileLocation: root.sessionDataFileUrl
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
                signal: internal.startCameraPreviewRequested
            }

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: internal.startSessionRequested
            }
        }

        DSM.State {
            id: cameraPreviewState

            onEntered: {
                camera.start()
                captureSession.videoOutput = videoOutput
                internal.playingState = EcollectController.CameraPreviewState
            }
            onExited: {
                camera.stop()
                captureSession.videoOutput = null
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: internal.stopCameraPreviewRequested
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: root.errorOcurred
            }
        }

        DSM.State {
            id: runningSessionState
            initialState: playingTransitionState

            onEntered: {
                Utils.makeFilesystemPath(currentSessionDataLocation)
                internal.currentVideoIndex = 0
                internal.currentVideoReplay = 0
                internal.isProcessingCancelRequest = false
                mediaPlayer.videoOutput = videoOutput
                camera.start()
                recorder.record()
            }

            onExited: {
                mediaPlayer.videoOutput = null
                camera.stop()
                recorder.stop()
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: internal.cancelSessionRequested
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: root.errorOcurred
            }

            DSM.State {
                id: playingTransitionState

                onEntered: {
                    mediaPlayer.source = root.transitionVideoUrl
                    mediaPlayer.play()
                    internal.playingState = EcollectController.PlayingTransitionState
                }

                DSM.SignalTransition {
                    targetState: playingVideoState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                }
            }

            DSM.State {
                id: playingVideoState

                onEntered: {
                    internal.reactionsRegistered = 0
                    mediaPlayer.source = root.videoPlaylist[internal.currentVideoIndex]
                    mediaPlayer.play()
                    internal.playingState = EcollectController.PlayingVideoState
                }

                DSM.SignalTransition {
                    targetState: pausedState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                           && internal.reactionsRegistered == 0
                }

                DSM.SignalTransition {
                    targetState: uploadingState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                        && ++internal.currentVideoIndex === root.videoPlaylist.length
                    onTriggered: internal.currentVideoReplay = 0
                }

                DSM.SignalTransition {
                    targetState: playingTransitionState
                    signal: mediaPlayer.onPlaybackStateChanged
                    guard: mediaPlayer.playbackState === MediaPlayer.StoppedState
                }
            }

            DSM.State {
                id: pausedState

                onEntered: {
                    internal.playingState = EcollectController.PausedState
                    recorder.pause()
                }
                onExited: {
                    internal.currentVideoReplay++
                    recorder.record()
                }

                DSM.SignalTransition {
                    targetState: playingTransitionState
                    signal: internal.continueSessionRequested
                }
            }
        }

        DSM.State {
            id: uploadingState

            onEntered: {
                internal.playingState = EcollectController.UploadingState
                uploader.uploadDirectory(root.currentSessionDataLocation)
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: uploader.finished
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                onTriggered: internal.isProcessingCancelRequest = true
                signal: internal.cancelSessionRequested
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: uploader.errorOcurred
            }
        }

        DSM.State {
            id: cancelingUploadState

            onEntered: {
                internal.playingState = EcollectController.CancelingState
                uploader.cancel()
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: uploader.finished
                guard: !internal.isProcessingCancelRequest
            }

            DSM.SignalTransition {
                // Clean files if the upload was canceled by the user
                targetState: cleanupFilesState
                signal: uploader.finished
                guard: internal.isProcessingCancelRequest
            }
        }

        DSM.State {
            id: cleanupFilesState

            onEntered: {
                internal.cleanupSessionFiles()
                internal.cleanupFinished()
            }

            DSM.SignalTransition {
                targetState: stoppedState
                signal: internal.cleanupFinished
            }
        }
    }

    QtObject {
        id: internal

        property int error: EcollectController.NoError
        property int playingState: EcollectController.StoppedState
        property int currentVideoIndex: 0
        property int currentVideoReplay: 0
        property int reactionsRegistered: 0
        property bool isProcessingCancelRequest: false

        signal startCameraPreviewRequested;
        signal stopCameraPreviewRequested;
        signal startSessionRequested;
        signal continueSessionRequested;
        signal cancelSessionRequested;
        signal cleanupFinished;

        function handleError(error, errorString, sourceErrorCode) {
            var tag = "Controller";
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

            case EcollectController.UploadError:
                tag = "Upload"
                break
            }

            var message = `[${tag}]: `
            message += error !== undefined ? `Error (${error}): ` : ""
            message += errorString !== undefined ? errorString : ""
            console.warn(message);

            internal.error = error;
            root.errorOcurred();
        }

        function cleanupSessionFiles() {
            Utils.removeFilesystemPath(root.currentSessionDataLocation)
        }
    }
}
