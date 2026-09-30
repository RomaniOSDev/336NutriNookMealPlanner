import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @State private var confirmReset = false
    @State private var showStats = false
    @State private var showEditor = false
    @State private var editing: Recipe?

    private let columns = [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)]

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Desk")
                                .font(Theme.rounded(.title, weight: .bold))
                            Text("Your dishes, units, and house data. This app stays on the device.")
                                .font(Theme.rounded(.subheadline, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Your dishes")
                                    .font(Theme.rounded(.headline, weight: .bold))
                                Spacer()
                                Button("Add") { showEditor = true }
                                    .font(Theme.rounded(.subheadline, weight: .bold))
                            }
                            if store.customRecipes.isEmpty {
                                Text("Add a home recipe with leftover hints. That is what makes leftover matching yours.")
                                    .font(Theme.rounded(.subheadline))
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(store.customRecipes) { recipe in
                                    HStack {
                                        NavigationLink {
                                            RecipeDetailView(recipe: recipe)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(recipe.title)
                                                    .font(Theme.rounded(.body, weight: .semibold))
                                                    .foregroundStyle(.primary)
                                                Text("\(recipe.minutes) min")
                                                    .font(Theme.rounded(.caption))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Button("Edit") { editing = recipe }
                                            .font(Theme.rounded(.caption, weight: .bold))
                                        Button("Delete", role: .destructive) {
                                            store.deleteCustomRecipe(recipe.id)
                                        }
                                        .font(Theme.rounded(.caption, weight: .bold))
                                    }
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color("AppSurface"))
                                    }
                                }
                            }
                        }

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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, Theme.dockClearance)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(Color.clear)
        .sheet(isPresented: $showStats) {
            StatsView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showEditor) {
            RecipeEditorView()
                .environmentObject(store)
        }
        .sheet(item: $editing) { recipe in
            RecipeEditorView(existing: recipe)
                .environmentObject(store)
        }
        .alert("Reset all kitchen data?", isPresented: $confirmReset) {
            Button("Reset", role: .destructive) {
                store.resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Favorites, market items, pantry, week plan, notes, leftovers, your dishes, timers, stats, and unit preference will be cleared from this device.")
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
