import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Antes de empezar...")
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
        text: qsTr("Durante la sesión reproduciremos en el centro de la ventana una serie de vídeos e\n" +
                   "imágenes mientras grabamos sus expresiones faciales con la cámara del ordenador.")
    }
}
