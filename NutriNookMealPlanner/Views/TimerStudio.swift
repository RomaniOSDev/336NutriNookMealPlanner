import SwiftUI

struct DecoderStudio: View {
    @EnvironmentObject private var store: Store
    @State private var query = ""
    @State private var selected: DecoderEntry?

    private var filtered: [DecoderEntry] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if needle.isEmpty { return RecipeCatalog.decoderEntries }
        return RecipeCatalog.decoderEntries.filter { $0.searchBlob.contains(needle) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingredient decoder")
                            .font(Theme.rounded(.title, weight: .bold))
                        Text("Type 味噌, gochugaru, or wakame. Get the English, a swap, and dishes that use it.")
                            .font(Theme.rounded(.subheadline, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Foreign word or English name", text: $query)
                            .font(Theme.rounded(.body))
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background { Capsule().fill(Color("AppSurface")) }
                    .padding(.horizontal, 20)

                    if filtered.isEmpty {
                        KitchenEmptyState(symbol: "book.fill", message: "Nothing matches. Try miso, 醤油, doenjang, or daikon.")
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filtered) { entry in
                                    Button {
                                        selected = entry
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.native)
                                                    .font(Theme.rounded(.title3, weight: .bold))
                                                    .foregroundStyle(.primary)
                                                Text(entry.english)
                                                    .font(Theme.rounded(.subheadline, weight: .medium))
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: store.isInPantry(entry.native) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(store.isInPantry(entry.native) ? Color("AppAccent") : Color("AppPrimary"))
                                        }
                                        .padding(14)
                                        .background {
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(Color("AppSurface").opacity(0.94))
                                        }
                                        .cheapPlateShadow()
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, Theme.dockClearance)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
                .padding(.top, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selected) { entry in
                DecoderDetailSheet(entry: entry)
                    .environmentObject(store)
            }
        }
        .background(Color.clear)
        .background(KitchenClearHost())
    }
}

struct DecoderDetailSheet: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let entry: DecoderEntry

    private var dishes: [Recipe] {
        store.allRecipes.filter { recipe in
            recipe.ingredients.contains { RecipeCatalog.namesOverlap($0.name, entry.native) }
                || RecipeCatalog.recipesContaining(entry).contains(where: { $0.id == recipe.id })
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(entry.native)
                            .font(Theme.rounded(.largeTitle, weight: .bold))
                        Text(entry.english)
                            .font(Theme.rounded(.title3, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text(entry.meaning)
                            .font(Theme.rounded(.body))
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("If the shop doesn’t have it")
                                    .font(Theme.rounded(.headline, weight: .bold))
                                Text(entry.substitution)
                                    .font(Theme.rounded(.subheadline))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        PlateActionButton(
                            title: store.isInPantry(entry.native) ? "On the shelf — tap to remove" : "I have this at home",
                            symbol: store.isInPantry(entry.native) ? "checkmark.circle.fill" : "plus.circle.fill"
                        ) {
                            store.togglePantry(entry.native)
                        }

                        Text("Dishes that use it")
                            .font(Theme.rounded(.headline, weight: .bold))
                        if dishes.isEmpty {
                            Text("No catalog dish lists this yet.")
                                .font(Theme.rounded(.subheadline))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(dishes) { recipe in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(recipe.title)
                                            .font(Theme.rounded(.body, weight: .semibold))
                                        Text("\(recipe.kind.title) · \(recipe.minutes) min")
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
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 28)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Decoder")
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
