import QtQuick
import QtQuick.Controls
import QtQuick.Particles

import ecollect
import ecollect.Controls.Reactions

Item {
    id: root

    property alias model: reactionsRepeater.model
    property bool enabled: true
    property bool useDefaultIcons: false

    signal reactionClicked(string name)

    anchors.fill: parent
    anchors.rightMargin: Constants.spacingUnit * 2

    Column {
        id: reactionsContainer
        anchors.top: parent.top
        anchors.left: parent.left
        spacing: Constants.spacingUnit

        Repeater {
            id: reactionsRepeater

            Reaction {
                text: qsTr(model.displayName)
                icon: model.icon
                disabledIcon: useDefaultIcons ? model.icon : model.disabledIcon
                enabled: root.enabled
                onClicked: if (enabled) root.reactionClicked(model.name)
            }
        }
    }
}
