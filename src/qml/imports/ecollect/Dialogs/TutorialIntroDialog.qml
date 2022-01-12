import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Antes de empezar...")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent

    Label {
        text: qsTr("Durante la sesión reproduciremos en el centro de la ventana una serie de vídeos e\n" +
                   "imágenes mientras grabamos sus expresiones faciales con la cámara del ordenador.")
    }
}
