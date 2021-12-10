import QtQuick
import QtMultimedia
import Qt.labs.platform

import ecollect.Native

Item {
    signal onStopped;

    property VideoOutput videoOutput;

    CaptureSession {
        id: captureSession

        camera: Camera {
            id: camera
        }
    }

    MediaRecorder {
        id: recorder
    }

    QtObject {
        id: internal
        property string sessionId: Uuid.create();
        property url cameraRecordingUrl: makeCameraRecordingUrl();
        property url dataFileUrl: makeDataFileUrl();

        function makeCameraRecordingUrl() {
            return Qt.resolvedUrl(StandardPaths.writableLocation(StandardPaths.AppDataLocation)) + `/${sessionId}/capture.mp4"`;
        }

        function makeDataFileUrl(uuid) {
            return Qt.resolvedUrl(StandardPaths.writableLocation(StandardPaths.AppDataLocation)) + `/${sessionId}/dataset.csv"`;
        }
    }

    function startCameraPreview() {
        captureSession.videoOutput = videoOutput;
        camera.start()
    }

    function stopCameraPreview() {
        captureSession.videoOutput = null;
        camera.stop()
    }

    function startExperiment() {
        console.log("cameraRecordingUrl: " + internal.cameraRecordingUrl);
        console.log("dataFileUrl: " + internal.dataFileUrl);

        captureSession.recorder = recorder;
    }
}
