import SwiftUI

struct RecipeIndexView: View {
    @EnvironmentObject private var store: Store
    @State private var searchText = ""
    @State private var kindFilter: DishKind?
    @State private var onlySaved = false

    private var filtered: [Recipe] {
        store.allRecipes.filter { recipe in
            if onlySaved && !store.isFavorite(recipe.id) { return false }
            if let kindFilter, recipe.kind != kindFilter { return false }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty { return true }
            let haystack = [
                recipe.title,
                recipe.foreignName ?? "",
                recipe.kind.title,
                recipe.ingredients.map(\.name).joined(separator: " ")
            ].joined(separator: " ").lowercased()
            return haystack.contains(query.lowercased())
        }
    }

    var body: some View {
        ZStack {
            NookBackdrop()
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Find a weeknight dish", text: $searchText)
                        .font(Theme.rounded(.body))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background { Capsule().fill(Color("AppSurface")) }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        KitchenChip(title: "All", isSelected: kindFilter == nil && !onlySaved) {
                            kindFilter = nil
                            onlySaved = false
                        }
                        KitchenChip(title: "Saved", isSelected: onlySaved) {
                            onlySaved = true
                            kindFilter = nil
                        }
                        ForEach(DishKind.allCases) { kind in
                            KitchenChip(title: kind.title, isSelected: kindFilter == kind) {
                                kindFilter = kind
                                onlySaved = false
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if filtered.isEmpty {
                    KitchenEmptyState(symbol: "leaf.fill", message: "No dish matches. Loosen the filter or add your own on Desk.")
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filtered) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    DishLineCard(recipe: recipe, isFavorite: store.isFavorite(recipe.id))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .padding(.top, 8)
        }
        .hidesAppDock()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppSurface"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Catalog")
                    .font(Theme.rounded(.headline, weight: .bold))
            }
        }
    }
}

struct DishLineCard: View {
    let recipe: Recipe
    let isFavorite: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.plateFill)
                Image(systemName: recipe.kind.symbol)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(recipe.title)
                        .font(Theme.rounded(.body, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color("AppAccent"))
                    }
                    if recipe.isCustom {
                        Text("Yours")
                            .font(Theme.rounded(.caption2, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background { Capsule().fill(Color("AppPrimary").opacity(0.25)) }
                    }
                }
                if let foreign = recipe.foreignName {
                    Text(foreign)
                        .font(Theme.rounded(.caption, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Text("\(recipe.kind.title) · \(recipe.minutes) min")
                    .font(Theme.rounded(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface").opacity(0.94))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.18), lineWidth: 1)
        }
        .cheapPlateShadow()
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject private var store: Store
    let recipe: Recipe
    @State private var marketNote: String?
    @State private var noteText = ""
    @State private var showPlanPicker = false

    private var match: PantryMatch {
        store.pantryMatch(for: recipe)
    }

    var body: some View {
        ZStack {
            NookBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    titleBlock
                    matchBlock
                    unitsRow
                    servingsRow
                    actionRow
                    if let marketNote {
                        Text(marketNote)
                            .font(Theme.rounded(.subheadline, weight: .semibold))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("AppSurface"))
                            }
                    }
                    ingredientsBlock
                    decoderBlock
                    notesBlock
                    stepsBlock
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .hidesAppDock()
        .scrollDismissesKeyboard(.immediately)
        .dismissKeyboardOnTap()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppSurface"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(recipe.kind.title)
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

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.plateFill)
                .frame(height: 168)
            VStack(alignment: .leading, spacing: 8) {
                DishKindBadge(kind: recipe.kind)
                if let foreign = recipe.foreignName {
                    Text(foreign)
                        .font(Theme.rounded(.title2, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
            .padding(18)
        }
        .cheapPlateShadow()
        .padding(.top, 12)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recipe.title)
                .font(Theme.rounded(.title, weight: .bold))
            Text("\(recipe.minutes) minutes · \(match.percent)% of the pantry already there")
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

    private var matchBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            if match.missing.isEmpty {
                Text("Every ingredient is on hand.")
                    .font(Theme.rounded(.subheadline, weight: .semibold))
            } else {
                Text("Buy \(match.missing.count): " + match.missing.map(\.name).joined(separator: ", "))
                    .font(Theme.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppSurface"))
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
            KitchenChip(title: "2", isSelected: store.servings == 2) { store.setServings(2) }
            KitchenChip(title: "4", isSelected: store.servings == 4) { store.setServings(4) }
            KitchenChip(title: "6", isSelected: store.servings == 6) { store.setServings(6) }
            Text("plates")
                .font(Theme.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var actionRow: some View {
        VStack(spacing: 12) {
            PlateActionButton(title: match.missing.isEmpty ? "Nothing to buy" : "Add missing to the list", symbol: "basket.fill") {
                let before = store.groceryItems.count
                store.addMissingList(match.missing, recipeID: recipe.id)
                if store.groceryItems.count == before {
                    marketNote = "The list already covers this dish, or the pantry does."
                } else {
                    marketNote = "Missing items landed on the week list."
                }
            }
            NavigationLink {
                CookFocusView(recipe: recipe)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                    Text("Cook this tonight")
                }
                .font(Theme.rounded(.headline, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background { Capsule().fill(Theme.plateFill) }
                .cheapPlateShadow()
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
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
                        .fill(store.isOnHand(ingredient.name) ? Color("AppAccent") : Color("AppPrimary"))
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ingredient.name)
                            .font(Theme.rounded(.body, weight: .semibold))
                        Text("\(KitchenUnits.display(ingredient.quantity, preference: store.preferredMeasurementUnits, servings: store.servings)) · \(ingredient.category.rawValue)")
                            .font(Theme.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        store.togglePantry(ingredient.name)
                    } label: {
                        Image(systemName: store.isInPantry(ingredient.name) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(store.isInPantry(ingredient.name) ? Color("AppAccent") : Color("AppPrimary"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.isInPantry(ingredient.name) ? "Remove from pantry" : "I have this")
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface"))
                }
            }
        }
    }

    private var decoderBlock: some View {
        let entries = recipe.ingredients.compactMap { RecipeCatalog.entry(for: $0.name) }
        let unique = Dictionary(grouping: entries, by: \.native).compactMap(\.value.first)
        return Group {
            if !unique.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Decoder")
                        .font(Theme.rounded(.headline, weight: .bold))
                    ForEach(unique) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.native) · \(entry.english)")
                                .font(Theme.rounded(.body, weight: .semibold))
                            Text(entry.meaning)
                                .font(Theme.rounded(.caption, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text("Swap: \(entry.substitution)")
                                .font(Theme.rounded(.caption, weight: .medium))
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
            TextField("Less salt, kids ate this…", text: $noteText, axis: .vertical)
                .font(Theme.rounded(.body))
                .lineLimit(3...6)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppSurface"))
                }
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
                    }
                    .frame(width: 28, height: 28)
                    Text(step)
                        .font(Theme.rounded(.body))
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

struct RecipeEditorView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    var existing: Recipe?

    @State private var title = ""
    @State private var foreignName = ""
    @State private var minutes = 20
    @State private var kind: DishKind = .bowl
    @State private var vegetarian = false
    @State private var glutenFree = true
    @State private var ingredientName = ""
    @State private var ingredientQty = ""
    @State private var ingredientCategory: IngredientCategory = .pantry
    @State private var ingredients: [Ingredient] = []
    @State private var stepText = ""
    @State private var steps: [String] = []
    @State private var leftoverText = ""
    @State private var leftoverHints: [String] = []
    @State private var showValidation = false

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        field("English name", text: $title)
                        field("Native name (optional)", text: $foreignName)
                        HStack {
                            Text("Minutes")
                                .font(Theme.rounded(.headline, weight: .bold))
                            Spacer()
                            Stepper("\(minutes)", value: $minutes, in: 5...180, step: 5)
                        }
                        Text("Kind")
                            .font(Theme.rounded(.headline, weight: .bold))
                        HStack {
                            ForEach(DishKind.allCases) { item in
                                KitchenChip(title: item.title, isSelected: kind == item) { kind = item }
                            }
                        }
                        Toggle("Vegetarian", isOn: $vegetarian)
                        Toggle("Gluten-free", isOn: $glutenFree)

                        Text("Ingredients")
                            .font(Theme.rounded(.headline, weight: .bold))
                        ForEach(ingredients) { item in
                            HStack {
                                Text("\(item.name) · \(item.quantity)")
                                    .font(Theme.rounded(.subheadline, weight: .semibold))
                                Spacer()
                                Button("Remove") {
                                    ingredients.removeAll { $0.id == item.id }
                                }
                                .font(Theme.rounded(.caption, weight: .bold))
                            }
                        }
                        field("Ingredient", text: $ingredientName)
                        field("Quantity", text: $ingredientQty)
                        HStack {
                            ForEach(IngredientCategory.allCases) { item in
                                KitchenChip(title: item.rawValue, isSelected: ingredientCategory == item) {
                                    ingredientCategory = item
                                }
                            }
                        }
                        PlateActionButton(title: "Add ingredient", symbol: "plus") {
                            let name = ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let qty = ingredientQty.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            ingredients.append(Ingredient(name: name, category: ingredientCategory, quantity: qty.isEmpty ? "to taste" : qty))
                            ingredientName = ""
                            ingredientQty = ""
                        }

                        Text("Steps")
                            .font(Theme.rounded(.headline, weight: .bold))
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1). \(step)")
                                    .font(Theme.rounded(.subheadline))
                                Spacer()
                                Button("Remove") { steps.remove(at: index) }
                                    .font(Theme.rounded(.caption, weight: .bold))
                            }
                        }
                        field("Next step", text: $stepText)
                        PlateActionButton(title: "Add step", symbol: "plus") {
                            let trimmed = stepText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            steps.append(trimmed)
                            stepText = ""
                        }

                        Text("Leftovers this dish often leaves")
                            .font(Theme.rounded(.headline, weight: .bold))
                        ForEach(leftoverHints, id: \.self) { hint in
                            HStack {
                                Text(hint)
                                Spacer()
                                Button("Remove") { leftoverHints.removeAll { $0 == hint } }
                                    .font(Theme.rounded(.caption, weight: .bold))
                            }
                        }
                        field("Leftover name", text: $leftoverText)
                        PlateActionButton(title: "Add leftover hint", symbol: "plus") {
                            let trimmed = leftoverText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            leftoverHints.append(trimmed)
                            leftoverText = ""
                        }

                        if showValidation {
                            Text("Need a title, at least one ingredient, and one step.")
                                .font(Theme.rounded(.caption, weight: .bold))
                        }

                        PlateActionButton(title: "Save dish", symbol: "checkmark") {
                            save()
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 28)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .dismissKeyboardOnTap()
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existing == nil ? "Your dish" : "Edit dish")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
            .onAppear { loadExisting() }
        }
        .hidesAppDock()
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.rounded(.headline, weight: .bold))
            TextField(title, text: text)
                .font(Theme.rounded(.body))
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface"))
                }
        }
    }

    private func loadExisting() {
        guard let existing else { return }
        title = existing.title
        foreignName = existing.foreignName ?? ""
        minutes = existing.minutes
        kind = existing.kind
        vegetarian = existing.vegetarian
        glutenFree = existing.glutenFree
        ingredients = existing.ingredients
        steps = existing.steps
        leftoverHints = existing.leftoverHints
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !ingredients.isEmpty, !steps.isEmpty else {
            showValidation = true
            return
        }
        let recipe = Recipe(
            id: existing?.id ?? "user-\(UUID().uuidString)",
            title: trimmedTitle,
            kind: kind,
            minutes: minutes,
            ingredients: ingredients,
            steps: steps,
            foreignName: foreignName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : foreignName,
            vegetarian: vegetarian,
            glutenFree: glutenFree,
            leftoverHints: leftoverHints,
            isCustom: true
        )
        store.upsertCustomRecipe(recipe)
        dismiss()
    }
}
