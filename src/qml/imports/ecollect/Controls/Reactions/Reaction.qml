import QtQuick
import QtQuick.Controls
import QtQuick.Particles

import ecollect

MouseArea {
    id: root

    property url icon
    property url disabledIcon: ""
    property alias text: button.text
    property alias enabled: button.enabled

    signal clicked

    hoverEnabled: true
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    ParticleSystem {
        id: particles
    }

    RoundButton {
        id: button

        anchors.fill: parent
        display: Button.TextBesideIcon
        radius: Constants.spacingUnit * 0.5
        icon.color: "transparent"
        icon.source: button.enabled ? root.icon :
                     root.disabledIcon.toString() === "" ? root.icon : root.disabledIcon

        onClicked: {
            root.clicked()
            var positionInButton = mapToItem(button, mouseX, mouseY)
            emitter.x = positionInButton.x
            emitter.y = positionInButton.y
            emitter.pulse(Math.round(Math.random() * 300 + 100))
        }

        Emitter {
            id: emitter

            width: 1
            height: 1
            enabled: false
            system: particles
            emitRate: 10
            lifeSpan: 1000
            lifeSpanVariation: 50
            size: 24
            velocity: PointDirection {
                x: 0
                y: -100
                xVariation: 50
                yVariation: 100/6
            }

            ImageParticle {
                source: root.icon
                system: particles
                width: 24
                height: 24
                alpha: 0.5
            }
        }
    }
}
