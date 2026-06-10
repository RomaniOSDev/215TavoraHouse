import SwiftUI

struct TopicDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var topic: Topic
    @State private var newChecklistItem = ""
    @State private var showSuccessBadge = false

    init(topic: Topic) {
        _topic = State(initialValue: topic)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    categoryBadge

                    notesSection(
                        title: "Key Thought",
                        placeholder: "Main concept...",
                        text: $topic.structuredNotes.keyThought
                    )

                    notesSection(
                        title: "Example",
                        placeholder: "Concrete example...",
                        text: $topic.structuredNotes.example
                    )

                    checklistSection
                    linkedBookmarksSection
                }
                .padding(16)
            }

            SuccessCheckmarkBadge(isShowing: $showSuccessBadge)
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveTopic()
                }
                .foregroundStyle(Color("AppPrimary"))
            }
        }
        .onAppear {
            store.recordTopicReview(topic)
        }
    }

    private var categoryBadge: some View {
        AppCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: topic.category.systemImage)
                        .foregroundStyle(Color("AppPrimary"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.category.displayName)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(topic.status.displayName)
                        .font(.caption)
                        .foregroundStyle(topic.status == .known ? Color("AppPrimary") : Color("AppAccent"))
                }
                Spacer()
            }
        }
    }

    private func notesSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(title: title, icon: title == "Key Thought" ? "lightbulb.fill" : "text.quote")
                TextField(placeholder, text: text, axis: .vertical)
                    .lineLimit(3...8)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
    }

    private var checklistSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(title: "Checklist", icon: "checklist")

                ForEach($topic.structuredNotes.checklist) { $item in
                    HStack(spacing: 10) {
                        Button {
                            FeedbackService.lightTap()
                            item.isCompleted.toggle()
                        } label: {
                            Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundStyle(item.isCompleted ? Color("AppPrimary") : Color("AppTextSecondary"))
                        }
                        .frame(minWidth: 44, minHeight: 44)

                        TextField("Task", text: $item.text)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .strikethrough(item.isCompleted)
                    }
                    .padding(.vertical, 4)
                }

                HStack {
                    TextField("Add checklist item", text: $newChecklistItem)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Button("Add") {
                        let trimmed = newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        FeedbackService.lightTap()
                        topic.structuredNotes.checklist.append(ChecklistItem(text: trimmed))
                        newChecklistItem = ""
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private var linkedBookmarksSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(title: "Linked Bookmarks", icon: "link")

                if store.bookmarks.isEmpty {
                    Text("No bookmarks available. Add bookmarks in Learning Summary.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.bookmarks, id: \.self) { bookmark in
                        let isLinked = topic.structuredNotes.linkedBookmarks.contains(bookmark)
                        Button {
                            FeedbackService.lightTap()
                            if isLinked {
                                topic.structuredNotes.linkedBookmarks.removeAll { $0 == bookmark }
                            } else {
                                topic.structuredNotes.linkedBookmarks.append(bookmark)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: isLinked ? "link.circle.fill" : "link.circle")
                                    .foregroundStyle(isLinked ? Color("AppPrimary") : Color("AppTextSecondary"))
                                Text(bookmark)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                    }
                }
            }
        }
    }

    private func saveTopic() {
        store.updateTopic(topic)
        FeedbackService.mediumTap()
        FeedbackService.success()
        SuccessCheckmarkBadge.trigger($showSuccessBadge)
    }
}
