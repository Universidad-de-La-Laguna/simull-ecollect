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
    readonly property url transitionVideoUrl: "qrc:///videos/film_leader.mp4"

    readonly property var videoPlaylist: [
        "qrc:///videos/film_leader.mp4",
        "qrc:///videos/film_leader.mp4",
        "qrc:///videos/film_leader.mp4",
    ]

    readonly property ListModel reactions: ListModel {
        ListElement {
            name: "Divertido"
            icon: "qrc:///images/face-with-tears-of-joy.png"
        }

        ListElement {
            name: "Desagradado"
            icon: "qrc:///images/nauseated-face.png"
        }

        ListElement {
            name: "Enfadado"
            icon: "qrc:///images/pouting-face.png"
        }
    }
}
