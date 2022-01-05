import QtQuick
import QtMultimedia
import QtQml.StateMachine as DSM

import ecollect

Item {
    id: root

    readonly property bool active: internal.playingState !== SessionManager.StoppedState
    readonly property alias error: internal.error
    readonly property alias playingState: internal.playingState

    property Camera camera
    property VideoOutput videoOutput

    signal errorOccurred

    enum PlayingState {
        StoppedState,
        PausedState,
        PlayingTransitionState,
        PlayingVideoState,
        UploadingState,
        CancelingState
    }

    function start() {
        internal.startRequested()
    }

    function resume() {
        internal.resumenRequested()
    }

    function cancel() {
        internal.cancelRequested()
    }

    function registerUserReaction(reactionId) {
        sessionLog.log(`${recorder.duration}, ${reactionId}, ${internal.currentVideoIndex}, ` +
                       `${internal.currentVideoReplay}, ${mediaPlayer.position}`);
        internal.reactionsRegistered++;
    }

    CaptureSession {
        id: captureSession

        camera: root.camera
        recorder: MediaRecorder {
            id: recorder

            outputLocation: internal.recordingFileUrl
            quality: internal.recordingQuality
            mediaFormat.fileFormat: internal.recordingMediaFileFormat
            mediaFormat.videoCodec: internal.recordingMediaVideoCodec
            onActualLocationChanged: console.log(`Session data location: ${actualLocation}`)
            onErrorOccurred: function(errorCode, errorString) {
                appManager.logError(AppManager.RecorderError, errorCode, errorString)
                internal.handleError(AppManager.RecorderError)
            }
        }
    }

    MediaPlayer {
        id: mediaPlayer

        audioOutput: AudioOutput {
            volume: volumeControl.value
        }
        onErrorOccurred: function(errorCode, errorString) {
            appManager.logError(AppManager.PlayerError, errorCode, errorString)
            internal.handleError(AppManager.PlayerError)
        }
    }

    Uploader {
        id: uploader
        onErrorOccurred: function(errorCode, errorString) {
            appManager.logError(AppManager.UploadError, errorCode, errorString)
            internal.handleError(AppManager.UploadError)
        }
    }

    FileLog {
        id: sessionLog
        fileLocation: internal.sessionDataFileUrl
    }

    Connections {
        target: root.camera
        enabled: root.active

        function onErrorOccurred(errorCode, errorString) {
            internal.handleError(AppManager.CameraError)
        }
    }

    DSM.StateMachine {
        id: stateMachine

        initialState: stoppedState
        running: true

        DSM.State {
            id: stoppedState

            onEntered: internal.playingState = SessionManager.StoppedState

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: internal.startRequested
            }
        }

        DSM.State {
            id: runningSessionState
            initialState: playingTransitionState

            onEntered: {
                Utils.makeFilesystemPath(appManager.sessionDataLocation)
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
                signal: internal.cancelRequested
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: root.errorOccurred
            }

            DSM.State {
                id: playingTransitionState

                onEntered: {
                    mediaPlayer.source = internal.transitionVideoUrl
                    mediaPlayer.play()
                    internal.playingState = SessionManager.PlayingTransitionState
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
                    mediaPlayer.source = internal.videoPlaylist[internal.currentVideoIndex]
                    mediaPlayer.play()
                    internal.playingState = SessionManager.PlayingVideoState
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
                        && ++internal.currentVideoIndex === internal.videoPlaylist.length
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
                    internal.playingState = SessionManager.PausedState
                    recorder.pause()
                }
                onExited: {
                    internal.currentVideoReplay++
                    recorder.record()
                }

                DSM.SignalTransition {
                    targetState: playingTransitionState
                    signal: internal.resumenRequested
                }
            }
        }

        DSM.State {
            id: uploadingState

            onEntered: {
                internal.playingState = SessionManager.UploadingState
                uploader.uploadDirectory(appManager.sessionDataLocation)
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: uploader.finished
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                onTriggered: internal.isProcessingCancelRequest = true
                signal: internal.cancelRequested
            }

            DSM.SignalTransition {
                targetState: cancelingUploadState
                signal: uploader.errorOccurred
            }
        }

        DSM.State {
            id: cancelingUploadState

            onEntered: {
                internal.playingState = SessionManager.CancelingState
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

        readonly property int recordingMediaFileFormat: Constants.recordingMediaFormat
        readonly property int recordingMediaVideoCodec: Constants.recordingVideoCodec
        readonly property int recordingQuality: Constants.recordingQuality
        readonly property url transitionVideoUrl: Constants.transitionVideoUrl
        readonly property var videoPlaylist: Constants.videoPlaylist

        readonly property url recordingFileUrl: `${appManager.sessionDataLocation}/${Constants.recordingFilename}`
        readonly property url sessionDataFileUrl: `${appManager.sessionDataLocation}/${Constants.sessionDataFilename}`

        property int error: AppManager.NoError
        property int playingState: SessionManager.StoppedState
        property int currentVideoIndex: 0
        property int currentVideoReplay: 0
        property int reactionsRegistered: 0
        property bool isProcessingCancelRequest: false

        signal startCameraPreviewRequested;
        signal stopCameraPreviewRequested;
        signal startRequested;
        signal resumenRequested;
        signal cancelRequested;
        signal cleanupFinished;

        function cleanupSessionFiles() {
            Utils.removeFilesystemPath(appManager.sessionDataLocation)
        }

        function handleError(error) {
            internal.error = error;
            root.errorOccurred();
        }
    }
}
