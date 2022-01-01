pragma Singleton
import QtQuick
import QtMultimedia

QtObject {
    readonly property int width: 1920
    readonly property int height: 1080
    readonly property real spacingUnit: 8.0

    readonly property string applicatioName: qsTr("Emotions Samples Collect - SIMULL")

    readonly property int recordingMediaFormat: MediaFormat.MPEG4
    readonly property int recordingVideoCodec: MediaFormat.VideoCodec.H264
    readonly property int recordingQuality: MediaRecorder.NormalQuality

    readonly property string recordingFilename: "recording.mp4"
    readonly property string sessionDataFilename: "dataset.csv"
    readonly property url transitionVideoUrl: "qrc:///mp4/321_action.mp4"

    readonly property var videoPlaylist: [
        "qrc:///mp4/321_action.mp4",
        "qrc:///mp4/321_action.mp4",
    ]

    readonly property ListModel reactions: ListModel {
        ListElement {
            name: "Divertido"
        }

        ListElement {
            name: "Desagradable"
        }
    }
}
