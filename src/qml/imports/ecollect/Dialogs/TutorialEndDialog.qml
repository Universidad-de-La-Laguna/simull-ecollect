import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("¡Listos!")
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
        text: qsTr("Ya casi estamos listos. Podemos empezar la sesión.\n\n" +
                   "¿Desea continuar?")
    }
}
