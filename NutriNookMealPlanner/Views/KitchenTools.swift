import SwiftUI

struct CookFocusView: View {
    @EnvironmentObject private var store: Store
    let recipe: Recipe
    @State private var stepIndex = 0
    @State private var showLeftovers = false
    @State private var pickedLeftovers: Set<String> = []
    @State private var extraLeftover = ""

    var body: some View {
        VStack(spacing: 18) {
            Text("Step \(stepIndex + 1) of \(recipe.steps.count)")
                .font(Theme.rounded(.caption, weight: .bold))
                .foregroundStyle(.secondary)

            stepTimer

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
                    } else {
                        finishCook()
                    }
                } label: {
                    controlLabel(stepIndex == recipe.steps.count - 1 ? "Finish" : "Next", symbol: "chevron.right")
                }
                .buttonStyle(.plain)
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
        .hidesAppDock()
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
        .sheet(isPresented: $showLeftovers) {
            LeftoverCaptureSheet(
                recipe: recipe,
                picked: $pickedLeftovers,
                extra: $extraLeftover
            )
            .environmentObject(store)
        }
        .onAppear {
            pickedLeftovers = Set(recipe.leftoverHints)
        }
    }

    @ViewBuilder
    private var stepTimer: some View {
        if let timer = store.selectedTimer(), timer.dishName.contains(recipe.title) {
            TimelineView(.periodic(from: .now, by: 0.25)) { timeline in
                let left = timer.displayedRemaining(at: timeline.date)
                VStack(spacing: 8) {
                    Text(timeString(left))
                        .font(Theme.rounded(.title, weight: .bold))
                    HStack(spacing: 12) {
                        Button(timer.isRunning ? "Pause" : "Resume") {
                            store.toggleTimer(timer.id, at: timeline.date)
                        }
                        .font(Theme.rounded(.caption, weight: .bold))
                        Button("Clear") {
                            store.deleteTimer(timer.id)
                        }
                        .font(Theme.rounded(.caption, weight: .bold))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppSurface"))
                }
            }
        }
    }

    private func finishCook() {
        store.markCookFinished(recipe: recipe)
        showLeftovers = true
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

    private func timeString(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct LeftoverCaptureSheet: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe
    @Binding var picked: Set<String>
    @Binding var extra: String

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                VStack(alignment: .leading, spacing: 16) {
                    Text("What is left for tomorrow?")
                        .font(Theme.rounded(.title2, weight: .bold))
                    Text("These names feed Tonight’s leftover matches.")
                        .font(Theme.rounded(.subheadline))
                        .foregroundStyle(.secondary)

                    let options = Array(Set(recipe.leftoverHints + recipe.ingredients.map(\.name))).sorted()
                    ForEach(options, id: \.self) { name in
                        Button {
                            if picked.contains(name) {
                                picked.remove(name)
                            } else {
                                picked.insert(name)
                            }
                        } label: {
                            HStack {
                                Image(systemName: picked.contains(name) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(Color("AppPrimary"))
                                Text(name)
                                    .font(Theme.rounded(.body, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("AppSurface"))
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    TextField("Something else (cooked rice, broth…)", text: $extra)
                        .font(Theme.rounded(.body))
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("AppSurface"))
                        }

                    Spacer()

                    PlateActionButton(title: "Save leftovers", symbol: "archivebox.fill") {
                        var names = Array(picked)
                        let extraTrim = extra.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !extraTrim.isEmpty { names.append(extraTrim) }
                        store.saveLeftovers(names: names, from: recipe)
                        dismiss()
                    }
                    Button("Skip") { dismiss() }
                        .font(Theme.rounded(.subheadline, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
            .dismissKeyboardOnTap()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Leftovers")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
            }
        }
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
                Text("Marked staples count toward tonight’s match percent.")
                    .font(Theme.rounded(.subheadline))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    TextField("Miso, 醤油, rice…", text: $name)
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

                Text("Catalog staples")
                    .font(Theme.rounded(.headline, weight: .bold))
                FlexibleStapleRow(names: RecipeCatalog.pantryStaples)

                if store.pantryKeys.isEmpty {
                    Text("Nothing marked yet.")
                        .font(Theme.rounded(.subheadline))
                        .foregroundStyle(.secondary)
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

struct FlexibleStapleRow: View {
    @EnvironmentObject private var store: Store
    let names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(names, id: \.self) { name in
                Button {
                    store.togglePantry(name)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: store.isInPantry(name) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AppAccent"))
                        Text(displayName(name))
                            .font(Theme.rounded(.subheadline, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        Capsule().fill(Color("AppSurface"))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func displayName(_ name: String) -> String {
        if let english = RecipeCatalog.englishName(for: name), english.lowercased() != name.lowercased() {
            return "\(name) — \(english)"
        }
        return name
    }
}
