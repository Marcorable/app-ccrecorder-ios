
import Foundation

public enum Diagnostics {
    private static let storage = Storage()

    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        private var storedHandler: Handler?

        var handler: Handler? {
            lock.withLock {
                storedHandler
            }
        }

        func configure(_ handler: @escaping Handler) {
            lock.withLock {
                guard storedHandler == nil else {
                    assertionFailure("Diagnostics is already configured")
                    return
                }
                storedHandler = handler
            }
        }
    }

    public static func configure(_ handler: @escaping Handler) {
        storage.configure(handler)
    }

}

extension Diagnostics {

    public enum Level: Sendable {
        case debug
        case info
        case warn
        case error
    }

    public struct Entry: Sendable {
        public let level: Level
        public let message: String
        public let source: Source
    }

    public struct Source: Sendable {
        public let fileID: String
        public let function: String
        public let line: UInt
    }

    public protocol Event: RawRepresentable, Sendable where RawValue == String {}

    public typealias Handler = @Sendable (Entry) -> Void

}

extension Diagnostics {

    public static func log<Event: Diagnostics.Event>(
        of level: Level = .info,
        _ event: @autoclosure () -> Event,
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard let handler = storage.handler else {
            return
        }
        handler(
            .init(
                level: level,
                message: event().rawValue,
                source: .init(
                    fileID: String(describing: fileID),
                    function: String(describing: function),
                    line: line
                )
            )
        )
    }

}
