
import SwiftUI

import ComposableArchitecture

extension SettingScreen {

    struct GeneralSection: View {
        let store: StoreOf<Root.Feature>

        var body: some View {
            Section(String(localized: .SettingScreen.generalSectionTitleSection)) {
                Picker(
                    String(localized: .SettingScreen.generalSectionLabelDisplayMode),
                    selection: Binding(
                        get: { store.displayMode },
                        set: { store.send(.view(.displayModeChanged($0))) }
                    )
                ) {
                    ForEach(DisplayMode.allCases, id: \.self) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                Picker(
                    String(localized: .SettingScreen.generalSectionLabelSkipInterval),
                    selection: Binding(
                        get: { store.skipInterval },
                        set: { store.send(.view(.skipIntervalChanged($0))) }
                    )
                ) {
                    ForEach(SkipInterval.allCases, id: \.self) {
                        Text(.SettingScreen.generalSectionLabelSkipSeconds($0.rawValue))
                            .tag($0)
                    }
                }
                Toggle(
                    String(localized: .SettingScreen.generalSectionLabelAutoLockDisabled),
                    isOn: Binding(
                        get: { store.isIdleTimerDisabled },
                        set: { store.send(.view(.idleTimerDisabledChanged($0))) }
                    )
                )
                Button(
                    action: { store.send(.view(.tutorialButtonTapped)) },
                    label: {
                        Text(.SettingScreen.generalSectionButtonReplayTutorial)
                    }
                )
                .tint(.primary)
            }
        }
    }

}

fileprivate extension DisplayMode {

    var title: String {
        switch self {
            case .system:
                .init(localized: .SettingScreen.generalSectionLabelDisplayModeSystem)

            case .light:
                .init(localized: .SettingScreen.generalSectionLabelDisplayModeLight)

            case .dark:
                .init(localized: .SettingScreen.generalSectionLabelDisplayModeDark)
        }
    }

}

#Preview {
    Form {
        SettingScreen.GeneralSection(
            store: .init(
                initialState: .init(),
                reducer: { SettingScreen.Root.Feature() }
            )
        )
    }
}
