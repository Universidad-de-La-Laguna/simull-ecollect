import QtQuick
import QtQuick.Layouts

Item {
    default property alias mainContent: mainContent.children
    property alias leftSidebar: leftSidebar.children
    property alias rightSidebar: rightSidebar.children

    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: Constants.spacingUnit

        Item {
            id: leftSidebar

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15
        }

        Item {
            id: mainContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 70
        }

        Item {
            id: rightSidebar

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15
        }
    }
}
