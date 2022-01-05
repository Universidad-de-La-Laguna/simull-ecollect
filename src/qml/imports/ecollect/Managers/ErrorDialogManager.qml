import QtQuick
import QtQuick.Controls

import ecollect.Dialogs

Item {
    id: root

    signal closed

    function show() {
        for (var i = 0; i < resources.length; ++i) {
            if (resources[i].errorCode === appManager.error) {
                resources[i].visible = true
                return
            }
        }
    }

    ErrorDialog {
        id: cameraErrorDialog

        errorCode: EcollectManager.CameraError
        title: qsTr("Problema con la cámara")
        informativeText: qsTr("Ha ocurrido un problema con la cámara. Por favor, compruebe que está conectada\n" +
                              "y que no está siendo usada por otra aplicación e inténtelo de nuevo.")

        onClosed: root.closed()
    }

    ErrorDialog {
        id: recorderErrorDialog

        errorCode: EcollectManager.RecorderError
        title: qsTr("Problema con la grabación")
        informativeText: qsTr("Ha ocurrido un problema con el componente de grabación. Por favor, compruebe que\n" +
                              "la cámara no está siendo usada por otra aplicación y que tiene espacio libre en\n" +
                              "el disco duro e inténtelo de nuevo.")

        onClosed: root.closed()
    }

    ErrorDialog {
        id: mediaPlayerErrorDialog

        errorCode: EcollectManager.PlayerError
        title: qsTr("Problema con el reproductor multimedia")
        informativeText: qsTr("Ha ocurrido un problema con el reproductor multimedia. Por favor, compruebe que\n" +
                              "puede reproducir archivos MP4 H.264 en el reproductor multimeda estándar de su\n"+
                              "sistema e inténtelo de nuevo.")

        onClosed: root.closed()
    }

    ErrorDialog {
        id: uploadErrorDialog

        errorCode: EcollectManager.UploadError
        title: qsTr("Problema de red")
        informativeTextFormat: Text.StyledText
        informativeText: qsTr("Ha ocurrido un problema al intentar enviar los archivos de la sesión. Por favor,<br>" +
                              "localice los archivos en <a href=\"%1\">esta carpeta</a> y contacte con nosotros para acordar cómo<br>" +
                              "nos los podría enviar.<br><br>Discule las molestias."
                              ).arg(appManager.currentSessionDataLocation)

        onLinkActivated: (link) => Qt.openUrlExternally(link)
        onClosed: root.closed()
    }
}
