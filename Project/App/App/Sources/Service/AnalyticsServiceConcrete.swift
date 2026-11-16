
import UIKit
import StoreKit

import Common
import Domain
import FirebaseAnalytics

actor AnalyticsServiceConcrete {}

private extension AnalyticsServiceConcrete {

    enum Event: String, Diagnostics.Event {
        case configurationStarted = "configuration.started"
        case configurationCompleted = "configuration.completed"
    }

}

extension AnalyticsServiceConcrete: Service {

    @MainActor
    static func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        Diagnostics.log(Event.configurationStarted)
        configureFirebaseAnalytics()
        Diagnostics.log(Event.configurationCompleted)
        return true
    }

    private static func configureFirebaseAnalytics() {
        Analytics.setAnalyticsCollectionEnabled(false)

#if DEBUG
        Analytics.setAnalyticsCollectionEnabled(FirebaseService.isDebugEnabled)
#else
        Task {
            let environment: AppStore.Environment?
            do {
                switch try await AppTransaction.shared {
                    case .verified(let transaction):
                        environment = transaction.environment

                    case .unverified:
                        environment = nil
                }
            } catch {
                environment = nil
            }
            Analytics.setAnalyticsCollectionEnabled(environment == .production)
        }
#endif
    }

}

extension AnalyticsServiceConcrete: AnalyticsService {}
