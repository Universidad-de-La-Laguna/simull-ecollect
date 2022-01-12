import QtQuick
import QtQuick.Controls
import QtQuick.Particles

import ecollect
import ecollect.Controls.Reactions

Item {
    id: root

    property ReactionsProps reactions: ReactionsProps {}
    property alias model: reactionsRepeater.model

    signal reactionClicked(string name)

    anchors.fill: parent
    anchors.rightMargin: Constants.spacingUnit * 2

    ParticleSystem {
        id: particles
    }

    Column {
        id: reactionsContainer
        anchors.top: parent.top
        anchors.left: parent.left
        spacing: Constants.spacingUnit

        Repeater {
            id: reactionsRepeater
            model: reactions.model

            Reaction {
                name: model.name
                icon: model.icon
                enabled: reactions.enabled
                particleSystem: particles
                onClicked: root.reactionClicked(name)
            }
        }
    }
}
