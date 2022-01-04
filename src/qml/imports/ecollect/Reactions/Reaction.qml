import QtQuick
import QtQuick.Controls
import QtQuick.Particles

import ecollect
import ecollect.Debug

Item {
    id: root

    property alias icon: button.icon.source
    property alias name: button.text
    property alias enabled: button.enabled

    signal clicked

    implicitHeight: button.implicitHeight
    implicitWidth: button.implicitWidth

    ParticleSystem {
        id: particles
    }

    RoundButton {
        id: button

        property color defaultIconColor: icon.color

        display: Button.TextBesideIcon
        radius: Constants.spacingUnit * 0.5
        onClicked: {
            root.clicked()
            emitter.pulse(Math.round(Math.random() * 300+100))
        }

        Component.onCompleted: {
            onEnabledChanged.connect(() => icon.color = enabled ? "transparent" : defaultIconColor)
        }

        Emitter {
            id: emitter

            x: 28
            y: 28
            width: 1
            height: 1
            system: particles
            enabled: false
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
                source: button.icon.source
                system: particles
                width: 24
                height: 24
                alpha: 0.5
            }
        }
    }
}
