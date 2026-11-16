
import UIKit

import Common
#if DEBUG
import NectoSDK
import NectoEventsPlugin
#endif

enum DiagnosticsService {}

extension DiagnosticsService: Service {

    @MainActor
    static func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        #if DEBUG
        let events = NectoEventsPlugin()
        NectoSDK.register(events)
        NectoSDK.start()
        Diagnostics.configure { [events] entry in
            events.report(
                .init(
                    level: entry.level.nectoLevel,
                    tag: entry.source.fileID
                        .split(separator: "/")
                        .last
                        .flatMap({ String($0) }) ?? entry.source.fileID,
                    message: entry.message
                )
            )
        }
        #endif
        return true
    }

}

fileprivate extension Diagnostics.Level {

    #if DEBUG
    var nectoLevel: NectoEvent.Level {
        switch self {
            case .debug:    .debug
            case .info:     .info
            case .warn:     .warn
            case .error:    .error
        }
    }
    #endif

}
