import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ecollect

Dialog {
    id: dialog

    readonly property alias gender: gender.currentValue
    readonly property alias age: age.value
    readonly property alias nationality: nationality.currentValue

    title: qsTr("Datos estadísticos")
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    modal: true

    footer: DialogButtonBox {
        Button {
            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
        Button {
            text: qsTr("OK")
            flat: true
            enabled: gender.currentIndex !== -1 && nationality.acceptablePartialInput
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
    }

    GridLayout {
        columns: 2
        anchors.fill: parent

        Label {
            Layout.columnSpan: 2
            text: qsTr("La encuesta es anónima pero necestiamos que nos proporciones algunos datos\n" +
                       "solo con fines estadisticos.")
        }

        Label {
            text: qsTr("Gender:")
        }

        ComboBox {
            id: gender

            model: Constants.genders
            valueRole: "tag"
            textRole: "displayName"
            currentIndex: -1
        }

        Label {
            text: qsTr("Age:")
        }

        SpinBox {
            id: age

            editable: true
            value: 18
            from: 18
            to: 99
        }

        Label {
            text: qsTr("Country of nationality:")
        }

        ComboBox {
            id: nationality

            property bool acceptablePartialInput: find(editText, Qt.MatchFixedString) !== -1

            model: Constants.nationalities.model
            editable: true
            valueRole: "alpha2"
            textRole: "name_" + I18n.activeLanguage

            popup: null
            indicator: null

            Material.accent: acceptablePartialInput ? Material.Teal : Material.Red
        }
    }
}
