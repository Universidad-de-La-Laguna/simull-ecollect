import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ecollect.Controls

Dialog {
    id: dialog

    title: qsTr("¡Bienvenido/a!")
    standardButtons: Dialog.Yes | Dialog.No
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    modal: true

    ColumnLayout {

        LanguageSelector { }

        Label {
            text: qsTr("El propósito de esta aplicación es recoger vídeos de expresiones faciales de una\n" +
                       "persona mientras observa videos e imágenes promocionales y señala las emociones\n" +
                       "y sensaciones que el contenido despiertan en ella.\n\n" +
                       "Esta información será valiosa para crear modelos predictivos sobre las emociones\n" +
                       "humanas. Muchas gracias por su colaboración.\n\n" +
                       "El tiempo estimado para completar una sesión es de 15 minutos. ¿Desea continuar?")
        }
    }
}
