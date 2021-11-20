import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Bienvenido/a")
    standardButtons: Dialog.Ok

    Label {
        text: qsTr("El propósito de esta aplicación es recoger vídeos de expresiones faciales")
    }
}
