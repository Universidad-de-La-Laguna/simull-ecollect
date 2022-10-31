import QtQuick

Item {
    id: root

    property alias color: bar.color
    property alias backgroundColor: background.color
    property double value: 0.5

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: -height

    height: 1
    width: parent.contentRect.width

    Rectangle {
        id: background

        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: bar

            anchors.top: parent.top
            anchors.left: parent.left

            width: root.value * parent.width
            height: parent.height
        }
    }
}
