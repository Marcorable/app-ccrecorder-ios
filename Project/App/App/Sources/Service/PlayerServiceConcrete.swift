
import AVFAudio
import Foundation

import Common
import Domain

actor PlayerServiceConcrete {
    private var player: AVAudioPlayer?
    private var delegate: Delegate?

    var isPrepared: Bool { player != nil }
    var isPlaying: Bool { player?.isPlaying ?? false }
    var currentTime: TimeInterval { player?.currentTime ?? .zero }
    var duration: TimeInterval { player?.duration ?? .zero }
    var rate: Float { player?.rate ?? 1 }
}

private extension PlayerServiceConcrete {

    enum Event: String, Diagnostics.Event {
        case prepareStarted = "prepare.started"
        case prepareCompleted = "prepare.completed"
        case prepareFailed = "prepare.failed"
        case playIgnored = "play.ignored"
        case playbackStarted = "playback.started"
        case pauseIgnored = "pause.ignored"
        case playbackPaused = "playback.paused"
        case playbackFinished = "playback.finished"
        case seekIgnored = "seek.ignored"
        case seekCompleted = "seek.completed"
        case rateChangeIgnored = "rate-change.ignored"
        case rateChanged = "rate.changed"
        case playbackCompleted = "playback.completed"
        case playbackFailed = "playback.failed"
    }

}

extension PlayerServiceConcrete: Service {

}

extension PlayerServiceConcrete: PlayerService {

    func prepare(with fileURL: URL) throws(DomainError.PlayerServiceFailure) {
        Diagnostics.log(Event.prepareStarted)
        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.enableRate = true
            player.numberOfLoops = 0
            player.volume = 1
            player.rate = 1

            let id = UUID()
            let delegate = Delegate(
                id: id,
                finish: { [weak self] in
                    Task { await self?.didFinish(id: id) }
                },
                fail: { [weak self] in
                    Task { await self?.didFail(id: id) }
                }
            )
            player.delegate = delegate

            guard player.prepareToPlay() else {
                throw DomainError.PlayerServiceFailure.prepareToPlayFalse
            }

            finish()
            self.player = player
            self.delegate = delegate
            Diagnostics.log(Event.prepareCompleted)
        } catch {
            Diagnostics.log(Event.prepareFailed)
            if let failure = error as? DomainError.PlayerServiceFailure {
                throw failure
            }
            throw .system(error)
        }
    }

    func play() {
        guard let player, player.play() else {
            Diagnostics.log(Event.playIgnored)
            return
        }
        Diagnostics.log(Event.playbackStarted)
    }

    func pause() {
        guard let player, player.isPlaying else {
            Diagnostics.log(Event.pauseIgnored)
            return
        }
        player.pause()
        Diagnostics.log(Event.playbackPaused)
    }

    func finish() {
        player?.stop()
        player = nil
        delegate = nil
        Diagnostics.log(Event.playbackFinished)
    }

    func seek(to time: TimeInterval) {
        guard let player else {
            Diagnostics.log(Event.seekIgnored)
            return
        }
        player.currentTime = min(
            max(time, .zero),
            player.duration
        )
        Diagnostics.log(Event.seekCompleted)
    }

    func changeRate(to value: Float) {
        guard let player else {
            Diagnostics.log(Event.rateChangeIgnored)
            return
        }
        player.rate = min(
            max(value, 0.5),
            2
        )
        Diagnostics.log(Event.rateChanged)
    }

}

private extension PlayerServiceConcrete {

    func didFinish(id: UUID) {
        guard delegate?.id == id else {
            return
        }
        player?.currentTime = .zero
        Diagnostics.log(Event.playbackCompleted)
    }

    func didFail(id: UUID) {
        guard delegate?.id == id else {
            return
        }
        player?.stop()
        player = nil
        delegate = nil
        Diagnostics.log(Event.playbackFailed)
    }

}

private extension PlayerServiceConcrete {

    final class Delegate: NSObject, AVAudioPlayerDelegate, @unchecked Sendable {
        let id: UUID
        private let finish: @Sendable () -> Void
        private let fail: @Sendable () -> Void

        nonisolated init(
            id: UUID,
            finish: @escaping @Sendable () -> Void,
            fail: @escaping @Sendable () -> Void
        ) {
            self.id = id
            self.finish = finish
            self.fail = fail
        }

        func audioPlayerDidFinishPlaying(
            _ player: AVAudioPlayer,
            successfully flag: Bool
        ) {
            finish()
        }

        func audioPlayerDecodeErrorDidOccur(
            _ player: AVAudioPlayer,
            error: Error?
        ) {
            fail()
        }
    }

}
