import QtQuick
import QtMultimedia
import QtQml.StateMachine as DSM

import ecollect

Item {
    id: root

    readonly property bool active: internal.playingState !== SessionManager.StoppedState
    readonly property alias error: internal.error
    readonly property alias playingState: internal.playingState

    property CaptureSession captureSession
    property var userProfile: QtObject {
        property string gender
        property int age
        property string nationality
    }

    signal errorOccurred

    enum PlayingState {
        StoppedState,
        PausedState,
        RequestingUserProfileState,
        PlayingTransitionState,
        PlayingVideoState,
        UploadingState,
        CancelingState
    }

    function start() {
        if (root.active) return;
        stateMachine.start()
    }

    function resume() {
        internal.resumeRequested()
    }

    function cancel() {
        internal.cancelRequested()
    }

    function registerUserReaction(reactionId) {
        sessionLog.log(`R, ${recorder.duration}, ${reactionId}, ${internal.currentVideoIndex}, ` +
                       `${internal.currentVideoReplay}, ${mediaPlayer.position}`);
        internal.reactionsRegistered++;
    }

    property var mediaPlayer: MediaPlayer {
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
            internal.handleError(AppManager.UploadError, errorString)
        }
    }

    FileLog {
        id: sessionLog
        fileLocation: appManager.sessionDataFileUrl
    }

    Connections {
        target: root.captureSession.camera
        enabled: root.active

        function onErrorOccurred(errorCode, errorString) {
            internal.handleError(AppManager.CameraError, errorString)
        }
    }

    Connections {
        target: root.captureSession.recorder
        enabled: root.active

        function onErrorOccurred(errorCode, errorString) {
            internal.handleError(AppManager.RecorderError, errorString)
        }
    }

    DSM.StateMachine {
        id: stateMachine

        initialState: requestingUserProfileState

        DSM.State {
            id: requestingUserProfileState

            onEntered: {
                Utils.makeFilesystemPath(appManager.sessionDataLocation)
                internal.playingState = SessionManager.RequestingUserProfileState
            }

            DSM.SignalTransition {
                targetState: runningSessionState
                signal: internal.resumeRequested
                guard: {
                    sessionLog.log(`P, ${userProfile.gender}, ${userProfile.age}, ${userProfile.nationality}`)
                    return true
                }
            }

            DSM.SignalTransition {
                targetState: cleanupFilesState
                signal: internal.cancelRequested
            }
        }

        DSM.State {
            id: runningSessionState
            initialState: playingTransitionState

            onEntered: {
                internal.videoPlaylist = Utils.readPlaylist(internal.videoPlaylistUrl)
                internal.currentVideoIndex = 0
                internal.currentVideoReplay = 0
                internal.isProcessingCancelRequest = false
                mediaPlayer.videoOutput = videoOutput
                captureSession.startCameraRecording()
            }

            onExited: {
                captureSession.stopCameraRecording()
                mediaPlayer.videoOutput = null
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
                    mediaPlayer.audioOutput.muted = true
                    mediaPlayer.play()
                    internal.playingState = SessionManager.PlayingTransitionState
                }

                onExited: {
                    mediaPlayer.audioOutput.muted = false
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
                    targetState: playingVideoState
                    signal: internal.resumeRequested
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

        DSM.FinalState {
            id: stoppedState
        }

        onFinished: internal.playingState = SessionManager.StoppedState
    }

    QtObject {
        id: internal

        readonly property url transitionVideoUrl: Constants.transitionVideoUrl
        readonly property url videoPlaylistUrl: Constants.videoPlaylistUrl

        property int error: AppManager.NoError
        property int playingState: SessionManager.StoppedState
        property var videoPlaylist: []
        property int currentVideoIndex: 0
        property int currentVideoReplay: 0
        property int reactionsRegistered: 0
        property bool isProcessingCancelRequest: false

        signal resumeRequested;
        signal cancelRequested;
        signal cleanupFinished;

        function cleanupSessionFiles() {
            Utils.removeFilesystemPath(appManager.sessionDataLocation)
        }

        function handleError(error, errorString) {
            internal.error = error;
            root.errorOccurred();
        }
    }
}
