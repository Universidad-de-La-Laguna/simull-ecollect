import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Sobre el control de volumen...")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent

    Label {
        text: qsTr("En todo momento podrá controlar el volumen de la reproducción usando el control\n" +
                   "de volumen bajo el reproductor de vídeo.")
    }
}
