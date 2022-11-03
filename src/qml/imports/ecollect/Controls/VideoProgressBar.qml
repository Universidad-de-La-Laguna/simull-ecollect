import QtQuick
import QtMultimedia

import ecollect

Item {
    id: root

    property var mediaPlayer: MediaPlayer {}
    property color backgroundColor: "black"
    property color color: "white"
    property int length: 100
    property int thick: 1
    property int bottomMargin: Constants.spacingUnit

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: -thick - bottomMargin

    width: root.length
    height: root.thick

    Rectangle {
        id: background

        anchors.fill: parent
        color: root.backgroundColor

        Rectangle {
            id: bar

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

            color: root.color
            height: root.thick
        }
    }

    states: [
        State {
            name: "playing"
            when: root.mediaPlayer.playbackState === MediaPlayer.PlayingState &&
                  root.mediaPlayer.mediaStatus === MediaPlayer.BufferedMedia

            PropertyChanges {
                target: background
                visible: true
            }

            PropertyChanges {
                target: bar
                width: root.length
            }
        },
        State {
            name: "stopped"
            when: true

            PropertyChanges {
                target: background
                visible: false
            }

            PropertyChanges {
                target: bar
                width: 0
            }
        }
    ]

    transitions: Transition {
        from: "stopped"
        to: "playing"

        NumberAnimation {
            target: bar
            property: "width"
            duration: root.mediaPlayer.duration
        }
    }
}
