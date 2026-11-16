
import AVFAudio

import Common
import Domain

actor RecorderServiceConcrete {
    private var recorder: AVAudioRecorder?

    var isRecording: Bool {
        recorder?.isRecording ?? false
    }

    var currentTime: TimeInterval {
        recorder?.currentTime ?? .zero
    }

    init() {}
}

private extension RecorderServiceConcrete {

    enum Event: String, Diagnostics.Event {
        case prepareStarted = "prepare.started"
        case prepareCompleted = "prepare.completed"
        case prepareFailed = "prepare.failed"
        case startIgnored = "start.ignored"
        case recordingStarted = "recording.started"
        case pauseIgnored = "pause.ignored"
        case recordingPaused = "recording.paused"
        case recordingFinished = "recording.finished"
        case recordingCancelled = "recording.cancelled"
    }

}

extension RecorderServiceConcrete: Service {

}

extension RecorderServiceConcrete: RecorderService {

    func prepare(with fileURL: URL) async throws(DomainError.RecorderServiceFailure) {
        Diagnostics.log(Event.prepareStarted)
        do {
            let recorder = try AVAudioRecorder(
                url: fileURL,
                settings: [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
            )

            guard recorder.prepareToRecord() else {
                throw DomainError.RecorderServiceFailure.prepareToRecordFalse
            }

            self.recorder?.stop()
            self.recorder = recorder
            Diagnostics.log(Event.prepareCompleted)
        } catch {
            Diagnostics.log(Event.prepareFailed)
            if let failure = error as? DomainError.RecorderServiceFailure {
                throw failure
            }
            throw .system(error)
        }
    }

    func start() async {
        guard
            let recorder,
            !recorder.isRecording,
            recorder.record()
        else {
            Diagnostics.log(of: .warn, Event.startIgnored)
            return
        }
        Diagnostics.log(Event.recordingStarted)
    }

    func pause() async {
        guard let recorder, recorder.isRecording else {
            Diagnostics.log(of: .warn, Event.pauseIgnored)
            return
        }
        recorder.pause()
        Diagnostics.log(Event.recordingPaused)
    }

    func finish() async throws(DomainError.RecorderServiceFailure) -> URL {
        guard let recorder else {
            throw DomainError.RecorderServiceFailure.notPrepared
        }

        let fileURL = recorder.url
        recorder.stop()
        self.recorder = nil
        Diagnostics.log(Event.recordingFinished)

        return fileURL
    }

    func cancel() async {
        recorder?.stop()
        recorder = nil
        Diagnostics.log(Event.recordingCancelled)
    }

}
