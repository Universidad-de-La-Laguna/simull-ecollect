import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Bienvenido/a")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.NoAutoClose

    Component.onCompleted: function() {
        standardButton(Dialog.Ok).text = qsTr("Continuar")
        standardButton(Dialog.Cancel).text = qsTr("Salir")
    }

    Label {
        text: qsTr("El propósito de esta aplicación es recoger vídeos de expresiones faciales\n" +
                   "de una persona mientras observa videos e imágenes promocionales y señala\n" +
                   "las emociones y sensaciones que el contenido despiertan en ella.\n\n" +
                   "Esta información será valiosa para crear moderlos predictivos sobre las\n" +
                   "emocionales humanas.")
    }
}
