
import Foundation

import Common

final class ManagingConversationUsecaseConcrete: Sendable {
    private let dependency: Dependency
    private let mutationLock = ConversationMutationLock()

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

private extension ManagingConversationUsecaseConcrete {

    enum Event: String, Diagnostics.Event {
        case conversationsStarted = "conversations.started"
        case conversationsCompleted = "conversations.completed"
        case conversationsFailed = "conversations.failed"
        case conversationStarted = "conversation.started"
        case conversationCompleted = "conversation.completed"
        case conversationFailed = "conversation.failed"
        case conversationDeleteStarted = "conversation-delete.started"
        case conversationDeleteCompleted = "conversation-delete.completed"
        case conversationDeleteFailed = "conversation-delete.failed"
        case notesStarted = "notes.started"
        case notesCompleted = "notes.completed"
        case notesFailed = "notes.failed"
        case conversationUpdateStarted = "conversation-update.started"
        case conversationUpdateCompleted = "conversation-update.completed"
        case conversationUpdateFailed = "conversation-update.failed"
        case noteAddStarted = "note-add.started"
        case noteAddCompleted = "note-add.completed"
        case noteAddFailed = "note-add.failed"
        case noteDeleteStarted = "note-delete.started"
        case noteDeleteCompleted = "note-delete.completed"
        case noteDeleteFailed = "note-delete.failed"
    }

}

extension ManagingConversationUsecaseConcrete {

    struct Dependency: Sendable {
        let conversationRepository: ConversationRepository
        let noteRepository: NoteRepository
        let recordFileRepository: RecordFileRepository
        let now: @Sendable () -> Date
    }

}

extension ManagingConversationUsecaseConcrete: ManagingConversationUsecase {

    func conversations() async -> Result<[Conversation], DomainError> {
        Diagnostics.log(Event.conversationsStarted)
        do {
            let conversations = try await dependency.conversationRepository.read()
            Diagnostics.log(Event.conversationsCompleted)
            return .success(conversations)
        } catch {
            Diagnostics.log(Event.conversationsFailed)
            return .failure(.managingConversationUsecase(.system(error)))
        }
    }

    func conversation(id: Conversation.ID) async -> Result<Conversation?, DomainError> {
        Diagnostics.log(Event.conversationStarted)
        do {
            let conversation = try await dependency.conversationRepository.read(id: id)
            Diagnostics.log(Event.conversationCompleted)
            return .success(conversation)
        } catch {
            Diagnostics.log(Event.conversationFailed)
            return .failure(.managingConversationUsecase(.system(error)))
        }
    }

    func deleteConversations(
        _ conversations: [Conversation]
    ) async -> Result<Void, DomainError> {
        Diagnostics.log(Event.conversationDeleteStarted)
        do {
            for conversation in conversations {
                if let fileURL = await dependency.recordFileRepository.fileURL(
                    of: conversation.recordFileName
                ), await dependency.recordFileRepository.fileExists(at: fileURL) {
                    try await dependency.recordFileRepository.removeFile(at: fileURL)
                }
            }
            try await dependency.conversationRepository.delete(
                ids: conversations.map(\.id)
            )
            Diagnostics.log(Event.conversationDeleteCompleted)
            return .success(())
        } catch {
            Diagnostics.log(Event.conversationDeleteFailed)
            return .failure(.managingConversationUsecase(.system(error)))
        }
    }

    func notes(
        conversationID: Conversation.ID
    ) async -> Result<[Note], DomainError> {
        Diagnostics.log(Event.notesStarted)
        do {
            guard let conversation = try await dependency.conversationRepository.read(
                id: conversationID
            ) else {
                Diagnostics.log(Event.notesFailed)
                return .failure(.managingConversationUsecase(.conversationNotFound))
            }
            let notes = try await dependency.noteRepository.read()
            let notesByID = Dictionary(
                uniqueKeysWithValues: notes.map { ($0.id, $0) }
            )
            let notesForConversation = conversation.noteIds.compactMap({ notesByID[$0] })
            Diagnostics.log(Event.notesCompleted)
            return .success(
                notesForConversation
            )
        } catch {
            Diagnostics.log(Event.notesFailed)
            return .failure(.managingConversationUsecase(.system(error)))
        }
    }

    func update(_ conversation: Conversation) async throws {
        Diagnostics.log(Event.conversationUpdateStarted)
        try await mutationLock.withLock(for: conversation.id) {
            do {
                guard var updatingItem = try await dependency.conversationRepository.read(
                    id: conversation.id
                ) else {
                    throw DomainError.managingConversationUsecase(.conversationNotFound)
                }
                updatingItem.title = conversation.title
                updatingItem.topic = conversation.topic
                updatingItem.parties = conversation.parties
                try await dependency.conversationRepository.update(updatingItem)
                Diagnostics.log(Event.conversationUpdateCompleted)
            } catch is CancellationError {
                Diagnostics.log(Event.conversationUpdateFailed)
                throw CancellationError()
            } catch let error as DomainError {
                Diagnostics.log(Event.conversationUpdateFailed)
                throw error
            } catch {
                Diagnostics.log(Event.conversationUpdateFailed)
                throw DomainError.managingConversationUsecase(.system(error))
            }
        }
    }

    func addNote(
        content: String,
        to conversationID: Conversation.ID
    ) async throws -> Conversation {
        Diagnostics.log(Event.noteAddStarted)
        return try await mutationLock.withLock(for: conversationID) {
            do {
                guard var updatingItem = try await dependency.conversationRepository.read(
                    id: conversationID
                ) else {
                    throw DomainError.managingConversationUsecase(.conversationNotFound)
                }
                guard !content.isEmpty else {
                    Diagnostics.log(Event.noteAddCompleted)
                    return updatingItem
                }

                let note = note(content: content)
                updatingItem.noteIds.append(note.id)
                try Task.checkCancellation()
                try await dependency.noteRepository.create(note)
                do {
                    try Task.checkCancellation()
                    try await dependency.conversationRepository.update(updatingItem)
                    Diagnostics.log(Event.noteAddCompleted)
                    return updatingItem
                } catch {
                    try? await dependency.noteRepository.delete(ids: [note.id])
                    throw error
                }
            } catch is CancellationError {
                Diagnostics.log(Event.noteAddFailed)
                throw CancellationError()
            } catch let error as DomainError {
                Diagnostics.log(Event.noteAddFailed)
                throw error
            } catch {
                Diagnostics.log(Event.noteAddFailed)
                throw DomainError.managingConversationUsecase(.system(error))
            }
        }
    }

    func deleteNotes(
        ids: [Note.ID],
        from conversationID: Conversation.ID
    ) async throws -> Conversation {
        Diagnostics.log(Event.noteDeleteStarted)
        return try await mutationLock.withLock(for: conversationID) {
            do {
                guard let conversation = try await dependency.conversationRepository.read(
                    id: conversationID
                ) else {
                    throw DomainError.managingConversationUsecase(.conversationNotFound)
                }
                guard !ids.isEmpty else {
                    Diagnostics.log(Event.noteDeleteCompleted)
                    return conversation
                }

                let idSet = Set(ids)
                var updatingItem = conversation
                updatingItem.noteIds.removeAll(where: { idSet.contains($0) })
                try Task.checkCancellation()
                try await dependency.conversationRepository.update(updatingItem)
                do {
                    try Task.checkCancellation()
                    try await dependency.noteRepository.delete(ids: ids)
                    Diagnostics.log(Event.noteDeleteCompleted)
                    return updatingItem
                } catch {
                    try? await dependency.conversationRepository.update(conversation)
                    throw error
                }
            } catch is CancellationError {
                Diagnostics.log(Event.noteDeleteFailed)
                throw CancellationError()
            } catch let error as DomainError {
                Diagnostics.log(Event.noteDeleteFailed)
                throw error
            } catch {
                Diagnostics.log(Event.noteDeleteFailed)
                throw DomainError.managingConversationUsecase(.system(error))
            }
        }
    }

}

private actor ConversationMutationLock {
    private var lockedIDs: Set<Conversation.ID> = []
    private var waiters: [Conversation.ID: [CheckedContinuation<Void, Never>]] = [:]

    func withLock<Value: Sendable>(
        for id: Conversation.ID,
        operation: @Sendable () async throws -> Value
    ) async rethrows -> Value {
        await lock(id)
        defer { unlock(id) }
        return try await operation()
    }

    private func lock(_ id: Conversation.ID) async {
        guard lockedIDs.contains(id) else {
            lockedIDs.insert(id)
            return
        }
        await withCheckedContinuation { continuation in
            waiters[id, default: []].append(continuation)
        }
    }

    private func unlock(_ id: Conversation.ID) {
        guard var queuedWaiters = waiters[id], !queuedWaiters.isEmpty else {
            lockedIDs.remove(id)
            waiters[id] = nil
            return
        }
        let continuation = queuedWaiters.removeFirst()
        waiters[id] = queuedWaiters.isEmpty ? nil : queuedWaiters
        continuation.resume()
    }
}

private extension ManagingConversationUsecaseConcrete {

    func note(content: String) -> Note {
        let particleCount = content.components(separatedBy: " ").count
        let category: Note.Category = particleCount > 2
            ? .sentence
            : .vocabulary

        switch language(of: content) {
            case .english:
                return .init(
                    createdDate: dependency.now(),
                    original: content,
                    translation: "",
                    category: category
                )

            case .korean, .mixed:
                return .init(
                    createdDate: dependency.now(),
                    original: "",
                    translation: content,
                    category: category
                )
        }
    }

    func language(of content: String) -> Language {
        let isKorean = content.range(
            of: "[가-힣]",
            options: .regularExpression
        ) != nil
        let isEnglish = content.range(
            of: "[A-Za-z]",
            options: .regularExpression
        ) != nil

        if isKorean && isEnglish {
            return .mixed
        } else if isKorean {
            return .korean
        } else {
            return .english
        }
    }

    enum Language {
        case korean
        case english
        case mixed
    }

}
