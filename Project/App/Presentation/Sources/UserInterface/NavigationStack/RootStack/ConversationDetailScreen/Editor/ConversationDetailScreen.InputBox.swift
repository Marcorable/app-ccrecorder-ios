
import UIKit
import SwiftUI

import ComposableArchitecture

extension ConversationDetailScreen.Editor {

    struct InputBox: View {
        let store: StoreOf<Feature>
        let focusedField: FocusState<Field?>.Binding

        var body: some View {
            GroupBox {
                HStack {
                    TextField(
                        String(localized: .ConversationDetailScreen.inputBoxLabelNoteInput),
                        text: Binding(
                            get: { store.noteInput },
                            set: { store.send(.view(.noteInputChanged($0))) }
                        ),
                        prompt: Text(.ConversationDetailScreen.inputBoxPromptNoteInput)
                    )
                    .trailingAction(
                        of: !store.noteInput.isEmpty,
                        label: {
                            Image(systemName: "multiply.circle.fill")
                                .accessibilityLabel(String(localized: .accessibilityClearInput))
                        },
                        action: { store.send(.view(.noteInputChanged(""))) }
                    )
                    .textFieldStyle(.roundedBorder)
                    .focused(focusedField, equals: .inputNote)
                    .onSubmit { store.send(.view(.noteAdded)) }
                    Button(
                        action: { store.send(.view(.noteAdded)) },
                        label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .padding(.leading)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(
                        action: {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                        },
                        label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    )
                    Spacer()
                    Button(String(localized: .ConversationDetailScreen.inputBoxButtonAdd)) {
                        store.send(.view(.noteAdded))
                    }
                }
            }
        }
    }

}

#Preview("Input") {
    @Previewable @FocusState var focusedField: ConversationDetailScreen.Editor.Field?

    ConversationDetailScreen.Editor.InputBox(
        store: .init(
            initialState: .init(
                conversationID: .init(),
                title: "영어 회화",
                createdDate: .init(timeIntervalSince1970: 1_735_689_600),
                topic: "여행 계획",
                noteInput: "Where should we meet?",
                rows: [NoteBoard.Row.ViewModel]()
            ),
            reducer: { ConversationDetailScreen.Editor.Feature() },
            withDependencies: {
                $0.managingConversationUsecase = .preview
            }
        ),
        focusedField: $focusedField
    )
}
