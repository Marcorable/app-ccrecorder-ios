
import Foundation

import Common

actor PlayingRecordUsecaseConcrete {
    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

private extension PlayingRecordUsecaseConcrete {

    enum Event: String, Diagnostics.Event {
        case prepareStarted = "prepare.started"
        case prepareCompleted = "prepare.completed"
        case prepareFailed = "prepare.failed"
        case playbackStarted = "playback.started"
        case playbackPaused = "playback.paused"
        case playbackFinished = "playback.finished"
        case seekCompleted = "seek.completed"
        case rateChanged = "rate.changed"
    }

}

extension PlayingRecordUsecaseConcrete {

    struct Dependency: Sendable {
        let playerService: PlayerService
        let recordFileRepository: RecordFileRepository
    }

}

extension PlayingRecordUsecaseConcrete: PlayingRecordUsecase {

    var isPrepared: Bool {
        get async {
            await dependency.playerService.isPrepared
        }
    }

    var isPlaying: Bool {
        get async {
            await dependency.playerService.isPlaying
        }
    }

    var currentTime: TimeInterval {
        get async {
            await dependency.playerService.currentTime
        }
    }

    var duration: TimeInterval {
        get async {
            await dependency.playerService.duration
        }
    }

    var rate: Float {
        get async {
            await dependency.playerService.rate
        }
    }

    func prepare(fileName: String) async throws {
        Diagnostics.log(Event.prepareStarted)
        guard
            let fileURL = await dependency.recordFileRepository.fileURL(of: fileName),
            await dependency.recordFileRepository.fileExists(at: fileURL)
        else {
            Diagnostics.log(Event.prepareFailed)
            throw DomainError.playingRecordUsecase(.fileNotFound)
        }

        do {
            try Task.checkCancellation()
            try await dependency.playerService.prepare(with: fileURL)
            try Task.checkCancellation()
            Diagnostics.log(Event.prepareCompleted)
        } catch is CancellationError {
            Diagnostics.log(Event.prepareFailed)
            await dependency.playerService.finish()
            throw CancellationError()
        } catch {
            Diagnostics.log(Event.prepareFailed)
            await dependency.playerService.finish()
            throw DomainError.playingRecordUsecase(.prepareFailed)
        }
    }

    func play() async {
        await dependency.playerService.play()
        Diagnostics.log(Event.playbackStarted)
    }

    func pause() async {
        await dependency.playerService.pause()
        Diagnostics.log(Event.playbackPaused)
    }

    func finish() async {
        await dependency.playerService.finish()
        Diagnostics.log(Event.playbackFinished)
    }

    func seek(to time: TimeInterval) async {
        await dependency.playerService.seek(to: time)
        Diagnostics.log(Event.seekCompleted)
    }

    func changeRate(to value: Float) async {
        await dependency.playerService.changeRate(to: value)
        Diagnostics.log(Event.rateChanged)
    }

}
