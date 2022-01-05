import QtMultimedia
import QtQuick
import QtQml.StateMachine as DSM

import ecollect.Controls
import ecollect.Managers

Manager {
    id: root

    property int error: AppManager.NoError
    property Camera camera
    property VideoOutput videoOutput

    signal finished
    signal canceled
    signal errorOccurred

//    DSM.SignalTransition {
//        targetState: cameraPreviewState
//        signal: internal.startCameraPreviewRequested
//    }

//    DSM.State {
//        id: cameraPreviewState

//        onEntered: {
//            camera.start()
//            captureSession.videoOutput = mainVideoOutput
//            internal.playingState = SessionManager.CameraPreviewState
//        }
//        onExited: {
//            camera.stop()
//            captureSession.videoOutput = null
//        }

//        DSM.SignalTransition {
//            targetState: stoppedState
//            signal: internal.stopCameraPreviewRequested
//        }

//        DSM.SignalTransition {
//            targetState: stoppedState
//            signal: root.errorOccurred
//        }
//    }


//    function startCameraPreview() {
//        internal.startCameraPreviewRequested()
//    }

//    function stopCameraPreview() {
//        internal.stopCameraPreviewRequested()
//    }


//    TutorialControlMarker {
//        control: videoOutput
//        borderColor: "#E77054"
//        borderWidth: Constants.spacingUnit
//    }


//    DSM.StateMachine {
//        id: tutoiralStateMachine

//        initialState: aboutCameraState
//            running: true

//        onStarted: appManager.startCameraPreview()
//        onFinished: appManager.stopCameraPreview()

//        DSM.State {
//            id: aboutCameraState

//            DSM.SignalTransition {
//                targetState: aboutReactionsState
//                signal: TutorialCameraDialog.accepted
//            }

//            DSM.SignalTransition {
//                targetState: abortState
//                signal: TutorialCameraDialog.rejected
//            }
//        }

//        DSM.State {
//            id: aboutReactionsState

//            DSM.SignalTransition {
//                targetState: aboutAudioState
//                signal: TutorialReactionsDialog.accepted
//            }

//            DSM.SignalTransition {
//                targetState: abortState
//                signal: TutorialReactionsDialog.rejected
//            }
//        }

//        DSM.State {
//            id: aboutAudioState

//            DSM.SignalTransition {
//                targetState: beforeEndState
//                signal: TutorialAudioDialog.accepted
//            }

//            DSM.SignalTransition {
//                targetState: abortState
//                signal: TutorialAudioDialog.rejected
//            }
//        }

//        DSM.State {
//            id: beforeEndState

//            DSM.SignalTransition {
//                targetState: finishState
//                signal: TutorialEndDialog.accepted
//            }

//            DSM.SignalTransition {
//                targetState: abortState
//                signal: TutorialEndDialog.rejected
//            }
//        }

//        DSM.FinalState {
//            id: finishState

//            onEntered: root.finished()
//        }

//        DSM.FinalState {
//            id: abortState

//            onEntered: root.aborted()
//        }
//    }
}
