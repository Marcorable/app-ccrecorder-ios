
import UIKit
import SwiftUI

extension SettingScreen {

    struct InformationSection: View {
        let appVersion: String

        var body: some View {
            Section(String(localized: .SettingScreen.informationSectionTitleAppInfo)) {
                LabeledContent(String(localized: .SettingScreen.informationSectionLabelVersion), value: appVersion)
                Link(
                    destination: URL(string: UIApplication.openSettingsURLString)!,
                    label: {
                        Label(
                            String(localized: .SettingScreen.informationSectionButtonOpenSourceLicenses),
                            systemImage: "arrow.up.forward"
                        )
                    }
                )
                Link(
                    destination: URL(string: "https://www.instagram.com/casualconversation_ccrecorder/")!,
                    label: {
                        Label(
                            String(localized: .SettingScreen.informationSectionButtonInstagram),
                            systemImage: "hand.thumbsup"
                        )
                    }
                )
                Link(
                    destination: URL(string: "mailto:pse.applications@gmail.com")!,
                    label: {
                        Label(
                            String(localized: .SettingScreen.informationSectionButtonContact),
                            systemImage: "envelope.open"
                        )
                    }
                )
            }
            .tint(.primary)
        }
    }

}

#Preview {
    Form {
        SettingScreen.InformationSection(appVersion: "1.0")
    }
}
