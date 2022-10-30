import QtQuick
import QtMultimedia
import QtQml.StateMachine as DSM

import ecollect
import ecollect.Controls
import ecollect.Dialogs
import ecollect.Managers

Manager {
    id: root

    readonly property alias error: internal.error
    readonly property alias aboutReactionsStateActive: aboutReactionsState.active

    property CaptureSession captureSession
    property var videoOutputControl
    property var reactionsControl
    property var volumeControl

    signal finished
    signal canceled
    signal errorOccurred

    function start() {
        stateMachine.start()
    }

    DSM.StateMachine {
        id: stateMachine

        initialState: aboutAppState

        DSM.State {
            id: aboutAppState

            DSM.SignalTransition {
                targetState: aboutAudioState
                signal: introDialog.accepted
            }

            DSM.SignalTransition {
                targetState: cancelState
                signal: introDialog.rejected
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: root.errorOccurred
            }
        }

        DSM.State {
            id: aboutAudioState

            DSM.SignalTransition {
                targetState: aboutReactionsState
                signal: audioDialog.accepted
            }

            DSM.SignalTransition {
                targetState: cancelState
                signal: audioDialog.rejected
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: root.errorOccurred
            }
        }

        DSM.State {
            id: aboutReactionsState

            DSM.SignalTransition {
                targetState: aboutCameraState
                signal: reactionsDialog.accepted
            }

            DSM.SignalTransition {
                targetState: cancelState
                signal: reactionsDialog.rejected
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: root.errorOccurred
            }
        }

        DSM.State {
            id: aboutCameraState

            onEntered: {
                root.captureSession.camera.errorOccurred.connect(internal.handleError)
                root.captureSession.startCameraPreview()
            }
            onExited: {
                root.captureSession.stopCameraPreview()
                root.captureSession.camera.errorOccurred.disconnect(internal.handleError)
            }

            DSM.SignalTransition {
                targetState: beforeEndState
                signal: cameraDialog.accepted
            }

            DSM.SignalTransition {
                targetState: cancelState
                signal: cameraDialog.rejected
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: root.errorOccurred
            }
        }

        DSM.State {
            id: beforeEndState

            DSM.SignalTransition {
                targetState: finishState
                signal: endDialog.accepted
            }

            DSM.SignalTransition {
                targetState: cancelState
                signal: endDialog.rejected
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: root.errorOccurred
            }
        }

        DSM.FinalState {
            id: finishState

            onEntered: root.finished()
        }

        DSM.FinalState {
            id: cancelState

            onEntered: root.canceled()
        }

        DSM.FinalState {
            id: abortState
        }
    }

    // UI components

    TutorialEndDialog {
        id: endDialog
        visible: beforeEndState.active
    }

    TutorialIntroDialog {
        id: introDialog
        visible: aboutAppState.active
    }

    TutorialControlMarker {
        control: videoOutputControl
        borderColor: Constants.tutorialMarkerColor
        borderWidth: Constants.spacingUnit
        visible: aboutAppState.active || aboutCameraState.active
    }

    TutorialCameraDialog {
        id: cameraDialog

        x: (root.width - width) / 2
        y: Constants.spacingUnit * 2
        visible: aboutCameraState.active
    }

    TutorialControlMarker {
        control: reactionsControl
        borderColor: Constants.tutorialMarkerColor
        borderWidth: Constants.spacingUnit
        visible: aboutReactionsState.active
    }

    TutorialReactionsDialog {
        id: reactionsDialog

        visible: aboutReactionsState.active

        Component.onCompleted: {
            var position = reactionsControl.mapToItem(root, 0, 0)
            x = position.x - width - Constants.spacingUnit * 2
            y = position.y
        }
    }

    TutorialControlMarker {
        control: volumeControl
        borderColor: Constants.tutorialMarkerColor
        borderWidth: Constants.spacingUnit
        visible: aboutAudioState.active
    }

    TutorialAudioDialog {
        id: audioDialog
        visible: aboutAudioState.active
    }

    QtObject {
        id: internal

        property int error: AppManager.NoError

        function handleError(error, errorString) {
            internal.error = error;
            root.errorOccurred();
        }
    }
}
