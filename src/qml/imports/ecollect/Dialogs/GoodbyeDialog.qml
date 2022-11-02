import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Hemos terminado")
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    modal: true

    footer: DialogButtonBox {
        Button {
            text: qsTr("Close")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    Label {
        text: qsTr("Ya hemos terminado. Muchísimas gracias por su colaboración.")
    }
}
