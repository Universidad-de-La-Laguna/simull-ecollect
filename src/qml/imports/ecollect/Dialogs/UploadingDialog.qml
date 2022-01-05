import QtQuick
import QtQuick.Controls

import ecollect

Dialog {
    title: qsTr("Enviando los datos...")
    closePolicy: Popup.NoAutoClose

    parent: currentView
    anchors.centerIn: parent
    modal: true

    Column {
        spacing: Constants.spacingUnit * 2

        Label {
            text: qsTr("Ya casi hemos terminado.\n\n" +
                       "Se están enviando los datos de la sesión. Por favor, espere un momento a que\n" +
                       "terminen de enviarse.")
        }

        ProgressBar {
            indeterminate: true
            topPadding: Constants.spacingUnit * 2
            bottomPadding: Constants.spacingUnit * 2
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
