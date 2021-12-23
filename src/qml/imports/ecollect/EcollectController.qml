import QtQuick
import QtMultimedia
import Qt.labs.platform

import ecollect.Native

Item {
    id: root

    enum PlayingState {
        StoppedState,
        PlayingInBetweenState,
        PlayingState,
        UploadingState
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

    function startSession() {
        console.log(`Creating session data location: ${currentSessionDataLocation}`)
        if (!Utils.makeFilesystemPath(currentSessionDataLocation))
            console.log("makeFilesystemPath() failed")
        camera.start()
        recorder.record()

        mediaPlayer.stop()
        mediaPlayer.videoOutput = videoOutput
        internal.playNextPlaylistVideo(0)
    }

    QtObject {
        id: internal
        property int playingState: EcollectController.StoppedState
        property int currentVideoIndex: 0
        property bool hasStopCameraWhenStopCameraPreview: false

        function playNextPlaylistVideo(startIndex = -1) {
            if (startIndex >= 0) internal.currentVideoIndex = startIndex
            if (currentVideoIndex >= videoPlaylist.length) {
                currentVideoIndex = videoPlaylist.length
                playingState = EcollectController.StoppedState
                return
            }

            mediaPlayer.onPlaybackStateChanged.connect(handleMediaPlayerStateChanged)
            playInBetweenVideo()
        }

        function playInBetweenVideo() {
            mediaPlayer.source = inBetweenVideoUrl
            playingState = EcollectController.PlayingInBetweenState
            mediaPlayer.play()
        }

        function handleMediaPlayerStateChanged() {
            if (mediaPlayer.playbackState !== MediaPlayer.StoppedState) return

            if (playingState === EcollectController.PlayingInBetweenState) {
                mediaPlayer.source = videoPlaylist[currentVideoIndex]
                mediaPlayer.play()
                playingState = EcollectController.PlayingState
            }
            else if (playingState === EcollectController.PlayingState) {
                ++currentVideoIndex
                if (currentVideoIndex < videoPlaylist.length) {
                    playInBetweenVideo()
                }
                else {
                    mediaPlayer.onPlaybackStateChanged.disconnect(handleMediaPlayerStateChanged)
                    camera.stop()
                    recorder.stop()
                    handleSessionUploading()
                }
            }
        }

        function handleSessionUploading() {
            playingState = EcollectController.UploadingState
            Uploader.onFinished.connect(handleUploaderFinished)
            Uploader.onErrorChanged.connect(function() {
                console.log(Uploader.errorString)
            })
            Uploader.uploadDirectory(root.currentSessionDataLocation)
        }

        function handleUploaderFinished() {
            Uploader.finished.disconnect(handleUploaderFinished)
            playingState = EcollectController.StoppedState
        }
    }
}
