import QtQuick 2.0

Item {
    id: root

    property var control
    property color borderColor: Qt.lighter("red")
    property int borderWidth: 1

    Rectangle {
        id: marker

        parent: control
        x: control.x - borderWidth
        y: control.y - borderWidth
        width: control.width + borderWidth * 2
        height: control.height + borderWidth * 2
        border.color: borderColor
        border.width: borderWidth
        color: "transparent"
    }
}
