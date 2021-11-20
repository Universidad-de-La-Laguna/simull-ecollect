import QtQuick
import QtQuick.Layouts
import QtMultimedia

import ecollect
import ecollect.MediaViewer

Item {
    id: root
    anchors.fill: parent

    property alias videoOutput: videoOutput
    property ReactionsProps reactions: ReactionsProps {}

    ColumnLayout {
        anchors.fill: parent
        spacing: Constants.spacingUnit

        VideoOutput {
            id: videoOutput

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Row {
            id: reactionsContainer
            Layout.alignment: Qt.AlignHCenter
            spacing: Constants.spacingUnit

            Repeater {
                id: reactionsRepeater
                model: reactions.model

                Reaction {
                    name: model.name
                    icon: model.icon
                    enabled: reactions.enabled
                }
            }
        }
    }
}
