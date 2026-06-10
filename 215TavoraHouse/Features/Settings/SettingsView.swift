import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showExportSheet = false
    @State private var exportItems: [Any] = []

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        settingsList

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showExportSheet) {
                ShareSheet(items: exportItems)
            }
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackService.lightTap() }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackService.warning()
                }
            } message: {
                Text("This will permanently delete all your topics, progress, and achievements. This action cannot be undone.")
            }
        }
    }

    private var statsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(title: "Your Stats", icon: "person.crop.circle.fill")
                HStack(spacing: 10) {
                    MetricStatCell(value: "\(store.totalEntriesCreated)", label: "Entries", icon: "doc.fill")
                    MetricStatCell(value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "clock.fill")
                    MetricStatCell(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }

    private var settingsList: some View {
        AppCard(padding: 0) {
            VStack(spacing: 0) {
                SettingsMenuCell(title: "Export Summary", icon: "square.and.arrow.up") {
                    FeedbackService.lightTap()
                    exportProgress()
                }
                divider
                SettingsMenuCell(title: "Privacy Policy", icon: "hand.raised.fill") {
                    FeedbackService.lightTap()
                    openPrivacyPolicy()
                }
                divider
                SettingsMenuCell(title: "Rate App", icon: "star.fill") {
                    FeedbackService.lightTap()
                    rateApp()
                }
                divider
                SettingsMenuCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true) {
                    FeedbackService.lightTap()
                    showResetAlert = true
                }
            }
        }
    }

    private var divider: some View {
        Divider()
            .background(Color("AppTextSecondary").opacity(0.2))
            .padding(.leading, 62)
    }

    private func exportProgress() {
        let text = store.exportSummaryText()
        var items: [Any] = [text]
        if let txtURL = ExportService.createTextFile(from: text) { items.append(txtURL) }
        if let pdfURL = ExportService.createPDF(from: text) { items.append(pdfURL) }
        exportItems = items
        showExportSheet = true
        FeedbackService.success()
    }

    private func openPrivacyPolicy() {
        if let url = AppLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
