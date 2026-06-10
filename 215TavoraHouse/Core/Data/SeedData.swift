import Foundation

enum SeedData {
    static let algebraId = UUID(uuidString: "A1000001-0001-0001-0001-000000000001")!
    static let fractionsId = UUID(uuidString: "A1000002-0002-0002-0002-000000000002")!
    static let vocabularyId = UUID(uuidString: "A1000003-0003-0003-0003-000000000003")!
    static let grammarId = UUID(uuidString: "A1000004-0004-0004-0004-000000000004")!
    static let planningId = UUID(uuidString: "A1000005-0005-0005-0005-000000000005")!
    static let communicationId = UUID(uuidString: "A1000006-0006-0006-0006-000000000006")!

    static let topics: [Topic] = [
        Topic(
            id: algebraId,
            title: "Algebra Basics",
            notes: "Variables represent unknown values in equations.",
            category: .math,
            structuredNotes: TopicStructuredNotes(
                keyThought: "Variables represent unknown values in equations.",
                example: "If x + 3 = 7, then x = 4.",
                checklist: [
                    ChecklistItem(text: "Review variables"),
                    ChecklistItem(text: "Practice one-step equations"),
                    ChecklistItem(text: "Solve for x in word problems")
                ]
            )
        ),
        Topic(
            id: fractionsId,
            title: "Fractions",
            notes: "A fraction shows parts of a whole.",
            category: .math,
            structuredNotes: TopicStructuredNotes(
                keyThought: "A fraction shows parts of a whole.",
                example: "1/2 means one part out of two equal parts.",
                checklist: [
                    ChecklistItem(text: "Understand numerator and denominator"),
                    ChecklistItem(text: "Add fractions with common denominators")
                ]
            )
        ),
        Topic(
            id: vocabularyId,
            title: "Vocabulary",
            notes: "Context clues help infer word meaning.",
            category: .language,
            structuredNotes: TopicStructuredNotes(
                keyThought: "Context clues help infer word meaning.",
                example: "The arid desert had no rain — arid means dry.",
                checklist: [
                    ChecklistItem(text: "Learn 5 new words"),
                    ChecklistItem(text: "Use each word in a sentence")
                ]
            )
        ),
        Topic(
            id: grammarId,
            title: "Grammar Rules",
            notes: "Subjects and verbs must agree in number.",
            category: .language,
            structuredNotes: TopicStructuredNotes(
                keyThought: "Subjects and verbs must agree in number.",
                example: "She runs every day. They run every day.",
                checklist: [
                    ChecklistItem(text: "Review subject-verb agreement"),
                    ChecklistItem(text: "Identify sentence fragments")
                ]
            )
        ),
        Topic(
            id: planningId,
            title: "Project Planning",
            notes: "Break large goals into actionable tasks.",
            category: .work,
            structuredNotes: TopicStructuredNotes(
                keyThought: "Break large goals into actionable tasks.",
                example: "A report due Friday → outline Mon, draft Wed, edit Thu.",
                checklist: [
                    ChecklistItem(text: "Define project scope"),
                    ChecklistItem(text: "Set milestones"),
                    ChecklistItem(text: "Review progress weekly")
                ]
            )
        ),
        Topic(
            id: communicationId,
            title: "Communication Skills",
            notes: "Active listening improves understanding.",
            category: .work,
            structuredNotes: TopicStructuredNotes(
                keyThought: "Active listening improves understanding.",
                example: "Paraphrase what you heard before responding.",
                checklist: [
                    ChecklistItem(text: "Practice paraphrasing"),
                    ChecklistItem(text: "Ask clarifying questions")
                ]
            )
        )
    ]

    static let quizQuestions: [QuizQuestion] = [
        // Algebra
        QuizQuestion(
            id: UUID(uuidString: "B1000001-0001-0001-0001-000000000001")!,
            topicId: algebraId,
            question: "What is the value of x if x + 5 = 12?",
            options: ["5", "7", "17", "2"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000002-0002-0002-0002-000000000002")!,
            topicId: algebraId,
            question: "Which expression represents 'twice a number'?",
            options: ["n + 2", "2n", "n / 2", "n - 2"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000003-0003-0003-0003-000000000003")!,
            topicId: algebraId,
            question: "Solve: 3x = 15",
            options: ["3", "5", "12", "45"],
            correctIndex: 1
        ),
        // Fractions
        QuizQuestion(
            id: UUID(uuidString: "B1000004-0004-0004-0004-000000000004")!,
            topicId: fractionsId,
            question: "What is 1/2 + 1/2?",
            options: ["1/4", "2/4", "1", "2"],
            correctIndex: 2
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000005-0005-0005-0005-000000000005")!,
            topicId: fractionsId,
            question: "Which fraction is equivalent to 2/4?",
            options: ["1/2", "1/4", "3/4", "4/2"],
            correctIndex: 0
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000006-0006-0006-0006-000000000006")!,
            topicId: fractionsId,
            question: "In 3/5, what is the denominator?",
            options: ["3", "5", "8", "2"],
            correctIndex: 1
        ),
        // Vocabulary
        QuizQuestion(
            id: UUID(uuidString: "B1000007-0007-0007-0007-000000000007")!,
            topicId: vocabularyId,
            question: "What does 'benevolent' most likely mean?",
            options: ["Kind and generous", "Angry", "Confused", "Lazy"],
            correctIndex: 0
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000008-0008-0008-0008-000000000008")!,
            topicId: vocabularyId,
            question: "A synonym for 'rapid' is:",
            options: ["Slow", "Quick", "Heavy", "Quiet"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000009-0009-0009-0009-000000000009")!,
            topicId: vocabularyId,
            question: "Context clues help you understand:",
            options: ["Math formulas", "Unknown words", "Map directions", "Music notes"],
            correctIndex: 1
        ),
        // Grammar
        QuizQuestion(
            id: UUID(uuidString: "B1000010-0010-0010-0010-000000000010")!,
            topicId: grammarId,
            question: "Choose the correct sentence:",
            options: ["She don't like it", "She doesn't like it", "She not like it", "She no like it"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000011-0011-0011-0011-000000000011")!,
            topicId: grammarId,
            question: "Which is a complete sentence?",
            options: ["Running fast", "Because it rained", "The dog barked", "Under the table"],
            correctIndex: 2
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000012-0012-0012-0012-000000000012")!,
            topicId: grammarId,
            question: "They ___ to school every day.",
            options: ["goes", "go", "going", "gone"],
            correctIndex: 1
        ),
        // Project Planning
        QuizQuestion(
            id: UUID(uuidString: "B1000013-0013-0013-0013-000000000013")!,
            topicId: planningId,
            question: "What is the first step in project planning?",
            options: ["Define the goal", "Celebrate", "Ignore deadlines", "Skip research"],
            correctIndex: 0
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000014-0014-0014-0014-000000000014")!,
            topicId: planningId,
            question: "A milestone is:",
            options: ["A random task", "A key progress checkpoint", "A break", "A failure"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000015-0015-0015-0015-000000000015")!,
            topicId: planningId,
            question: "Breaking tasks into smaller steps helps:",
            options: ["Increase confusion", "Make work manageable", "Delay progress", "Avoid planning"],
            correctIndex: 1
        ),
        // Communication
        QuizQuestion(
            id: UUID(uuidString: "B1000016-0016-0016-0016-000000000016")!,
            topicId: communicationId,
            question: "Active listening includes:",
            options: ["Interrupting often", "Paraphrasing what you heard", "Ignoring the speaker", "Changing the topic"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000017-0017-0017-0017-000000000017")!,
            topicId: communicationId,
            question: "Clarifying questions help you:",
            options: ["End conversations", "Understand better", "Avoid listening", "Guess randomly"],
            correctIndex: 1
        ),
        QuizQuestion(
            id: UUID(uuidString: "B1000018-0018-0018-0018-000000000018")!,
            topicId: communicationId,
            question: "Good feedback should be:",
            options: ["Vague and personal", "Specific and constructive", "Only negative", "Avoided entirely"],
            correctIndex: 1
        )
    ]
}
