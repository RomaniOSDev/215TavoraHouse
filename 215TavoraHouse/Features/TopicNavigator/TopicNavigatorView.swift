import SwiftUI

struct TopicNavigatorView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TopicNavigatorViewModel()

    private var dueTopics: [Topic] { store.topicsDueForReview() }
    private var displayedTopics: [Topic] { viewModel.filteredTopics(from: store) }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    SearchBarView(text: $viewModel.searchText, placeholder: "Search topics...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    categoryFilterChips
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    if store.topics.isEmpty {
                        emptyState
                    } else {
                        topicList
                    }
                }

                VStack {
                    Spacer()
                    PrimaryButton(title: "Add Topic") {
                        viewModel.showAddSheet = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }

                SuccessCheckmarkBadge(isShowing: $viewModel.showSuccessBadge)
            }
            .navigationTitle("Topic Navigator")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showAddSheet) { addTopicSheet }
        }
    }

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChipView(title: "All", isSelected: viewModel.filterCategory == nil) {
                    FeedbackService.lightTap()
                    viewModel.filterCategory = nil
                }
                ForEach(TopicCategory.allCases) { category in
                    CategoryChipView(
                        title: category.displayName,
                        icon: category.systemImage,
                        isSelected: viewModel.filterCategory == category
                    ) {
                        FeedbackService.lightTap()
                        viewModel.filterCategory = category
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            EmptyStateView(
                icon: "book.fill",
                title: "No Topics Yet!",
                message: "Start adding your topics to study.",
                actionTitle: "Add Topic"
            ) {
                viewModel.showAddSheet = true
            }
            .padding(16)
            .padding(.bottom, 100)
        }
    }

    private var topicList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if !dueTopics.isEmpty {
                    SectionHeaderView(
                        title: "Due Today",
                        icon: "clock.badge.exclamationmark",
                        tint: Color("AppAccent")
                    )
                    .padding(.horizontal, 16)

                    ForEach(dueTopics) { topic in
                        NavigationLink {
                            TopicDetailView(topic: topic)
                        } label: {
                            AppCard(accentBorder: true) {
                                DueTodayCell(topic: topic)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }

                SectionHeaderView(title: "All Topics", icon: "books.vertical.fill")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if displayedTopics.isEmpty {
                    AppCard {
                        Text("No topics match your search.")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .padding(.horizontal, 16)
                } else {
                    ForEach(displayedTopics) { topic in
                        topicCard(topic)
                            .padding(.horizontal, 16)
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.top, 8)
        }
    }

    private func topicCard(_ topic: Topic) -> some View {
        NavigationLink {
            TopicDetailView(topic: topic)
        } label: {
            AppCard {
                TopicCell(
                    topic: topic,
                    progress: store.topicProgress[topic.id.uuidString] ?? 0,
                    showsCheckmark: viewModel.animatingKnownIds.contains(topic.id)
                )
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                viewModel.markLearning(topic, store: store)
            } label: {
                Label("Mark Learning", systemImage: "book")
            }
            Button {
                viewModel.markKnown(topic, store: store)
                SuccessCheckmarkBadge.trigger($viewModel.showSuccessBadge)
            } label: {
                Label("Mark Known", systemImage: "checkmark")
            }
        }
    }

    private var addTopicSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        TextField("Topic name", text: $viewModel.topicName)
                            .modifier(ShakeEffect(shakes: viewModel.shakeName ? 1 : 0))
                            .foregroundStyle(Color("AppTextPrimary"))
                        if let error = viewModel.nameError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(TopicCategory.allCases) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Notes (optional)", text: $viewModel.topicNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        viewModel.showAddSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { _ = viewModel.validateAndSave(using: store) }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
