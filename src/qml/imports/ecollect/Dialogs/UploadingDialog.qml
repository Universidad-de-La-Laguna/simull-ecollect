import QtQuick
import QtQuick.Controls

import ecollect

Dialog {
    title: qsTr("Enviando los datos...")
    closePolicy: Popup.NoAutoClose
    modal: true

    Column {
        spacing: Constants.spacingUnit * 2

        Label {
            text: qsTr("Ya casi hemos terminado.\n\n" +
                       "Se están enviando los datos de la sesión. Por favor, espere un momento a que\n" +
                       "terminen de enviarse.")
        }

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
