import QtQuick
import QtQuick.Controls

import ecollect

Dialog {
    title: qsTr("Cancelando el envío de datos...")
    closePolicy: Popup.NoAutoClose
    modal: true

    Column {
        spacing: Constants.spacingUnit * 2

        Label {
            text: qsTr("Por favor, espere un momento a que se cancele la operación.")
        }

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
