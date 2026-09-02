import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var showStats = false

    private let columns = [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Close") { dismiss() }
                    .font(Theme.rounded(.body, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("Kitchen Desk")
                    .font(Theme.rounded(.headline, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Color.clear.frame(width: 52, height: 1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 28) {
                    plateKey(symbol: "chart.bar.xaxis", title: "Stats") {
                        showStats = true
                    }
                    plateKey(symbol: "star.fill", title: "Rate Us") {
                        AppLinks.rateApp()
                    }
                    plateKey(symbol: "hand.raised.fill", title: "Privacy") {
                        AppLinks.open(AppLinks.privacy)
                    }
                    plateKey(symbol: "doc.plaintext.fill", title: "Terms") {
                        AppLinks.open(AppLinks.terms)
                    }
                    plateKey(symbol: "trash.fill", title: "Reset") {
                        confirmReset = true
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 36)
            }
        }
        .kitchenCanvas()
        .sheet(isPresented: $showStats) {
            StatsView()
                .environmentObject(store)
        }
        .alert("Reset all kitchen data?", isPresented: $confirmReset) {
            Button("Reset", role: .destructive) {
                store.resetAllData()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Favorites, market items, pantry, week plan, notes, timers, stats, and unit preference will be cleared from this device.")
        }
    }

    private func plateKey(symbol: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.22))
                        .offset(y: 8)
                    Circle()
                        .fill(Theme.plateFill)
                    Circle()
                        .stroke(Color("AppAccent"), lineWidth: 3)
                    Image(systemName: symbol)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 96, height: 96)
                .cheapPlateShadow()

                Text(title)
                    .font(Theme.rounded(.subheadline, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .accessibilityLabel(title)
    }
}
