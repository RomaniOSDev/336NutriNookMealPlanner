import SwiftUI

struct RecipeStudio: View {
    @EnvironmentObject private var store: Store
    var cuisineFilter: String
    var searchText: String
    var dinnerFilters: DinnerFilters
    @Binding var pendingRecipeID: String?
    @State private var openedRecipe: Recipe?
    @State private var showOpened = false

    private var filteredRecipes: [Recipe] {
        RecipeCatalog.recipes.filter { recipe in
            let matchesCuisine: Bool
            if cuisineFilter == "All" {
                matchesCuisine = true
            } else if cuisineFilter == "Saved" {
                matchesCuisine = store.isFavorite(recipe.id)
            } else {
                matchesCuisine = recipe.cuisine.rawValue == cuisineFilter
            }

            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty { return matchesCuisine }
            let haystack = [
                recipe.title,
                recipe.cuisine.rawValue,
                recipe.foreignName ?? "",
                recipe.ingredients.map(\.name).joined(separator: " ")
            ].joined(separator: " ").lowercased()
            return matchesCuisine && haystack.contains(query.lowercased())
        }
        .filter { recipe in
            if dinnerFilters.quick && recipe.minutes > 30 { return false }
            if dinnerFilters.vegetarian && !recipe.vegetarian { return false }
            if dinnerFilters.glutenFree && !recipe.glutenFree { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredRecipes.isEmpty {
                    KitchenEmptyState(symbol: "book.fill", message: emptyMessage)
                } else {
                    List {
                        ForEach(filteredRecipes) { recipe in
                            ZStack(alignment: .leading) {
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)

                                MagazineClippingCard(
                                    recipe: recipe,
                                    isFavorite: store.isFavorite(recipe.id)
                                )
                            }
                            .contentShape(Rectangle())
                            .listRowInsets(EdgeInsets(top: 10, leading: 18, bottom: 18, trailing: 18))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    store.toggleFavorite(recipe.id)
                                } label: {
                                    Image(systemName: store.isFavorite(recipe.id) ? "star.slash" : "star.fill")
                                }
                                .tint(Color("AppPrimary"))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .kitchenClearChrome()
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showOpened) {
                if let openedRecipe {
                    RecipeDetailView(recipe: openedRecipe)
                }
            }
            .onChange(of: pendingRecipeID) { _ in
                openPendingRecipe()
            }
            .onAppear {
                openPendingRecipe()
            }
        }
        .background(Color.clear)
        .background(KitchenClearHost())
    }

    private func openPendingRecipe() {
        guard let id = pendingRecipeID, let recipe = RecipeCatalog.recipe(id: id) else { return }
        openedRecipe = recipe
        showOpened = true
        pendingRecipeID = nil
    }

    private var emptyMessage: String {
        if dinnerFilters.quick || dinnerFilters.vegetarian || dinnerFilters.glutenFree {
            return "No dish matches these dinner filters."
        }
        if cuisineFilter == "Saved" {
            return "No saved clippings yet. Star a dish from the table."
        }
        return "No Recipes Yet"
    }
}

struct MagazineClippingCard: View {
    let recipe: Recipe
    let isFavorite: Bool

    private var tilt: Double {
        let sum = recipe.id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Double((sum % 5) - 2) * 0.7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image(recipe.cuisine.bannerName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 168)
                    .clipped()

                LinearGradient(
                    colors: [Color("AppBackground").opacity(0.05), Color("AppBackground").opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack {
                    Text(recipe.cuisine.rawValue.uppercased())
                        .font(Theme.rounded(.caption, weight: .bold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule().fill(Color("AppSurface").opacity(0.92))
                        }
                    Spacer()
                    Text("\(recipe.minutes) min")
                        .font(Theme.rounded(.caption, weight: .bold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule().fill(Color("AppPrimary").opacity(0.9))
                        }
                }
                .padding(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(recipe.title)
                        .font(Theme.rounded(.title3, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    if isFavorite {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color("AppAccent"))
                            .accessibilityLabel("Saved")
                    }
                }
                if let foreignName = recipe.foreignName {
                    Text(foreignName)
                        .font(Theme.rounded(.subheadline, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("AppSurface"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(alignment: .top) {
            WashiTape()
                .offset(y: -7)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.18), lineWidth: 1)
        }
        .cheapPlateShadow()
        .rotationEffect(.degrees(tilt))
        .padding(.top, 8)
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject private var store: Store
    let recipe: Recipe
    @State private var marketNote: String?
    @State private var noteText = ""
    @State private var showPlanPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                banner
                titleBlock
                unitsRow
                servingsRow
                actionRow
                if let marketNote {
                    Text(marketNote)
                        .font(Theme.rounded(.subheadline, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("AppSurface"))
                        }
                }
                ingredientsBlock
                substitutionBlock
                translationBlock
                staplesBlock
                notesBlock
                stepsBlock
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .kitchenCanvas()
        .scrollDismissesKeyboard(.immediately)
        .dismissKeyboardOnTap()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppSurface"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(recipe.cuisine.rawValue)
                    .font(Theme.rounded(.headline, weight: .bold))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.toggleFavorite(recipe.id)
                } label: {
                    Image(systemName: store.isFavorite(recipe.id) ? "star.fill" : "star")
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(store.isFavorite(recipe.id) ? "Remove from saved" : "Save recipe")
            }
        }
        .onAppear { noteText = store.note(for: recipe.id) }
        .onChange(of: noteText) { value in
            store.setNote(value, for: recipe.id)
        }
        .confirmationDialog("Pin to the week", isPresented: $showPlanPicker, titleVisibility: .visible) {
            ForEach(PlanWeekday.allCases) { day in
                Button(day == PlanWeekday.today ? "\(day.title) · Today" : day.title) {
                    store.setPlan(recipe.id, day: day)
                    marketNote = "Pinned to \(day.title)."
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var banner: some View {
        Image(recipe.cuisine.bannerName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 210)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(alignment: .top) {
                WashiTape().offset(y: -6)
            }
            .cheapPlateShadow()
            .padding(.top, 12)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(recipe.title)
                    .font(Theme.rounded(.title, weight: .bold))
                    .foregroundStyle(.primary)
                if store.isFavorite(recipe.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            if let foreignName = recipe.foreignName {
                Text(foreignName)
                    .font(Theme.rounded(.title3, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Text("\(recipe.minutes) minutes at the stove")
                .font(Theme.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                if recipe.vegetarian {
                    Text("Veg")
                        .font(Theme.rounded(.caption, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background { Capsule().fill(Color("AppSurface")) }
                }
                if recipe.glutenFree {
                    Text("GF")
                        .font(Theme.rounded(.caption, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background { Capsule().fill(Color("AppSurface")) }
                }
            }
        }
    }

    private var unitsRow: some View {
        HStack(spacing: 10) {
            KitchenChip(title: "Metric", isSelected: store.preferredMeasurementUnits == "metric") {
                store.setPreferredUnits("metric")
            }
            KitchenChip(title: "US", isSelected: store.preferredMeasurementUnits == "imperial") {
                store.setPreferredUnits("imperial")
            }
            Spacer()
        }
    }

    private var servingsRow: some View {
        HStack(spacing: 10) {
            KitchenChip(title: "2", isSelected: store.servings == 2) {
                store.setServings(2)
            }
            KitchenChip(title: "4", isSelected: store.servings == 4) {
                store.setServings(4)
            }
            KitchenChip(title: "6", isSelected: store.servings == 6) {
                store.setServings(6)
            }
            Text("plates")
                .font(Theme.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var actionRow: some View {
        VStack(spacing: 12) {
            PlateActionButton(title: "Add to Market List", symbol: "basket.fill") {
                let before = store.groceryItems.count
                store.addMissingIngredients(from: recipe)
                if store.groceryItems.count == before {
                    marketNote = "Nothing new to buy — pantry or the list already covers this dish."
                } else {
                    marketNote = "Missing ingredients copied to the market list. Pantry staples were skipped."
                }
            }
            NavigationLink {
                CookFocusView(recipe: recipe)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "text.alignleft")
                    Text("Cook at the stove")
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .font(Theme.rounded(.headline, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    Capsule().fill(Theme.plateFill)
                }
                .cheapPlateShadow()
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
            PlateActionButton(title: "Start Cook Timer", symbol: "timer") {
                store.startCookTimer(dishName: recipe.title, minutes: recipe.minutes)
            }
            PlateActionButton(title: "Pin to week", symbol: "calendar") {
                showPlanPicker = true
            }
        }
    }

    private var ingredientsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients")
                .font(Theme.rounded(.headline, weight: .bold))
            ForEach(recipe.ingredients) { ingredient in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(Theme.plateFill)
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ingredient.name)
                            .font(Theme.rounded(.body, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("\(KitchenUnits.display(ingredient.quantity, preference: store.preferredMeasurementUnits, servings: store.servings)) · \(ingredient.category.rawValue)")
                            .font(Theme.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        store.togglePantry(ingredient.name)
                    } label: {
                        Image(systemName: store.isInPantry(ingredient.name) ? "cabinet.fill" : "cabinet")
                            .foregroundStyle(store.isInPantry(ingredient.name) ? Color("AppAccent") : Color("AppPrimary"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.isInPantry(ingredient.name) ? "Remove from pantry" : "Keep in pantry")
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface"))
                }
            }
        }
    }

    private var translationBlock: some View {
        let pairs: [(String, String)] = recipe.ingredients.compactMap { ingredient in
            guard let english = RecipeCatalog.englishName(for: ingredient.name) else { return nil }
            if english.lowercased() == ingredient.name.lowercased() { return nil }
            return (ingredient.name, english)
        }
        return Group {
            if !pairs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredient translation")
                        .font(Theme.rounded(.headline, weight: .bold))
                    ForEach(pairs, id: \.0) { pair in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.0)
                                .font(Theme.rounded(.body, weight: .semibold))
                            Text(pair.1)
                                .font(Theme.rounded(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("AppSurface"))
                        }
                    }
                }
            }
        }
    }

    private var substitutionBlock: some View {
        let pairs: [(String, String)] = recipe.ingredients.compactMap { ingredient in
            guard let swap = RecipeCatalog.substitution(for: ingredient.name) else { return nil }
            return (ingredient.name, swap)
        }
        return Group {
            if !pairs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("If the shop doesn't have it")
                        .font(Theme.rounded(.headline, weight: .bold))
                    ForEach(pairs, id: \.0) { pair in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.0)
                                .font(Theme.rounded(.body, weight: .semibold))
                            Text(pair.1)
                                .font(Theme.rounded(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("AppSurface"))
                        }
                    }
                }
            }
        }
    }

    private var notesBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your notes")
                .font(Theme.rounded(.headline, weight: .bold))
            TextField("Less salt, kids eat this, last time it caught…", text: $noteText, axis: .vertical)
                .font(Theme.rounded(.body))
                .lineLimit(3...6)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppSurface"))
                }
        }
    }

    private var staplesBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pantry staples for \(recipe.cuisine.rawValue) cooking")
                .font(Theme.rounded(.headline, weight: .bold))
            FlexibleStapleRow(names: RecipeCatalog.staples(for: recipe.cuisine))
        }
    }

    private var stepsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Method")
                .font(Theme.rounded(.headline, weight: .bold))
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle().fill(Theme.plateFill)
                        Text("\(index + 1)")
                            .font(Theme.rounded(.caption, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 28, height: 28)
                    Text(step)
                        .font(Theme.rounded(.body))
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppSurface"))
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
                        Image(systemName: store.isInPantry(name) ? "cabinet.fill" : "leaf.fill")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
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
        if let english = RecipeCatalog.englishName(for: name) {
            return "\(name) — \(english)"
        }
        return name
    }
}
