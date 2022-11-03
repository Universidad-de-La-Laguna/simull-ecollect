pragma Singleton
import QtQuick
import QtQuick.Controls.Material
import QtMultimedia

QtObject {
    readonly property int width: 1920
    readonly property int height: 1080
    readonly property real spacingUnit: 8.0

    readonly property string applicatioName: "Emotions Samples Collect - SIMULL"

    readonly property color tutorialMarkerColor: "#E77054"

    readonly property color videoProgressBarBackground: Material.primary
    readonly property color videoProgressBarColor: "white"
    readonly property int videoProgressBarLength: 500
    readonly property int videoProgressBarThick: 2

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
            displayName: "Angry"
            icon: "qrc:///images/pouting-face.png"
            disabledIcon: "qrc:///images/pouting-face-greyed.png"
        }

        ListElement {
            name: "disgust"
            displayName: "Disgust"
            icon: "qrc:///images/nauseated-face.png"
            disabledIcon: "qrc:///images/nauseated-face-greyed.png"
        }

        ListElement {
            name: "fear"
            displayName: "Fear"
            icon: "qrc:///images/face-screaming-in-fear.png"
            disabledIcon: "qrc:///images/face-screaming-in-fear-greyed.png"
        }

        ListElement {
            name: "happy"
            displayName: "Happy"
            icon: "qrc:///images/grinning-face-with-smiling-eye.png"
            disabledIcon: "qrc:///images/grinning-face-with-smiling-eye-greyed.png"
        }

        ListElement {
            name: "sad"
            displayName: "Sad"
            icon: "qrc:///images/slightly-frowning-face.png"
            disabledIcon: "qrc:///images/slightly-frowning-face-greyed.png"
        }

        ListElement {
            name: "surprise"
            displayName: "Surprise"
            icon: "qrc:///images/astonished-face.png"
            disabledIcon: "qrc:///images/astonished-face-greyed.png"
        }

        ListElement {
            name: "neutral"
            displayName: "Neutral"
            icon: "qrc:///images/neutral-face.png"
            disabledIcon: "qrc:///images/neutral-face-greyed.png"
        }
    }
}
