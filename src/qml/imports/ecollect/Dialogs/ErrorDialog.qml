import QtQuick
import QtQuick.Controls

Dialog {
    id: root

    property int errorCode: 0
    property alias informativeText: label.text
    property alias informativeTextFormat: label.textFormat

    signal linkActivated (url link)

    title: qsTr("Error")
    anchors.centerIn: parent
    modal: true

    footer: DialogButtonBox {
        Button {
            text: qsTr("Close")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    Label {
        id: label
        onLinkActivated: (link) => root.linkActivated(link)
    }
}
