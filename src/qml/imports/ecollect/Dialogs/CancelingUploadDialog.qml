import QtQuick
import QtQuick.Controls

import ecollect

Dialog {
    title: qsTr("Cancelando el envío de datos...")
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: parent
    modal: true

    Column {
        spacing: Constants.spacingUnit * 2

        Label {
            text: qsTr("Por favor, espere un momento a que se cancele la operación.")
        }

        ProgressBar {
            indeterminate: true
            topPadding: Constants.spacingUnit * 2
            bottomPadding: Constants.spacingUnit * 2
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
