import QtQuick
import QtQuick.Controls

import ecollect
import ecollect.Reactions

Item {
    id: root
    anchors.fill: parent

    property ReactionsProps reactions: ReactionsProps {}
    property alias model: reactionsRepeater.model

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
            }
        }
    }
}
