
import UIKit

import Common
import Domain
import FirebaseCrashlytics

actor CrashReportingServiceConcrete {}

private extension CrashReportingServiceConcrete {

    enum Event: String, Diagnostics.Event {
        case configurationStarted = "configuration.started"
        case configurationCompleted = "configuration.completed"
    }

}

extension CrashReportingServiceConcrete: Service {

    @MainActor
    static func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        Diagnostics.log(Event.configurationStarted)
        configureFirebaseCrashlytics()
        Diagnostics.log(Event.configurationCompleted)
        return true
    }

    private static func configureFirebaseCrashlytics() {
        let crashlytics = Crashlytics.crashlytics()
#if DEBUG
        crashlytics.setCrashlyticsCollectionEnabled(false)
        if FirebaseService.isDebugEnabled {
            crashlytics.sendUnsentReports()
        }
#else
        crashlytics.setCrashlyticsCollectionEnabled(true)
#endif
    }

}

extension CrashReportingServiceConcrete: CrashReportingService {}
