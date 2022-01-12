import QtQuick
import QtQuick.Controls

import ecollect

Item {
    id: root

    property alias value: volumeSlider.value

    width: volumeSlider.childrenRect.width + Constants.spacingUnit * 20
    height: childrenRect.height

    Row {

        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            text: Math.round(volumeSlider.value * 100)
            width: 1
            anchors.verticalCenter: parent.verticalCenter
            rightPadding: Constants.spacingUnit * 0.5
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Slider {
            id: volumeSlider

            from: 0.0;
            to: 1.0
            value: 1.0
        }

        Label {
            text: internal.mapVolumeValueToIcon(volumeSlider.value)
            font.family: "Material Design Icons"
            font.pointSize: 18
            opacity: 0.75
            width: 1
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    QtObject {
        id: internal

        function mapVolumeValueToIcon(value) {
            if (value > 0.75)
                return "\u{f057E}";
            else if (value > 0.25)
                return "\u{f0580}";
            else if (value > 0)
                return "\u{f057F}";
            else
                return "\u{f075F}";
        }
    }
}
