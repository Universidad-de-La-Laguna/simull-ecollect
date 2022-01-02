import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias icon: button.icon.source
    property alias name: button.text
    property alias enabled: button.enabled

    signal clicked

    implicitHeight: button.implicitHeight
    implicitWidth: button.implicitWidth

    Button {
        id: button
        display: Button.TextBesideIcon
        onClicked: root.clicked()
    }
}
