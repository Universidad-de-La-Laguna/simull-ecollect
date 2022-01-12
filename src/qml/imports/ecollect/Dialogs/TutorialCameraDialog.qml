import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Previsualización de la cámara")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape

    onVisibleChanged: {
        if (! visible) return
        standardButton(Dialog.Ok).enabled = false
        standardButton(Dialog.Cancel).enabled = false
        timer.restart()
    }

    Label {
        text: qsTr("Antes de continuar, compruebe que se le ve correctamente en la cámara. Por\n" +
                   "ejemplo, que la iluminación de la habitación es adecuada y que está de\n" +
                   "frente a la cámara.")
    }

    Timer {
        id: timer

        interval: 3000
        onTriggered: {
            standardButton(Dialog.Ok).enabled = true
            standardButton(Dialog.Cancel).enabled = true
        }
    }
}
