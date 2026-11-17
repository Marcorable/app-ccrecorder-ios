
import ComposableArchitecture

extension AlertState where Action == RecordScreen.Root.Feature.Action.Alert {

    static var confirmCancel: Self {
        .init(
            title: {
                TextState(String(localized: .RecordScreen.alertCancel))
            },
            actions: {
                ButtonState(
                    role: .destructive,
                    action: .cancelConfirmed
                ) {
                    TextState(String(localized: .RecordScreen.buttonDelete))
                }
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonCancel))
                }
            },
            message: {
                TextState(String(localized: .RecordScreen.alertCancelMessage))
            }
        )
    }

    static var confirmSave: Self {
        .init(
            title: {
                TextState(String(localized: .RecordScreen.alertComplete))
            },
            actions: {
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonCancel))
                }
                ButtonState(
                    role: .destructive,
                    action: .saveConfirmed
                ) {
                    TextState(String(localized: .buttonSave))
                }
            },
            message: {
                TextState(String(localized: .RecordScreen.alertCompleteMessage))
            }
        )
    }

    static var prepareFailed: Self {
        .init(
            title: {
                TextState(String(localized: .RecordScreen.errorPrepareFailed))
            },
            actions: {
                ButtonState(
                    role: .cancel,
                    action: .closeAfterFailure
                ) {
                    TextState(String(localized: .buttonClose))
                }
            },
            message: {
                TextState(String(localized: .errorTryAgainLater))
            }
        )
    }

    static var saveFailed: Self {
        .init(
            title: {
                TextState(String(localized: .RecordScreen.errorSaveFailed))
            },
            actions: {
                ButtonState(
                    role: .cancel,
                    action: .closeAfterFailure
                ) {
                    TextState(String(localized: .buttonClose))
                }
            },
            message: {
                TextState(String(localized: .RecordScreen.errorSaveFailedMessage))
            }
        )
    }

}
