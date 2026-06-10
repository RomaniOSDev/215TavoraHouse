import SwiftUI

struct MetricStatCell: View {
    let value: String
    let label: String
    var icon: String?

    var body: some View {
        VStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color("AppPrimary"))
            }
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appInsetSurface(radius: 10)
    }
}

struct SummaryMetricRow: View {
    let label: String
    let value: String
    var icon: String?

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 24)
            }
            Text(label)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(.vertical, 4)
    }
}
