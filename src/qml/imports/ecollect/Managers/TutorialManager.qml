import QtQuick
import QtQml.StateMachine as DSM

Item {
    id: root

    signal finished
    signal aborted

    DSM.StateMachine {
        id: tutoiralStateMachine
        initialState: aboutCameraState

        onStarted: appManager.startCameraPreview()
        onFinished: appManager.stopCameraPreview()

        DSM.State {
            id: aboutCameraState

            DSM.SignalTransition {
                targetState: aboutReactionsState
                signal: TutorialCameraDialog.accepted
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: TutorialCameraDialog.rejected
            }
        }

        DSM.State {
            id: aboutReactionsState

            DSM.SignalTransition {
                targetState: aboutAudioState
                signal: TutorialReactionsDialog.accepted
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: TutorialReactionsDialog.rejected
            }
        }

        DSM.State {
            id: aboutAudioState

            DSM.SignalTransition {
                targetState: beforeEndState
                signal: TutorialAudioDialog.accepted
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: TutorialAudioDialog.rejected
            }
        }

        DSM.State {
            id: beforeEndState

            DSM.SignalTransition {
                targetState: finishState
                signal: TutorialEndDialog.accepted
            }

            DSM.SignalTransition {
                targetState: abortState
                signal: TutorialEndDialog.rejected
            }
        }

        DSM.FinalState {
            id: finishState

            onEntered: root.finished()
        }

        DSM.FinalState {
            id: abortState

            onEntered: root.aborted()
        }
    }
}
