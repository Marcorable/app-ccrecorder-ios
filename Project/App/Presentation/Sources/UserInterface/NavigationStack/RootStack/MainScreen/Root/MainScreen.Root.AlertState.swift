
import ComposableArchitecture

extension AlertState where Action == MainScreen.Root.Feature.Action.Alert {

    static var permissionDenied: Self {
        .init(
            title: {
                TextState(String(localized: .MainScreen.alertMicrophonePermissionRequired))
            },
            actions: {
                ButtonState(action: .openSettingsTapped) {
                    TextState(String(localized: .MainScreen.buttonOpenSettings))
                }
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonClose))
                }
            },
            message: {
                TextState(String(localized: .MainScreen.alertMicrophonePermissionMessage))
            }
        )
    }

    static var conversationLoadFailed: Self {
        retryAlert(
            title: String(localized: .MainScreen.errorConversationListLoadFailed),
            retryAction: .retryConversationLoad
        )
    }

    static var conversationDeleteFailed: Self {
        failureAlert(
            title: String(localized: .MainScreen.errorConversationDeleteFailed),
            message: String(localized: .MainScreen.errorConversationDeleteFailedMessage)
        )
    }

    static var noteLoadFailed: Self {
        retryAlert(
            title: String(localized: .MainScreen.errorNoteListLoadFailed),
            retryAction: .retryNoteLoad
        )
    }

    static var noteDeleteFailed: Self {
        failureAlert(
            title: String(localized: .MainScreen.errorNoteDeleteFailed),
            message: String(localized: .errorTryAgainLater)
        )
    }

    private static func retryAlert(
        title: String,
        retryAction: Action
    ) -> Self {
        .init(
            title: {
                TextState(title)
            },
            actions: {
                ButtonState(action: retryAction) {
                    TextState(String(localized: .MainScreen.buttonRetry))
                }
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonCancel))
                }
            },
            message: {
                TextState(String(localized: .errorTryAgainLater))
            }
        )
    }

    private static func failureAlert(
        title: String,
        message: String
    ) -> Self {
        .init(
            title: {
                TextState(title)
            },
            actions: {
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonConfirm))
                }
            },
            message: {
                TextState(message)
            }
        )
    }

}
