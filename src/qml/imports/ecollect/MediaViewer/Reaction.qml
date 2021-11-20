import QtQuick
import QtQuick.Controls

import ecollect.MediaViewer

Item {
    id: root

    signal onClicked
    property alias icon: button.icon.source
    property alias name: button.text
    property alias enabled: button.enabled

    implicitHeight: button.implicitHeight
    implicitWidth: button.implicitWidth

    Button {
        id: button
        display: Button.TextBesideIcon
        onClicked: root.onClicked()
    }
}
