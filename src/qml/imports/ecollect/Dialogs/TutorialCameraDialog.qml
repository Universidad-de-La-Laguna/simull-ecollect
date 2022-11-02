import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Previsualización de la cámara")
    closePolicy: Popup.CloseOnEscape

    footer: DialogButtonBox {
        Button {
            id: cancelButton
            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
        Button {
            id: okButton
            text: qsTr("OK")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
    }

    onVisibleChanged: {
        if (! visible) return
        cancelButton.enabled = false
        okButton.enabled = false
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
            cancelButton.enabled = true
            okButton.enabled= true
        }
    }
}
