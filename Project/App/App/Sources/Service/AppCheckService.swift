
import UIKit

import FirebaseAppCheck

enum AppCheckService {}

extension AppCheckService: Service {

    @MainActor
    static func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = AppAttestProviderFactory()
        #endif

        AppCheck.setAppCheckProviderFactory(providerFactory)
        return true
    }

}
