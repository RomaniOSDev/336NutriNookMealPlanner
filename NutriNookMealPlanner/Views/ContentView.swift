import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSettings = false
    @State private var cuisineFilter: String = "All"
    @State private var searchText = ""
    @State private var dinnerFilters = DinnerFilters()
    @State private var pendingRecipeID: String?
    @State private var showTonight = false
    @State private var showFromStock = false

    var body: some View {
        VStack(spacing: 0) {
            cookbookIndex
            if store.station == .recipes {
                cuisineStrip
            }
            stationWorkspace
        }
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .kitchenCanvas()
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showTonight) {
            TonightPickView(filters: dinnerFilters) { recipe in
                store.station = .recipes
                pendingRecipeID = recipe.id
            }
            .environmentObject(store)
        }
        .sheet(isPresented: $showFromStock) {
            FromStockView { recipe in
                store.station = .recipes
                pendingRecipeID = recipe.id
            }
            .environmentObject(store)
        }
        .environmentObject(store)
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                store.pauseAllRunningTimers()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            cuisineFilter = "All"
            searchText = ""
            dinnerFilters = DinnerFilters()
            showSettings = false
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

    private var cookbookIndex: some View {
        HStack(alignment: .bottom, spacing: -8) {
            CookbookIndexTab(title: "Recipes", isSelected: store.station == .recipes, tilt: -3) {
                withAnimation(.easeInOut(duration: 0.18)) { store.station = .recipes }
            }
            CookbookIndexTab(title: "Plan", isSelected: store.station == .plan, tilt: 1.5) {
                withAnimation(.easeInOut(duration: 0.18)) { store.station = .plan }
            }
            CookbookIndexTab(title: "Market", isSelected: store.station == .market, tilt: 2) {
                withAnimation(.easeInOut(duration: 0.18)) { store.station = .market }
            }
            CookbookIndexTab(title: "Timers", isSelected: store.station == .timers, tilt: -1.5) {
                withAnimation(.easeInOut(duration: 0.18)) { store.station = .timers }
            }
            Spacer(minLength: 4)
            Button {
                showSettings = true
            } label: {
                Text("Desk")
                    .font(Theme.rounded(.caption2, weight: .bold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background {
                        Circle()
                            .fill(Theme.warmFill)
                    }
                    .overlay {
                        Circle()
                            .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
                    }
                    .cheapPlateShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private var cuisineStrip: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    KitchenChip(title: "All", isSelected: cuisineFilter == "All") {
                        cuisineFilter = "All"
                    }
                    KitchenChip(title: "Saved", isSelected: cuisineFilter == "Saved") {
                        cuisineFilter = "Saved"
                    }
                    ForEach(orderedCuisines) { cuisine in
                        KitchenChip(title: cuisine.rawValue, isSelected: cuisineFilter == cuisine.rawValue) {
                            cuisineFilter = cuisine.rawValue
                            store.recordCuisineFilter(cuisine.rawValue)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    KitchenChip(title: "Quick", isSelected: dinnerFilters.quick) {
                        dinnerFilters.quick.toggle()
                    }
                    KitchenChip(title: "Veg", isSelected: dinnerFilters.vegetarian) {
                        dinnerFilters.vegetarian.toggle()
                    }
                    KitchenChip(title: "GF", isSelected: dinnerFilters.glutenFree) {
                        dinnerFilters.glutenFree.toggle()
                    }
                    KitchenChip(title: "Tonight", isSelected: false) {
                        showTonight = true
                    }
                    KitchenChip(title: "From stock", isSelected: false) {
                        showFromStock = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Find a dish", text: $searchText)
                    .font(Theme.rounded(.body))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(Color("AppSurface"))
            }
            .overlay {
                Capsule()
                    .stroke(Color("AppPrimary").opacity(0.28), lineWidth: 1)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }

    private var orderedCuisines: [Cuisine] {
        var remaining = Cuisine.allCases
        var ordered: [Cuisine] = []
        for name in store.recentCuisineFilters {
            if let match = remaining.first(where: { $0.rawValue == name }) {
                ordered.append(match)
                remaining.removeAll { $0 == match }
            }
        }
        return ordered + remaining
    }

    private var stationWorkspace: some View {
        Group {
            switch store.station {
            case .recipes:
                RecipeStudio(
                    cuisineFilter: cuisineFilter,
                    searchText: searchText,
                    dinnerFilters: dinnerFilters,
                    pendingRecipeID: $pendingRecipeID
                )
            case .plan:
                PlanStudio()
            case .market:
                GroceryStudio()
            case .timers:
                TimerStudio()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
