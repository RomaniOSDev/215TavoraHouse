import Combine
import Foundation

final class AppDataStore: ObservableObject {
    static let reviewIntervalDays = 3
    private static let dataLibraryVersion = 2

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let topics = "topics"
        static let lastViewedTopicId = "lastViewedTopicId"
        static let cardsReviewed = "cardsReviewed"
        static let quizzesCompleted = "quizzesCompleted"
        static let topicsCompleted = "topicsCompleted"
        static let studyMinutes = "studyMinutes"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let userScores = "userScores"
        static let questionsAnswered = "questionsAnswered"
        static let topicProgress = "topicProgress"
        static let weeklyStats = "weeklyStats"
        static let bookmarks = "bookmarks"
        static let quizQuestions = "quizQuestions"
        static let quizAnswerStates = "quizAnswerStates"
        static let hasInitializedSamples = "hasInitializedSamples"
        static let reflectionEntries = "reflectionEntries"
        static let activityDates = "activityDates"
        static let sessionPlan = "sessionPlan"
        static let dataLibraryVersion = "dataLibraryVersion"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var topics: [Topic] {
        didSet { save(topics, forKey: Keys.topics) }
    }

    @Published var lastViewedTopicId: UUID? {
        didSet {
            if let id = lastViewedTopicId {
                defaults.set(id.uuidString, forKey: Keys.lastViewedTopicId)
            } else {
                defaults.removeObject(forKey: Keys.lastViewedTopicId)
            }
        }
    }

    @Published var cardsReviewed: Int {
        didSet {
            defaults.set(cardsReviewed, forKey: Keys.cardsReviewed)
            checkAchievements()
        }
    }

    @Published var quizzesCompleted: Int {
        didSet {
            defaults.set(quizzesCompleted, forKey: Keys.quizzesCompleted)
            checkAchievements()
        }
    }

    @Published var topicsCompleted: Int {
        didSet {
            defaults.set(topicsCompleted, forKey: Keys.topicsCompleted)
            checkAchievements()
        }
    }

    @Published var studyMinutes: Int {
        didSet {
            defaults.set(studyMinutes, forKey: Keys.studyMinutes)
            checkAchievements()
        }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet {
            defaults.set(streakDays, forKey: Keys.streakDays)
            checkAchievements()
        }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { save(achievementsUnlocked, forKey: Keys.achievementsUnlocked) }
    }

    @Published var userScores: [Int] {
        didSet { save(userScores, forKey: Keys.userScores) }
    }

    @Published var questionsAnswered: Int {
        didSet { defaults.set(questionsAnswered, forKey: Keys.questionsAnswered) }
    }

    @Published var topicProgress: [String: Double] {
        didSet { save(topicProgress, forKey: Keys.topicProgress) }
    }

    @Published var weeklyStats: [String: [String: TimeInterval]] {
        didSet { save(weeklyStats, forKey: Keys.weeklyStats) }
    }

    @Published var bookmarks: [String] {
        didSet { save(bookmarks, forKey: Keys.bookmarks) }
    }

    @Published var quizQuestions: [QuizQuestion] {
        didSet { save(quizQuestions, forKey: Keys.quizQuestions) }
    }

    @Published var quizAnswerStates: [String: QuizAnswerState] {
        didSet { save(quizAnswerStates, forKey: Keys.quizAnswerStates) }
    }

    @Published var reflectionEntries: [ReflectionEntry] {
        didSet { save(reflectionEntries, forKey: Keys.reflectionEntries) }
    }

    @Published var activityDates: [String] {
        didSet { save(activityDates, forKey: Keys.activityDates) }
    }

    @Published var sessionPlan: SessionPlan {
        didSet { save(sessionPlan, forKey: Keys.sessionPlan) }
    }

    @Published var newlyUnlockedAchievement: Achievement?
    private var achievementUnlockQueue: [Achievement] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        self.topics = Self.load([Topic].self, from: defaults, key: Keys.topics) ?? []
        if let idString = defaults.string(forKey: Keys.lastViewedTopicId) {
            self.lastViewedTopicId = UUID(uuidString: idString)
        } else {
            self.lastViewedTopicId = nil
        }
        self.cardsReviewed = defaults.integer(forKey: Keys.cardsReviewed)
        self.quizzesCompleted = defaults.integer(forKey: Keys.quizzesCompleted)
        self.topicsCompleted = defaults.integer(forKey: Keys.topicsCompleted)
        self.studyMinutes = defaults.integer(forKey: Keys.studyMinutes)
        self.totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        self.totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        self.streakDays = defaults.integer(forKey: Keys.streakDays)
        self.lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        self.achievementsUnlocked = Self.load([String: Date].self, from: defaults, key: Keys.achievementsUnlocked) ?? [:]
        self.userScores = Self.load([Int].self, from: defaults, key: Keys.userScores) ?? []
        self.questionsAnswered = defaults.integer(forKey: Keys.questionsAnswered)
        self.topicProgress = Self.load([String: Double].self, from: defaults, key: Keys.topicProgress) ?? [:]
        self.weeklyStats = Self.load([String: [String: TimeInterval]].self, from: defaults, key: Keys.weeklyStats) ?? [:]
        self.bookmarks = Self.load([String].self, from: defaults, key: Keys.bookmarks) ?? []
        self.quizQuestions = Self.load([QuizQuestion].self, from: defaults, key: Keys.quizQuestions) ?? []
        self.quizAnswerStates = Self.load([String: QuizAnswerState].self, from: defaults, key: Keys.quizAnswerStates) ?? [:]
        self.reflectionEntries = Self.load([ReflectionEntry].self, from: defaults, key: Keys.reflectionEntries) ?? []
        self.activityDates = Self.load([String].self, from: defaults, key: Keys.activityDates) ?? []
        self.sessionPlan = Self.load(SessionPlan.self, from: defaults, key: Keys.sessionPlan) ?? SessionPlan()

        applyLibraryUpgradeIfNeeded()

        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)
    }

    // MARK: - Library Upgrade

    private func applyLibraryUpgradeIfNeeded() {
        let version = defaults.integer(forKey: Keys.dataLibraryVersion)
        guard version < Self.dataLibraryVersion else { return }

        let onlyOldSamples = quizQuestions.isEmpty
            || quizQuestions.allSatisfy { $0.isSample || $0.question == "Sample Question" }

        if topics.isEmpty {
            topics = SeedData.topics
            for topic in topics {
                topicProgress[topic.id.uuidString] = 0
            }
        }

        if onlyOldSamples {
            quizQuestions = SeedData.quizQuestions
        }

        defaults.set(true, forKey: Keys.hasInitializedSamples)
        defaults.set(Self.dataLibraryVersion, forKey: Keys.dataLibraryVersion)
    }

    // MARK: - Topic Actions

    func addTopic(title: String, notes: String, category: TopicCategory = .general) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let topic = Topic(
            title: trimmed,
            notes: notes,
            category: category,
            structuredNotes: TopicStructuredNotes(keyThought: notes)
        )
        topics.append(topic)
        topicProgress[topic.id.uuidString] = 0
        registerActivity()
    }

    func updateTopic(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        var updated = topic
        updated.notes = topic.structuredNotes.keyThought
        topics[index] = updated
    }

    func markTopic(_ topic: Topic, status: TopicStatus) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        let wasKnown = topics[index].status == .known
        topics[index].status = status
        topics[index].lastReviewedDate = Date()
        lastViewedTopicId = topic.id

        if status == .known && !wasKnown {
            topicsCompleted += 1
            cardsReviewed += 1
            topicProgress[topic.id.uuidString] = 1.0
            addStudyTime(minutes: 5, forTopic: topic.title)
        } else if status == .learning {
            topicProgress[topic.id.uuidString] = min(topicProgress[topic.id.uuidString] ?? 0, 0.5)
            cardsReviewed += 1
        }

        registerActivity()
    }

    func recordTopicReview(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        topics[index].lastReviewedDate = Date()
        lastViewedTopicId = topic.id
        cardsReviewed += 1
        registerActivity()
    }

    func topicsDueForReview() -> [Topic] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return topics.filter { topic in
            guard topic.status == .learning else { return false }
            guard let lastReviewed = topic.lastReviewedDate else { return true }
            let lastDay = calendar.startOfDay(for: lastReviewed)
            let days = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            return days >= Self.reviewIntervalDays
        }
    }

    var dueTodayCount: Int {
        topicsDueForReview().count
    }

    func filteredTopics(search: String, category: TopicCategory?) -> [Topic] {
        topics.filter { topic in
            let matchesSearch = search.isEmpty
                || topic.title.localizedCaseInsensitiveContains(search)
                || topic.structuredNotes.keyThought.localizedCaseInsensitiveContains(search)
                || topic.category.displayName.localizedCaseInsensitiveContains(search)
            let matchesCategory = category == nil || topic.category == category
            return matchesSearch && matchesCategory
        }
    }

    func topicTitle(for id: UUID?) -> String? {
        guard let id else { return nil }
        return topics.first(where: { $0.id == id })?.title
    }

    func topicsGroupedByCategory() -> [(TopicCategory, [Topic])] {
        TopicCategory.allCases.compactMap { category in
            let items = topics.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    // MARK: - Quiz Actions

    func questions(for topicId: UUID?) -> [QuizQuestion] {
        guard let topicId else { return quizQuestions }
        return quizQuestions.filter { $0.topicId == topicId }
    }

    func filteredQuestions(search: String, topicId: UUID?) -> [QuizQuestion] {
        let base = questions(for: topicId)
        guard !search.isEmpty else { return base }
        return base.filter {
            $0.question.localizedCaseInsensitiveContains(search)
                || $0.options.contains { $0.localizedCaseInsensitiveContains(search) }
        }
    }

    func submitQuizAnswer(questionId: UUID, selectedIndex: Int) -> Bool {
        guard let question = quizQuestions.first(where: { $0.id == questionId }) else { return false }
        let isCorrect = selectedIndex == question.correctIndex
        quizAnswerStates[questionId.uuidString] = QuizAnswerState(
            selectedIndex: selectedIndex,
            isSubmitted: true,
            isCorrect: isCorrect
        )
        questionsAnswered += 1
        userScores.append(isCorrect ? 100 : 0)
        quizzesCompleted += 1
        totalSessionsCompleted += 1

        if sessionPlan.goalType == .quizCount {
            sessionPlan.quizzesCompletedInSession += 1
        }

        if let topicId = question.topicId, let title = topicTitle(for: topicId) {
            addStudyTime(minutes: 2, forTopic: title)
        } else {
            addStudyTime(minutes: 2, forTopic: "Quiz Practice")
        }

        registerActivity()
        return isCorrect
    }

    func addQuizQuestion(question: String, options: [String], correctIndex: Int, topicId: UUID?) {
        let q = QuizQuestion(topicId: topicId, question: question, options: options, correctIndex: correctIndex)
        quizQuestions.append(q)
        registerActivity()
    }

    func focusAreas() -> [FocusArea] {
        var stats: [String: (correct: Int, total: Int, title: String)] = [:]

        for question in quizQuestions {
            guard let state = quizAnswerStates[question.id.uuidString], state.isSubmitted else { continue }
            let key = question.topicId?.uuidString ?? "general"
            let title = topicTitle(for: question.topicId) ?? "General Practice"
            var entry = stats[key] ?? (0, 0, title)
            entry.total += 1
            if state.isCorrect { entry.correct += 1 }
            stats[key] = entry
        }

        return stats.values
            .filter { $0.total > 0 }
            .map { entry in
                let percent = Int((Double(entry.correct) / Double(entry.total)) * 100)
                return FocusArea(id: entry.title, title: entry.title, correctPercent: percent, totalAnswered: entry.total)
            }
            .filter { $0.correctPercent < 70 }
            .sorted { $0.correctPercent < $1.correctPercent }
    }

    // MARK: - Bookmark Actions

    func addBookmark(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !bookmarks.contains(trimmed) else { return }
        bookmarks.append(trimmed)
        registerActivity()
    }

    func removeBookmark(_ title: String) {
        bookmarks.removeAll { $0 == title }
        for index in topics.indices {
            topics[index].structuredNotes.linkedBookmarks.removeAll { $0 == title }
        }
    }

    func toggleBookmark(_ title: String) {
        if bookmarks.contains(title) {
            removeBookmark(title)
        } else {
            addBookmark(title)
        }
    }

    func filteredBookmarks(search: String) -> [String] {
        guard !search.isEmpty else { return bookmarks }
        return bookmarks.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    // MARK: - Reflection

    func addReflection(text: String, topicId: UUID?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let entry = ReflectionEntry(text: trimmed, topicId: topicId)
        reflectionEntries.insert(entry, at: 0)
        registerActivity()
    }

    // MARK: - Session Plan

    func completeSession(minutesStudied: Int) {
        if let topicId = sessionPlan.topicId, let title = topicTitle(for: topicId) {
            addStudyTime(minutes: minutesStudied, forTopic: title)
            if let index = topics.firstIndex(where: { $0.id == topicId }) {
                topics[index].lastReviewedDate = Date()
            }
        } else {
            addStudyTime(minutes: minutesStudied, forTopic: "Study Session")
        }
        sessionPlan.quizzesCompletedInSession = 0
        registerActivity()
    }

    func isSessionGoalMet(studySeconds: Int) -> Bool {
        switch sessionPlan.goalType {
        case .minutes:
            return studySeconds >= sessionPlan.goalValue * 60
        case .quizCount:
            return sessionPlan.quizzesCompletedInSession >= sessionPlan.goalValue
        }
    }

    // MARK: - Study Time

    func addStudyTime(minutes: Int, forTopic topicTitle: String) {
        studyMinutes += minutes
        totalMinutesUsed += minutes

        let dayKey = Self.dayKey(for: Date())
        recordActivityDay(dayKey)

        var topicStats = weeklyStats[topicTitle] ?? [:]
        topicStats[dayKey, default: 0] += TimeInterval(minutes * 60)
        weeklyStats[topicTitle] = topicStats

        if let topic = topics.first(where: { $0.title == topicTitle }) {
            let existing = topicProgress[topic.id.uuidString] ?? 0
            topicProgress[topic.id.uuidString] = min(existing + 0.1, 1.0)
        } else if topicTitle == "Quiz Practice" || topicTitle == "Study Session" {
            for topic in topics where topic.status == .learning {
                let existing = topicProgress[topic.id.uuidString] ?? 0
                topicProgress[topic.id.uuidString] = min(existing + 0.05, 1.0)
            }
        }
    }

    func recordActivityDay(_ dayKey: String? = nil) {
        let key = dayKey ?? Self.dayKey(for: Date())
        if !activityDates.contains(key) {
            activityDates.append(key)
        }
    }

    func activityLevel(for dayKey: String) -> Int {
        activityDates.contains(dayKey) ? 1 : 0
    }

    func activityDaysInLastMonths(_ months: Int = 3) -> [String] {
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .month, value: -months, to: Date()) else { return [] }
        return activityDates.filter { key in
            guard let date = Self.date(from: key) else { return false }
            return date >= start
        }.sorted()
    }

    // MARK: - Export

    func exportSummaryText() -> String {
        var lines: [String] = []
        lines.append("Learning Progress Summary")
        lines.append("Generated: \(Self.displayDate(Date()))")
        lines.append("")
        lines.append("--- Overview ---")
        lines.append("Study minutes: \(studyMinutes)")
        lines.append("Quizzes completed: \(quizzesCompleted)")
        lines.append("Topics mastered: \(topicsCompleted)")
        lines.append("Current streak: \(streakDays) days")
        lines.append("Items reviewed: \(cardsReviewed)")
        lines.append("")

        lines.append("--- Topics ---")
        for topic in topics {
            let progress = Int((topicProgress[topic.id.uuidString] ?? 0) * 100)
            lines.append("• \(topic.title) [\(topic.category.displayName)] — \(topic.status.displayName) — \(progress)%")
            if !topic.structuredNotes.keyThought.isEmpty {
                lines.append("  Key: \(topic.structuredNotes.keyThought)")
            }
        }
        lines.append("")

        lines.append("--- Quiz Results ---")
        let avg = userScores.isEmpty ? 0 : userScores.reduce(0, +) / userScores.count
        lines.append("Average score: \(avg)%")
        lines.append("Questions answered: \(questionsAnswered)")
        lines.append("")

        let weak = focusAreas()
        if !weak.isEmpty {
            lines.append("--- Focus Areas ---")
            for area in weak {
                lines.append("• \(area.title): \(area.correctPercent)% (\(area.totalAnswered) answered)")
            }
            lines.append("")
        }

        if !reflectionEntries.isEmpty {
            lines.append("--- Reflection Journal ---")
            for entry in reflectionEntries.prefix(20) {
                let topicName = topicTitle(for: entry.topicId) ?? "General"
                lines.append("[\(Self.displayDate(entry.date))] \(topicName)")
                lines.append(entry.text)
                lines.append("")
            }
        }

        lines.append("--- Bookmarks ---")
        for bookmark in bookmarks {
            lines.append("• \(bookmark)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Activity & Achievements

    func registerActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        recordActivityDay()

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else if dayDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
        checkAchievements()
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        registerActivity()
    }

    func checkAchievements() {
        for achievement in Achievement.all {
            let unlocked = achievement.isUnlocked(
                cardsReviewed: cardsReviewed,
                quizzesCompleted: quizzesCompleted,
                topicsCompleted: topicsCompleted,
                studyMinutes: studyMinutes,
                streakDays: streakDays
            )
            if unlocked && achievementsUnlocked[achievement.id] == nil {
                achievementsUnlocked[achievement.id] = Date()
                achievementUnlockQueue.append(achievement)
            }
        }
        if newlyUnlockedAchievement == nil, let next = achievementUnlockQueue.first {
            newlyUnlockedAchievement = next
        }
    }

    func consumeNewAchievement() -> Achievement? {
        let achievement = newlyUnlockedAchievement
        newlyUnlockedAchievement = nil
        return achievement
    }

    func advanceAchievementQueue() {
        if !achievementUnlockQueue.isEmpty {
            achievementUnlockQueue.removeFirst()
        }
        newlyUnlockedAchievement = achievementUnlockQueue.first
    }

    // MARK: - Reset

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = false
        topics = SeedData.topics
        lastViewedTopicId = nil
        cardsReviewed = 0
        quizzesCompleted = 0
        topicsCompleted = 0
        studyMinutes = 0
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        userScores = []
        questionsAnswered = 0
        topicProgress = [:]
        weeklyStats = [:]
        bookmarks = []
        quizQuestions = SeedData.quizQuestions
        quizAnswerStates = [:]
        reflectionEntries = []
        activityDates = []
        sessionPlan = SessionPlan()
        newlyUnlockedAchievement = nil
        achievementUnlockQueue = []
        for topic in topics {
            topicProgress[topic.id.uuidString] = 0
        }
        defaults.set(true, forKey: Keys.hasInitializedSamples)
        defaults.set(Self.dataLibraryVersion, forKey: Keys.dataLibraryVersion)
    }

    // MARK: - Persistence Helpers

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func date(from dayKey: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dayKey)
    }

    static func displayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var totalEntriesCreated: Int {
        topics.count + bookmarks.count + reflectionEntries.count
    }
}
