
import SwiftUI
import Foundation

extension NoteBoard {

    struct Row: View {
        let viewModel: ViewModel

        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: viewModel.isVocabulary ? "textformat.abc" : "text.bubble.fill")
                        .foregroundStyle(Color(asset: Asset.Logo.Prominent.red))
                        .frame(width: 36, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(viewModel.title)
                        Text(viewModel.subTitle)
                            .font(.caption)
                            .foregroundStyle(viewModel.subTitleColor)
                    }
                    Spacer()
                    Image(systemName: viewModel.noteContentImageName)
                        .foregroundStyle(viewModel.noteContentColor)
                }
                .font(.body)
                Divider()
            }
            .contentShape(.rect)
        }
    }

}

extension NoteBoard.Row {

    struct ViewModel: Equatable, Identifiable {
        let id: UUID
        let original: String
        let translation: String
        let isVocabulary: Bool

        private var isDone: Bool {
            !original.isEmpty && !translation.isEmpty
        }

        var title: String {
            original.isEmpty ? translation : original
        }

        var subTitle: String {
            switch isDone {
                case true:
                    translation
                case false:
                    if isVocabulary {
                        .init(
                            localized: original.isEmpty
                                ? .noteBoardPromptVocabularyTranslation
                                : .noteBoardPromptVocabularyOriginal
                        )
                    } else {
                        .init(
                            localized: original.isEmpty
                                ? .noteBoardPromptSentenceTranslation
                                : .noteBoardPromptSentenceOriginal
                        )
                    }
            }
        }

        var subTitleColor: Color {
            isDone ? .gray : .init(asset: Asset.Icon.accent)
        }

        var noteContentImageName: String {
            isDone ? "checkmark.circle.fill" : "\(original.isEmpty ? "k" : "e").circle"
        }

        var noteContentColor: Color {
            .init(asset: isDone ? Asset.Logo.Prominent.blue : Asset.Logo.Muted.blue)
        }
    }

}

#Preview {
    NoteBoard.Row(
        viewModel: .init(
            id: .init(),
            original: "How have you been?",
            translation: "어떻게 지냈어요?",
            isVocabulary: false
        )
    )
}
