import QtQuick
import QtQuick.Controls

Dialog {
    id: root

    property int errorCode: 0
    property alias informativeText: label.text
    property alias informativeTextFormat: label.textFormat

    signal linkActivated (url link)

    title: qsTr("Error")
    standardButtons: Dialog.Close

    parent: currentView
    anchors.centerIn: parent
    modal: true

    Label {
        id: label
        onLinkActivated: (link) => root.linkActivated(link)
    }
}
