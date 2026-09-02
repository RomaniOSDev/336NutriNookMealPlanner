import SwiftUI

struct CookFocusView: View {
    @EnvironmentObject private var store: Store
    let recipe: Recipe
    @State private var stepIndex = 0

    var body: some View {
        VStack(spacing: 18) {
            Text("Step \(stepIndex + 1) of \(recipe.steps.count)")
                .font(Theme.rounded(.caption, weight: .bold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(recipe.steps[stepIndex])
                .font(Theme.rounded(.title2, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            if !store.note(for: recipe.id).isEmpty {
                Text(store.note(for: recipe.id))
                    .font(Theme.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    stepIndex = max(0, stepIndex - 1)
                } label: {
                    controlLabel("Back", symbol: "chevron.left")
                }
                .buttonStyle(.plain)
                .opacity(stepIndex == 0 ? 0.35 : 1)
                .disabled(stepIndex == 0)

                Button {
                    if stepIndex < recipe.steps.count - 1 {
                        stepIndex += 1
                    }
                } label: {
                    controlLabel(stepIndex == recipe.steps.count - 1 ? "Done" : "Next", symbol: "chevron.right")
                }
                .buttonStyle(.plain)
                .disabled(stepIndex == recipe.steps.count - 1)
                .opacity(stepIndex == recipe.steps.count - 1 ? 0.35 : 1)
            }

            PlateActionButton(
                title: "Timer this step · \(store.stepMinutes(for: recipe)) min",
                symbol: "timer"
            ) {
                store.startCookTimer(
                    dishName: "\(recipe.title) · step \(stepIndex + 1)",
                    minutes: store.stepMinutes(for: recipe)
                )
            }
        }
        .padding(22)
        .kitchenCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppSurface"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(recipe.title)
                    .font(Theme.rounded(.headline, weight: .bold))
                    .lineLimit(1)
            }
        }
    }

    private func controlLabel(_ title: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(Theme.rounded(.headline, weight: .semibold))
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            Capsule().fill(Theme.warmFill)
        }
        .cheapPlateShadow()
        .frame(minHeight: 44)
    }
}

struct PantryBoardView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Already on the shelf")
                    .font(Theme.rounded(.headline, weight: .bold))
                Text("Marked staples are skipped when a recipe copies to Market.")
                    .font(Theme.rounded(.subheadline))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    TextField("Soy sauce, garlic, ghee…", text: $name)
                        .font(Theme.rounded(.body))
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("AppSurface"))
                        }
                    Button {
                        store.addPantry(name)
                        name = ""
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background { Circle().fill(Theme.plateFill) }
                            .cheapPlateShadow()
                    }
                    .buttonStyle(.plain)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if store.pantryKeys.isEmpty {
                    KitchenEmptyState(symbol: "cabinet.fill", message: "Tap an ingredient on a recipe, or type a staple you already keep.")
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(store.pantryKeys, id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .font(Theme.rounded(.body, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Button {
                                        store.removePantryKey(key)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color("AppPrimary"))
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 44, height: 44)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color("AppSurface"))
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .contentShape(Rectangle())
            .dismissKeyboardOnTap()
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Pantry")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
        }
    }
}

struct FromStockView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let onOpen: (Recipe) -> Void

    private var matches: [(Recipe, Int)] {
        store.recipesFromStock()
    }

    var body: some View {
        NavigationStack {
            Group {
                if matches.isEmpty {
                    KitchenEmptyState(
                        symbol: "leaf.fill",
                        message: "Stock the pantry or check off market items, then come back for a match."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(matches, id: \.0.id) { pair in
                                Button {
                                    onOpen(pair.0)
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(pair.0.title)
                                                .font(Theme.rounded(.body, weight: .semibold))
                                                .foregroundStyle(.primary)
                                            Text("\(pair.1)/\(pair.0.ingredients.count) on hand · \(pair.0.minutes) min")
                                                .font(Theme.rounded(.caption, weight: .medium))
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color("AppSurface"))
                                    }
                                    .cheapPlateShadow()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(18)
                    }
                }
            }
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("From stock")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
        }
    }
}

struct TonightPickView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let filters: DinnerFilters
    let onOpen: (Recipe) -> Void
    @State private var recipe: Recipe?

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                if let recipe {
                    Text(recipe.title)
                        .font(Theme.rounded(.title, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("\(recipe.cuisine.rawValue) · \(recipe.minutes) min")
                        .font(Theme.rounded(.headline, weight: .medium))
                        .foregroundStyle(.secondary)
                    if let foreign = recipe.foreignName {
                        Text(foreign)
                            .font(Theme.rounded(.title3))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    PlateActionButton(title: "Open this dish", symbol: "book.fill") {
                        onOpen(recipe)
                        dismiss()
                    }
                    PlateActionButton(title: "Shuffle again", symbol: "dice.fill") {
                        self.recipe = store.randomDinner(filters: filters, preferSaved: true)
                    }
                } else {
                    KitchenEmptyState(symbol: "dice.fill", message: "No dish matches these filters. Loosen Quick / Veg / GF and try again.")
                }
            }
            .padding(22)
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tonight")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
            .onAppear {
                if recipe == nil {
                    recipe = store.randomDinner(filters: filters, preferSaved: true)
                }
            }
        }
    }
}
