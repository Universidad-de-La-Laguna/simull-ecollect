import QtQuick 2.0

Item {
    id: root

    property var control
    property color borderColor: Qt.lighter("red")
    property int borderWidth: 1

    Rectangle {
        id: marker

        parent: appManager
        border.color: borderColor
        border.width: borderWidth
        color: "transparent"
        visible: root.visible

        Component.onCompleted: {
            var position = control.mapToItem(appManager, 0, 0)
            x = position.x - borderWidth
            y = position.y - borderWidth
            width = control.width + borderWidth * 2
            height = control.height + borderWidth * 2
        }
    }
}
