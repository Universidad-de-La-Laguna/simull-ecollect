import QtQuick
import QtMultimedia
import Qt.labs.platform

import ecollect.Native

Item {
    id: root

    enum PlayingState {
        StoppedState,
        PlayingInBetweenState,
        PlayingState
    }

    readonly property alias playingState: internal.playingState
    readonly property alias currentVideoIndex: internal.currentVideoIndex

    readonly property url currentSessionDataLocation: `${sessionDataRootLocation}/${Utils.createUuid()}`
    readonly property url recordingFileUrl: `${currentSessionDataLocation}/${recordingFilename}`
    readonly property url sessionDataFileUrl: `${currentSessionDataLocation}/${sessionDataFilename}`

    property var videoPlaylist: []
    property VideoOutput videoOutput
    property alias recordingMediaFormat: recorder.mediaFormat
    property alias recordingQuality: recorder.quality

    property url sessionDataRootLocation: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
    property string recordingFilename: Constants.recordingFilename
    property string sessionDataFilename: Constants.sessionDataFilename
    property url inBetweenVideoUrl: Constants.inBetweenVideoUrl

    CaptureSession {
        id: captureSession

        camera: Camera {
            id: camera
            onErrorOccurred: (error, errorString) => console.log(`[Camera]: (${error}) ${errorString}`)
        }

        recorder: MediaRecorder {
            id: recorder
            outputLocation: root.recordingFileUrl

            onErrorOccurred: (error, errorString) => console.log(`[MediaRecorder]: (${error}) ${errorString}`)
        }
    }

    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput {}

        onErrorOccurred: (error, errorString) => console.log(`[MediaPlayer]: (${error}) ${errorString}`)
    }

    QtObject {
        id: internal
        property int playingState: EcollectController.StoppedState
        property int currentVideoIndex: 0
        property bool hasStopCameraWhenStopCameraPreview: false
    }

    function startCameraPreview() {
        mediaPlayer.videoOutput = null
        captureSession.videoOutput = videoOutput
        if (! camera.active) {
            camera.start()
            internal.hasStopCameraWhenStopCameraPreview = true
        }
    }

    function stopCameraPreview() {
        captureSession.videoOutput = null
        mediaPlayer.videoOutput = videoOutput
        if (internal.hasStopCameraWhenStopCameraPreview) {
            camera.stop()
            internal.hasStopCameraWhenStopCameraPreview = false
        }
    }

    function startExperiment() {
        console.log(`Creating session data location: ${currentSessionDataLocation}`)
        if (!Utils.makeFilesystemPath(currentSessionDataLocation))
            console.log("makeFilesystemPath() failed")
        camera.start()
        recorder.record()

        mediaPlayer.stop()
        mediaPlayer.videoOutput = videoOutput
        playNextPlaylistVideo(0)
    }

    function playNextPlaylistVideo(startIndex = -1) {
        if (startIndex >= 0) internal.currentVideoIndex = startIndex
        if (internal.currentVideoIndex >= videoPlaylist.length) {
            internal.currentVideoIndex = videoPlaylist.length
            internal.playingState = EcollectController.PlayingState.StoppedState
            return
        }

        mediaPlayer.onPlaybackStateChanged.connect(handleMediaPlayerStateChanged)
        playInBetweenVideo()
    }

    function playInBetweenVideo() {
        mediaPlayer.source = inBetweenVideoUrl
        internal.playingState = EcollectController.PlayingInBetweenState
        mediaPlayer.play()
    }

    function handleMediaPlayerStateChanged() {
        if (mediaPlayer.playbackState !== MediaPlayer.StoppedState) return

        if (internal.playingState === EcollectController.PlayingInBetweenState) {
            mediaPlayer.source = videoPlaylist[internal.currentVideoIndex]
            mediaPlayer.play()
            internal.playingState = EcollectController.PlayingState
        }
        else if (internal.playingState === EcollectController.PlayingState) {
            ++internal.currentVideoIndex
            if (internal.currentVideoIndex < videoPlaylist.length) {
                playInBetweenVideo()
            }
            else {
                mediaPlayer.onPlaybackStateChanged.disconnect(handleMediaPlayerStateChanged)
                handleExperimentStopping()
            }
        }
    }

    function handleExperimentStopping() {
        camera.stop()
        recorder.stop()
        internal.playingState = EcollectController.StoppedState
    }
}
