
public enum DomainError: Error, Sendable {
    case data(Error)
    case managingConversationUsecase(ManagingConversationUsecaseFailure)
    case managingNoteUsecase(ManagingNoteUsecaseFailure)
    case recordingUsecase(RecordingUsecaseFailure)
    case playingRecordUsecase(PlayingRecordUsecaseFailure)
}
