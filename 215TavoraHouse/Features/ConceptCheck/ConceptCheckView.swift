import SwiftUI

struct ConceptCheckView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = ConceptCheckViewModel()

    private var filteredQuestions: [QuizQuestion] {
        viewModel.filteredQuestions(from: store)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    topicPicker
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    SearchBarView(text: $viewModel.searchText, placeholder: "Search questions...")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    if store.quizQuestions.isEmpty {
                        emptyState
                    } else if filteredQuestions.isEmpty {
                        noResultsState
                    } else {
                        questionList
                    }

                    PrimaryButton(title: "Review Summary") {
                        viewModel.showSummarySheet = true
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Concept Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        viewModel.newQuestionTopicId = viewModel.selectedTopicId
                        viewModel.showEditSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet) { addQuestionSheet }
            .sheet(isPresented: $viewModel.showSummarySheet) { reviewSummarySheet }
        }
    }

    private var topicPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChipView(title: "All Topics", icon: "square.grid.2x2", isSelected: viewModel.selectedTopicId == nil) {
                    FeedbackService.lightTap()
                    viewModel.selectedTopicId = nil
                }
                ForEach(store.topics) { topic in
                    CategoryChipView(
                        title: topic.title,
                        icon: topic.category.systemImage,
                        isSelected: viewModel.selectedTopicId == topic.id
                    ) {
                        FeedbackService.lightTap()
                        viewModel.selectedTopicId = topic.id
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            EmptyStateView(
                icon: "lightbulb.fill",
                title: "No Quiz Sessions Yet",
                message: "Tap + to add questions and start practicing."
            )
            .padding(.top, 40)
        }
    }

    private var noResultsState: some View {
        ScrollView {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "Try a different search or topic filter."
            )
            .padding(.top, 40)
        }
    }

    private var questionList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(filteredQuestions) { question in
                    QuizQuestionCell(
                        question: question,
                        topicTitle: store.topicTitle(for: question.topicId),
                        state: viewModel.answerState(for: question.id, store: store),
                        onSelectOption: { index in
                            var newState = viewModel.answerState(for: question.id, store: store)
                            newState.selectedIndex = index
                            store.quizAnswerStates[question.id.uuidString] = newState
                            FeedbackService.lightTap()
                            FeedbackService.tick()
                        },
                        onSubmit: {
                            viewModel.submitAnswer(for: question, store: store)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var reviewSummarySheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        AppCard {
                            VStack(spacing: 8) {
                                SummaryMetricRow(label: "Questions Answered", value: "\(store.questionsAnswered)", icon: "questionmark.circle")
                                Divider().background(Color("AppTextSecondary").opacity(0.2))
                                SummaryMetricRow(label: "Quizzes Completed", value: "\(store.quizzesCompleted)", icon: "checkmark.circle")
                                Divider().background(Color("AppTextSecondary").opacity(0.2))
                                SummaryMetricRow(label: "Average Score", value: "\(viewModel.averageScore(from: store))%", icon: "percent")
                                Divider().background(Color("AppTextSecondary").opacity(0.2))
                                SummaryMetricRow(label: "Total Sessions", value: "\(store.totalSessionsCompleted)", icon: "clock")
                            }
                        }

                        let focusAreas = store.focusAreas()
                        if !focusAreas.isEmpty {
                            SectionHeaderView(title: "Focus Areas", icon: "target", tint: Color("AppAccent"))
                            ForEach(focusAreas) { area in
                                FocusAreaCell(area: area)
                            }
                        }

                        if !store.userScores.isEmpty {
                            SectionHeaderView(title: "Recent Scores", icon: "chart.line.uptrend.xyaxis")
                            AppCard {
                                VStack(spacing: 8) {
                                    ForEach(Array(store.userScores.suffix(10).enumerated()), id: \.offset) { index, score in
                                        if index > 0 {
                                            Divider().background(Color("AppTextSecondary").opacity(0.2))
                                        }
                                        SummaryMetricRow(label: "Session \(index + 1)", value: "\(score)%")
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Review Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackService.lightTap()
                        viewModel.showSummarySheet = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private var addQuestionSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        Picker("Topic", selection: $viewModel.newQuestionTopicId) {
                            Text("No topic").tag(UUID?.none)
                            ForEach(store.topics) { topic in
                                Text(topic.title).tag(Optional(topic.id))
                            }
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Question", text: $viewModel.newQuestion, axis: .vertical)
                            .lineLimit(2...4)
                            .modifier(ShakeEffect(shakes: viewModel.shakeQuestion ? 1 : 0))
                            .foregroundStyle(Color("AppTextPrimary"))
                        if let error = viewModel.questionError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                    Section("Options") {
                        ForEach(0..<4, id: \.self) { index in
                            HStack {
                                TextField("Option \(index + 1)", text: $viewModel.newOptions[index])
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Button {
                                    FeedbackService.lightTap()
                                    viewModel.correctOptionIndex = index
                                } label: {
                                    Image(systemName: viewModel.correctOptionIndex == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                                .frame(minWidth: 44, minHeight: 44)
                            }
                            .listRowBackground(Color("AppSurface"))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        viewModel.showEditSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { _ = viewModel.addQuestion(store: store) }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
