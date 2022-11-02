import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Sobre el control de volumen...")
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent

    footer: DialogButtonBox {
        Button {
            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
        Button {
            text: qsTr("OK")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
    }

    Label {
        text: qsTr("En todo momento podrá controlar el volumen de la reproducción usando el control\n" +
                   "de volumen bajo el reproductor de vídeo.")
    }
}
