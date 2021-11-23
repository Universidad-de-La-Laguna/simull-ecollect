pragma Singleton
import QtQuick

QtObject {
    readonly property int width: 1920
    readonly property int height: 1080
    readonly property real spacingUnit: 8.0

    readonly property string applicatioName: qsTr("Emotions Samples Collect - SIMULL")

    readonly property ListModel reactions: ListModel {
        ListElement {
            name: "Divertido"
        }

        ListElement {
            name: "Desagradable"
        }
    }
}
