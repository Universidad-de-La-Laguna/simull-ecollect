import QtQuick
import QtQuick.Layouts

import ecollect

Item {
    default property alias mainContent: mainContent.children
    property alias headerContent: headerContent.children
    property alias footerContent: footerContent.children
    property alias leftSidebar: leftSidebar.children
    property alias rightSidebar: rightSidebar.children

    anchors.fill: parent

    GridLayout {
        anchors.fill: parent
        rowSpacing: Constants.spacingUnit
        columnSpacing: Constants.spacingUnit
        flow: GridLayout.LeftToRight
        columns: 3

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            id: headerContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 15
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

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
            Layout.preferredHeight: 70
        }

        Item {
            id: rightSidebar

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            id: footerContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 15
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
