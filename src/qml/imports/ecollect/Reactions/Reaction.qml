import QtQuick
import QtQuick.Controls

import ecollect

Item {
    id: root

    property alias icon: button.icon.source
    property alias name: button.text
    property alias enabled: button.enabled

    signal clicked

    implicitHeight: button.implicitHeight
    implicitWidth: button.implicitWidth

    RoundButton {
        id: button

        property color defaultIconColor: icon.color

        display: Button.TextBesideIcon
        radius: Constants.spacingUnit * 0.5
        onClicked: root.clicked()

        Component.onCompleted: {
            onEnabledChanged.connect(() => icon.color = enabled ? "transparent" : defaultIconColor)
        }
    }
}
