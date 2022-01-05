import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Hemos terminado")
    standardButtons: Dialog.Close
    closePolicy: Popup.CloseOnEscape

    parent: currentView
    anchors.centerIn: parent
    modal: true

    Label {
        text: qsTr("Ya hemos terminado. Muchísimas gracias por su colaboración.")
    }
}
