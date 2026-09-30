import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase
    @State private var pendingRecipeID: String?

    var body: some View {
        VStack(spacing: 0) {
            stationWorkspace
            if store.dockHiddenCount == 0 {
                tonightDock
            }
        }
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .kitchenCanvas()
        .environmentObject(store)
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                store.pauseAllRunningTimers()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            pendingRecipeID = nil
        }
        .overlay(alignment: .top) {
            TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                Color.clear
                    .frame(width: 0, height: 0)
                    .onChange(of: timeline.date) { date in
                        store.completeExpired(at: date)
                    }
                    .onAppear {
                        store.completeExpired(at: timeline.date)
                    }
            }
            .allowsHitTesting(false)
        }
    }

    private var stationWorkspace: some View {
        Group {
            switch store.station {
            case .today:
                TonightHomeView(pendingRecipeID: $pendingRecipeID)
            case .decoder:
                DecoderStudio()
            case .week:
                PlanStudio()
            case .desk:
                SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tonightDock: some View {
        HStack(spacing: 0) {
            ForEach(KitchenStation.allCases) { station in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        store.station = station
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: station.symbol)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text(station.title)
                            .font(Theme.rounded(.caption2, weight: .bold))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(store.station == station ? Theme.plateFill : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(station.title)
                .accessibilityAddTraits(store.station == station ? .isSelected : [])
            }
        }
        .padding(6)
        .background {
            Capsule()
                .fill(Color("AppSurface").opacity(0.96))
        }
        .overlay {
            Capsule()
                .stroke(Color("AppPrimary").opacity(0.28), lineWidth: 1)
        }
        .cheapPlateShadow()
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .padding(.top, 4)
    }
}

struct TonightHomeView: View {
    @EnvironmentObject private var store: Store
    @Binding var pendingRecipeID: String?
    @State private var showPantry = false
    @State private var openedRecipe: Recipe?
    @State private var showOpened = false

    private var leftoverMatches: [PantryMatch] {
        store.leftoverMatches()
    }

    private var pantryMatches: [PantryMatch] {
        Array(store.pantryMatches().prefix(6))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        todayPlan
                        leftoversBlock
                        fromPantryBlock
                        catalogPeek
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, Theme.dockClearance)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showOpened) {
                if let openedRecipe {
                    RecipeDetailView(recipe: openedRecipe)
                }
            }
            .onChange(of: pendingRecipeID) { _ in
                openPending()
            }
            .onAppear { openPending() }
            .sheet(isPresented: $showPantry) {
                PantryBoardView()
                    .environmentObject(store)
            }
        }
        .background(Color.clear)
        .background(KitchenClearHost())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tonight")
                .font(Theme.rounded(.largeTitle, weight: .bold))
                .foregroundStyle(.primary)
            Text("Japanese–Korean weeknights from what you already have. Mark the pantry, then cook.")
                .font(Theme.rounded(.subheadline, weight: .medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                KitchenChip(title: "Pantry", isSelected: false) {
                    showPantry = true
                }
                KitchenChip(title: "Decoder", isSelected: false) {
                    store.station = .decoder
                }
            }
        }
    }

    @ViewBuilder
    private var todayPlan: some View {
        let today = store.plannedRecipe(on: .today)
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pinned for today")
                    .font(Theme.rounded(.headline, weight: .bold))
                if let today {
                    Button {
                        open(today)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(today.title)
                                    .font(Theme.rounded(.body, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text("\(today.kind.title) · \(today.minutes) min")
                                    .font(Theme.rounded(.caption, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Nothing pinned. Match a dish from the pantry list, or set the week.")
                        .font(Theme.rounded(.subheadline))
                        .foregroundStyle(.secondary)
                    Button("Open the week") { store.station = .week }
                        .font(Theme.rounded(.subheadline, weight: .bold))
                }
            }
        }
    }

    @ViewBuilder
    private var leftoversBlock: some View {
        let active = store.activeLeftovers()
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tomorrow from leftovers")
                    .font(Theme.rounded(.headline, weight: .bold))
                if active.isEmpty {
                    Text("After you cook, log what is left in the fridge. Tomorrow’s dish will show up here.")
                        .font(Theme.rounded(.subheadline))
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(active) { item in
                                HStack(spacing: 6) {
                                    Text(item.name)
                                        .font(Theme.rounded(.caption, weight: .bold))
                                    Button {
                                        store.removeLeftover(item.id)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background { Capsule().fill(Theme.warmFill) }
                            }
                        }
                    }
                    if leftoverMatches.isEmpty {
                        Text("No catalog dish uses these leftovers yet. Add your own recipe on Desk.")
                            .font(Theme.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(leftoverMatches.prefix(3)) { match in
                            pantryRow(match, leftover: true)
                        }
                    }
                }
            }
        }
    }

    private var fromPantryBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cook from what you have")
                .font(Theme.rounded(.headline, weight: .bold))
            if pantryMatches.isEmpty {
                SurfaceCard {
                    Text("Mark staples in Decoder or Pantry. Matches appear here with a percent and a short buy list.")
                        .font(Theme.rounded(.subheadline))
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(pantryMatches) { match in
                    pantryRow(match, leftover: false)
                }
            }
        }
    }

    private var catalogPeek: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weeknight catalog")
                .font(Theme.rounded(.headline, weight: .bold))
            ForEach(store.allRecipes.prefix(4)) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    DishLineCard(recipe: recipe, isFavorite: store.isFavorite(recipe.id))
                }
                .buttonStyle(.plain)
            }
            NavigationLink {
                RecipeIndexView()
            } label: {
                Text("See every dish")
                    .font(Theme.rounded(.subheadline, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background { Capsule().fill(Color("AppSurface")) }
            }
            .buttonStyle(.plain)
        }
    }

    private func pantryRow(_ match: PantryMatch, leftover: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                open(match.recipe)
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    PercentRing(percent: match.percent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.recipe.title)
                            .font(Theme.rounded(.body, weight: .semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Text("\(match.have.count)/\(match.total) on hand · \(match.recipe.minutes) min")
                            .font(Theme.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                        if leftover, let foreign = match.recipe.foreignName {
                            Text(foreign)
                                .font(Theme.rounded(.caption2, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if !match.missing.isEmpty {
                Text("Still buy: " + match.missing.map(\.name).joined(separator: ", "))
                    .font(Theme.rounded(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
                Button("Add \(match.missing.count) to the list") {
                    store.addMissingList(match.missing, recipeID: match.recipe.id)
                }
                .font(Theme.rounded(.caption, weight: .bold))
            } else {
                Text("You can cook this without a shop run.")
                    .font(Theme.rounded(.caption, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppSurface"))
        }
        .cheapPlateShadow()
    }

    private func open(_ recipe: Recipe) {
        openedRecipe = recipe
        showOpened = true
    }

    private func openPending() {
        guard let id = pendingRecipeID, let recipe = store.recipe(id: id) else { return }
        pendingRecipeID = nil
        open(recipe)
    }
}
