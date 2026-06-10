import SwiftUI

struct ActivityCalendarView: View {
    let activeDayKeys: Set<String>
    var weeks: Int = 12

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels: [(id: Int, symbol: String)] = [
        (0, "Su"), (1, "Mo"), (2, "Tu"), (3, "We"), (4, "Th"), (5, "Fr"), (6, "Sa")
    ]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "Activity", icon: "calendar", tint: Color("AppTextPrimary"))

                HStack(spacing: 4) {
                    ForEach(weekdayLabels, id: \.id) { item in
                        Text(item.symbol)
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(calendarDays, id: \.self) { dayKey in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(cellFill(for: dayKey))
                            .frame(height: 16)
                    }
                }

                HStack(spacing: 16) {
                    legendItem(active: false, label: "Inactive")
                    legendItem(active: true, label: "Active")
                }
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private func legendItem(active: Bool, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    active
                        ? LinearGradient(
                            colors: [Color("AppAccent"), Color("AppPrimary")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color("AppBackground").opacity(0.6),
                                Color("AppBackground").opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(width: 12, height: 12)
            Text(label)
        }
    }

    private var calendarDays: [String] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: today) else { return [] }

        var days: [String] = []
        var current = start
        while current <= today {
            days.append(AppDataStore.dayKey(for: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return days
    }

    private func cellFill(for dayKey: String) -> LinearGradient {
        if activeDayKeys.contains(dayKey) {
            return LinearGradient(
                colors: [Color("AppAccent"), Color("AppPrimary")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.55),
                Color("AppBackground").opacity(0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
