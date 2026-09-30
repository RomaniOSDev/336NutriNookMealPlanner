import SwiftUI

struct GroceryStudio: View {
    @EnvironmentObject private var store: Store
    @State private var showAddSheet = false
    @State private var showPantry = false
    @State private var forceExpand: Set<IngredientCategory> = []

    var body: some View {
        ZStack {
            NookBackdrop()
            Group {
            if store.groceryItems.isEmpty {
                KitchenEmptyState(
                    symbol: "cart.badge.plus",
                    message: "No pick-up list yet. Cook from pantry, or copy missing items from the week."
                )
            } else {
                List {
                    ForEach(IngredientCategory.allCases) { category in
                        categorySection(category)
                    }
                }
                .listStyle(.plain)
                .kitchenClearChrome()
                .scrollDismissesKeyboard(.immediately)
            }
            }
        }
        .hidesAppDock()
        .background(Color.clear)
        .overlay(alignment: .bottomLeading) {
            pantryPlate
        }
        .overlay(alignment: .bottomTrailing) {
            addPlate
        }
        .overlay(alignment: .bottom) {
            if store.undoGroceryID != nil {
                undoBanner
                    .padding(.bottom, 96)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddGrocerySheet()
                .environmentObject(store)
        }
        .sheet(isPresented: $showPantry) {
            PantryBoardView()
                .environmentObject(store)
        }
    }

    @ViewBuilder
    private func categorySection(_ category: IngredientCategory) -> some View {
        let items = store.items(in: category)
        if !items.isEmpty {
            Section {
                categoryHeader(category, items: items)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                if shouldShowItems(category, items: items) {
                    ForEach(items) { item in
                        groceryRow(item)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    store.setAcquired(item.id, acquired: !item.acquired)
                                } label: {
                                    Image(systemName: item.acquired ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(Color("AppPrimary"))
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    store.removeGroceryItem(item.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private func shouldShowItems(_ category: IngredientCategory, items: [GroceryItem]) -> Bool {
        let allDone = items.allSatisfy(\.acquired)
        if allDone { return forceExpand.contains(category) }
        return true
    }

    private func categoryHeader(_ category: IngredientCategory, items: [GroceryItem]) -> some View {
        let allDone = items.allSatisfy(\.acquired)
        return Button {
            if allDone {
                if forceExpand.contains(category) {
                    forceExpand.remove(category)
                } else {
                    forceExpand.insert(category)
                }
            }
        } label: {
            HStack {
                Text(category.rawValue)
                    .font(Theme.rounded(.headline, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                if allDone {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                    Text(forceExpand.contains(category) ? "Hide" : "Show")
                        .font(Theme.rounded(.caption, weight: .semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(items.filter(\.acquired).count)/\(items.count)")
                        .font(Theme.rounded(.caption, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .textCase(nil)
    }

    private func groceryRow(_ item: GroceryItem) -> some View {
        Button {
            store.setAcquired(item.id, acquired: !item.acquired)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color("AppPrimary"), lineWidth: 2)
                    if item.acquired {
                        Circle().fill(Theme.plateFill)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(Theme.rounded(.body, weight: .semibold))
                        .foregroundStyle(.primary)
                        .strikethrough(item.acquired, color: Color("AppPrimary"))
                    if let recipeId = item.recipeId, let recipe = store.recipe(id: recipeId) {
                        Text(recipe.title)
                            .font(Theme.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("AppSurface"))
            }
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityValue(item.acquired ? "Acquired" : "Needed")
    }

    private var addPlate: some View {
        Button {
            showAddSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.25))
                    .offset(y: 5)
                Circle()
                    .fill(Theme.plateFill)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 56, height: 56)
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .padding(.trailing, 22)
        .padding(.bottom, 18)
        .accessibilityLabel("Add market item")
    }

    private var pantryPlate: some View {
        Button {
            showPantry = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.25))
                    .offset(y: 5)
                Circle()
                    .fill(Theme.warmFill)
                Image(systemName: "cabinet.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 56, height: 56)
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .padding(.leading, 22)
        .padding(.bottom, 18)
        .accessibilityLabel("Pantry")
    }

    private var undoBanner: some View {
        Button {
            store.undoLastAcquired()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.backward")
                Text("Undo")
                    .font(Theme.rounded(.headline, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background {
                Capsule().fill(Theme.plateFill)
            }
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Undo acquired item")
    }
}

struct AddGrocerySheet: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: IngredientCategory = .produce
    @State private var showValidation = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name")
                    .font(Theme.rounded(.headline, weight: .bold))
                TextField("Item to pick up", text: $name)
                    .font(Theme.rounded(.body))
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("AppSurface"))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(showValidation ? Color("AppPrimary") : Color("AppPrimary").opacity(0.2), lineWidth: showValidation ? 2 : 1)
                    }

                if showValidation {
                    Text("Enter an item name.")
                        .font(Theme.rounded(.caption, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text("Aisle")
                    .font(Theme.rounded(.headline, weight: .bold))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                    ForEach(IngredientCategory.allCases) { item in
                        KitchenChip(title: item.rawValue, isSelected: category == item) {
                            category = item
                        }
                    }
                }

                Spacer()

                PlateActionButton(title: "Add to Market", symbol: "plus") {
                    if store.addGroceryItem(name: name, category: category) {
                        dismiss()
                    } else {
                        showValidation = true
                    }
                }
            }
            .padding(20)
            .contentShape(Rectangle())
            .dismissKeyboardOnTap()
            .scrollDismissesKeyboard(.immediately)
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Manual add")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
        }
    }
}
