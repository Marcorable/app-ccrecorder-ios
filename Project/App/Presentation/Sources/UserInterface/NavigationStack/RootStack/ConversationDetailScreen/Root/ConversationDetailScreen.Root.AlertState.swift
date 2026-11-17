import ComposableArchitecture

extension AlertState where Action == ConversationDetailScreen.Root.Feature.Action.Alert {

    static var playbackInterrupted: Self {
        .init(
            title: {
                TextState(String(localized: .ConversationDetailScreen.alertPlaybackPaused))
            },
            actions: {
                ButtonState(action: .close) {
                    TextState(String(localized: .buttonClose))
                }
                ButtonState(role: .cancel) {
                    TextState(String(localized: .buttonConfirm))
                }
            },
            message: {
                TextState(String(localized: .ConversationDetailScreen.alertPlaybackInterrupted))
            }
        )
    }

    static func playbackFailed(message: String) -> Self {
        .init(
            title: {
                TextState(String(localized: .ConversationDetailScreen.playbackPanelLabelUnavailable))
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
