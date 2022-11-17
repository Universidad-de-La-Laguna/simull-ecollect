import QtQuick
import QtQuick.Controls
import QtQuick.Particles

import ecollect
import ecollect.Controls.Reactions

Item {
    id: root

    property alias model: reactionsView.model
    property bool enabled: true
    property bool useDefaultIcons: false

    signal reactionClicked(string name)

    anchors.fill: parent
    anchors.rightMargin: Constants.spacingUnit * 2

    ListView {
        id: reactionsView
        anchors.fill: parent
        interactive: false

        delegate: Reaction {
            width: parent.width
            height: implicitHeight * 2
            enabled: root.enabled

            text: model.getDisplayName()
            icon: model.icon
            disabledIcon: useDefaultIcons ? model.icon : model.disabledIcon

            onClicked: if (enabled) root.reactionClicked(model.name)

            Component.onCompleted: {
                text: Qt.binding(model.getDisplayName)
            }
        }
    }
}
