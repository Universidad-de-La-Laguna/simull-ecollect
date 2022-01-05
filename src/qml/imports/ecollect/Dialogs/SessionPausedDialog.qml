import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("¡Recuerde reaccionar durante la reproducción!")
    standardButtons: Dialog.Retry
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent

    Label {
        text: qsTr("Ha visto el contenido pero no ha reaccionado usando los botones de la derecha.\n" +
                   "Recuerde reaccionar durante la reproducción de cada pieza de contenido. Cuantas\n" +
                   "más veces lo haga mejor, pero debe hacerlo al menos una vez.")
    }
}
