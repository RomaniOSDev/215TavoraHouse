import SwiftUI
import UIKit

struct LearningSummaryView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = LearningSummaryViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    Picker("View", selection: $viewModel.segment) {
                        Text("Weekly Overview").tag(0)
                        Text("Bookmarks").tag(1)
                        Text("Journal").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .onChange(of: viewModel.segment) { _ in FeedbackService.lightTap() }

                    switch viewModel.segment {
                    case 0: weeklyOverview
                    case 1: bookmarksView
                    default: journalView
                    }

                    if viewModel.segment != 2 {
                        PrimaryButton(title: "Add Bookmark") {
                            viewModel.showAddBookmarkSheet = true
                        }
                        .padding(16)
                    }
                }

                SuccessCheckmarkBadge(isShowing: $viewModel.showSuccessBadge)
            }
            .navigationTitle("Learning Summary")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showAddBookmarkSheet) { addBookmarkSheet }
            .sheet(isPresented: $viewModel.showReflectionSheet) { reflectionSheet }
            .onChange(of: scenePhase) { phase in viewModel.updateScenePhase(phase) }
        }
    }

    private var hasOverviewData: Bool {
        !store.topics.isEmpty || store.studyMinutes > 0
    }

    private var weeklyOverview: some View {
        Group {
            if !hasOverviewData {
                ScrollView {
                    EmptyStateView(
                        icon: "lightbulb",
                        title: "No Data Yet",
                        message: "No data yet – Start tracking your progress today!"
                    )
                    .padding(.top, 40)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        sessionPlanCard
                        studyTimerCard

                        ForEach(store.topicsGroupedByCategory(), id: \.0) { category, categoryTopics in
                            SectionHeaderView(
                                title: category.displayName,
                                icon: category.systemImage,
                                tint: Color("AppPrimary")
                            )
                            .padding(.top, 4)

                            ForEach(categoryTopics) { topic in
                                ProgressTopicCell(
                                    topic: topic,
                                    progress: store.topicProgress[topic.id.uuidString] ?? (topic.status == .known ? 1.0 : 0.0),
                                    isExpanded: viewModel.expandedTopicIds.contains(topic.id.uuidString),
                                    weeklyTimeLabel: formatDuration(viewModel.weeklyTime(for: topic.title, store: store)),
                                    comprehensionPercent: viewModel.comprehensionScore(for: topic, store: store),
                                    isPulsing: viewModel.pulsingTopicId == topic.id.uuidString,
                                    onToggle: { viewModel.toggleExpanded(topic.id.uuidString) }
                                )
                                .contextMenu {
                                    Button {
                                        store.toggleBookmark(topic.title)
                                        viewModel.pulseTopic(topic.id.uuidString)
                                        if store.bookmarks.contains(topic.title) {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            FeedbackService.bookmarkSound()
                                        }
                                        FeedbackService.lightTap()
                                    } label: {
                                        Label(
                                            store.bookmarks.contains(topic.title) ? "Unbookmark" : "Bookmark",
                                            systemImage: "bookmark"
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
    }

    private var sessionPlanCard: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "Session Plan", icon: "flag.fill", tint: Color("AppAccent"))

                Picker("Topic", selection: Binding(
                    get: { store.sessionPlan.topicId },
                    set: { store.sessionPlan.topicId = $0 }
                )) {
                    Text("Any topic").tag(UUID?.none)
                    ForEach(store.topics) { topic in
                        Text(topic.title).tag(Optional(topic.id))
                    }
                }
                .foregroundStyle(Color("AppTextPrimary"))

                Picker("Goal type", selection: Binding(
                    get: { store.sessionPlan.goalType },
                    set: { newType in
                        FeedbackService.lightTap()
                        store.sessionPlan.goalType = newType
                        store.sessionPlan.goalValue = newType == .minutes ? 25 : 3
                    }
                )) {
                    Text("25 min").tag(SessionGoalType.minutes)
                    Text("3 quizzes").tag(SessionGoalType.quizCount)
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("Goal progress")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text(viewModel.sessionGoalLabel(store: store))
                        .foregroundStyle(Color("AppAccent"))
                        .font(.caption.bold())
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("AppBackground").opacity(0.5))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("AppAccent"))
                            .frame(width: geo.size.width * viewModel.sessionGoalProgress(store: store))
                    }
                }
                .frame(height: 8)
            }
        }
        .onAppear {
            if store.sessionPlan.goalValue == 0 { store.sessionPlan.goalValue = 25 }
        }
    }

    private var studyTimerCard: some View {
        AppCard {
            VStack(spacing: 14) {
                SectionHeaderView(title: "Study Timer", icon: "timer")

                Text(formattedTime(viewModel.studySeconds))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color("AppAccent"))

                HStack(spacing: 12) {
                    Button {
                        FeedbackService.lightTap()
                        if viewModel.isTimerRunning { viewModel.pauseTimer() }
                        else { viewModel.startTimer(store: store) }
                    } label: {
                        Text(viewModel.isTimerRunning ? "Pause" : "Start")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color("AppPrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)

                    Button {
                        viewModel.commitStudyTime(store: store)
                        SuccessCheckmarkBadge.trigger($viewModel.showSuccessBadge)
                    } label: {
                        Text("Save Session")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color("AppBackground").opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                }
            }
        }
    }

    private var bookmarksView: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $viewModel.bookmarkSearchText, placeholder: "Search bookmarks...")
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if store.bookmarks.isEmpty {
                ScrollView {
                    EmptyStateView(icon: "bookmark", title: "No Bookmarks", message: "Save insights from your study sessions.")
                        .padding(.top, 40)
                }
            } else {
                let items = viewModel.filteredBookmarks(from: store)
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if items.isEmpty {
                            AppCard {
                                Text("No bookmarks match your search.")
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        } else {
                            ForEach(items, id: \.self) { bookmark in
                                BookmarkCell(title: bookmark)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.removeBookmark(bookmark)
                                            FeedbackService.lightTap()
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var journalView: some View {
        Group {
            if store.reflectionEntries.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "text.book.closed",
                        title: "Reflection Journal",
                        message: "No reflections yet. Complete a study session to add one."
                    )
                    .padding(.top, 40)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.reflectionEntries) { entry in
                            ReflectionCell(
                                entry: entry,
                                topicTitle: store.topicTitle(for: entry.topicId)
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var reflectionSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        Text("What did I learn?")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .listRowBackground(Color.clear)
                        TextField("Write your reflection...", text: $viewModel.reflectionText, axis: .vertical)
                            .lineLimit(4...10)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { viewModel.skipReflection() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveReflection(store: store)
                        SuccessCheckmarkBadge.trigger($viewModel.showSuccessBadge)
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var addBookmarkSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        TextField("Insight or topic", text: $viewModel.bookmarkTitle)
                            .modifier(ShakeEffect(shakes: viewModel.shakeBookmark ? 1 : 0))
                            .foregroundStyle(Color("AppTextPrimary"))
                        if let error = viewModel.bookmarkError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        viewModel.showAddBookmarkSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.addBookmark(store: store) {
                            SuccessCheckmarkBadge.trigger($viewModel.showSuccessBadge)
                        }
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        "\(Int(interval) / 60) min"
    }
}
