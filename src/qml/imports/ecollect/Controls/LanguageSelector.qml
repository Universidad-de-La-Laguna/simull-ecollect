import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ecollect

Item {
    id: root

    implicitHeight: control.implicitHeight
    implicitWidth: control.implicitWidth

    ComboBox {
        id: control

        Layout.preferredWidth: 90
        font.capitalization: Font.AllUppercase
        popup.font.capitalization: Font.AllUppercase
        displayText: "\u{f059f} " + currentText

        textRole: "display"
        model: I18n.supportedLanguages
        currentIndex: I18n.activeLanguageIndex

        onActivated: I18n.activeLanguageIndex = currentIndex
    }
}
