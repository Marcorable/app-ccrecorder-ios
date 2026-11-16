
import Foundation

import Common

final class ManagingNoteUsecaseConcrete: Sendable {
    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

private extension ManagingNoteUsecaseConcrete {

    enum Event: String, Diagnostics.Event {
        case loadStarted = "load.started"
        case loadCompleted = "load.completed"
        case loadFailed = "load.failed"
        case noteStarted = "note.started"
        case noteCompleted = "note.completed"
        case noteFailed = "note.failed"
        case updateStarted = "update.started"
        case updateCompleted = "update.completed"
        case updateFailed = "update.failed"
        case deleteStarted = "delete.started"
        case deleteCompleted = "delete.completed"
        case deleteFailed = "delete.failed"
    }

}

extension ManagingNoteUsecaseConcrete {

    struct Dependency: Sendable {
        let noteRepository: any NoteRepository
    }

}

extension ManagingNoteUsecaseConcrete: ManagingNoteUsecase {

    func loadNotes() async -> Result<[Note], DomainError> {
        Diagnostics.log(Event.loadStarted)
        do {
            let notes = try await dependency.noteRepository.read()
            Diagnostics.log(Event.loadCompleted)
            return .success(notes)
        } catch {
            Diagnostics.log(Event.loadFailed)
            return .failure(.managingNoteUsecase(.system(error)))
        }
    }

    func note(id: Note.ID) async -> Result<Note?, DomainError> {
        Diagnostics.log(Event.noteStarted)
        do {
            let note = try await dependency.noteRepository.read(id: id)
            Diagnostics.log(Event.noteCompleted)
            return .success(note)
        } catch {
            Diagnostics.log(Event.noteFailed)
            return .failure(.managingNoteUsecase(.system(error)))
        }
    }

    func updateNote(_ note: Note) async -> Result<Void, DomainError> {
        Diagnostics.log(Event.updateStarted)
        do {
            try await dependency.noteRepository.update(note)
            Diagnostics.log(Event.updateCompleted)
            return .success(())
        } catch {
            Diagnostics.log(Event.updateFailed)
            return .failure(.managingNoteUsecase(.system(error)))
        }
    }

    func deleteNotes(ids: [UUID]) async -> Result<Void, DomainError> {
        Diagnostics.log(Event.deleteStarted)
        do {
            try await dependency.noteRepository.delete(ids: ids)
            Diagnostics.log(Event.deleteCompleted)
            return .success(())
        } catch {
            Diagnostics.log(Event.deleteFailed)
            return .failure(.managingNoteUsecase(.system(error)))
        }
    }

}
