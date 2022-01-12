import QtQuick
import QtQuick.Controls

Dialog {
    title: qsTr("Reacciones")
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape

    Label {
        text: qsTr("Necesitamos que durante la reproducción de cada vídeo indique las emociones\n" +
                   "que le despierta, usando los botones de la derecha. Cuanta más información\n" +
                   "nos proporcione mejor, por lo que le animamos a pulsar todas las veces que\n" +
                   "quiera. Como mínimo debe hacerlo una vez durante la reproducción para continuar\n" +
                   "con el siguiente vídeo\n\n" +
                   "Si no está seguro, no pulse ningún botón y la aplicación le ofrecerá verlo\n" +
                   "de nuevo.")
    }
}
