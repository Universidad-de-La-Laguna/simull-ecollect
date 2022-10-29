pragma Singleton
import QtQuick
import QtMultimedia

QtObject {
    readonly property int width: 1920
    readonly property int height: 1080
    readonly property real spacingUnit: 8.0

    readonly property string applicatioName: "Emotions Samples Collect - SIMULL"

    readonly property color tutorialMarkerColor: "#E77054"

    readonly property int recordingMediaFormat: MediaFormat.MPEG4
    readonly property int recordingVideoCodec: MediaFormat.VideoCodec.H264
    readonly property int recordingQuality: MediaRecorder.NormalQuality

    readonly property string recordingFilename: "recording.mp4"
    readonly property string sessionDataFilename: "dataset.csv"
    readonly property url transitionVideoUrl: "qrc:///videos/film_leader.mp4"
    readonly property url videoPlaylistUrl: "qrc:///campains/playlist.txt"

    readonly property ListModel reactions: ListModel {
        ListElement {
            name: "angry"
            displayName: qsTr("Angry")
            icon: "qrc:///images/pouting-face.png"
        }

        ListElement {
            name: "disgust"
            displayName: qsTr("Disgust")
            icon: "qrc:///images/nauseated-face.png"
        }

        ListElement {
            name: "fear"
            displayName: qsTr("Fear")
            icon: "qrc:///images/face-screaming-in-fear.png"
        }

        ListElement {
            name: "happy"
            displayName: qsTr("Happy")
            icon: "qrc:///images/grinning-face-with-smiling-eye.png"
        }

        ListElement {
            name: "sad"
            displayName: qsTr("Sad")
            icon: "qrc:///images/slightly-frowning-face.png"
        }

        ListElement {
            name: "surprise"
            displayName: qsTr("Surprise")
            icon: "qrc:///images/astonished-face.png"
        }

        ListElement {
            name: "neutral"
            displayName: qsTr("Neutral")
            icon: "qrc:///images/neutral-face.png"
        }
    }
}
