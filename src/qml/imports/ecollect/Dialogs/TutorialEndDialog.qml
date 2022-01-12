import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("¡Listos!")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent

    Label {
        text: qsTr("Ya casi estamos listos. Podemos empezar la sesión.\n\n" +
                   "¿Desea continuar?")
    }
}
