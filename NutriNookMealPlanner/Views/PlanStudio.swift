import SwiftUI

struct PlanStudio: View {
    @EnvironmentObject private var store: Store
    @State private var pickingDay: PlanWeekday?
    @State private var shopNote: String?
    @State private var showMarket = false

    var body: some View {
        NavigationStack {
            ZStack {
                NookBackdrop()
                ScrollView {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("The week")
                                .font(Theme.rounded(.title, weight: .bold))
                            Text("Pin one weeknight dish per day, then copy only the missing items.")
                                .font(Theme.rounded(.subheadline, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(PlanWeekday.allCases) { day in
                            dayPlate(day)
                        }

                        if let shopNote {
                            Text(shopNote)
                                .font(Theme.rounded(.subheadline, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color("AppSurface"))
                                }
                        }

                        PlateActionButton(title: "Shop the missing items", symbol: "basket.fill") {
                            store.addMissingIngredientsForWeek()
                            shopNote = "Missing ingredients from the week landed on the list. Pantry and leftovers were skipped."
                            showMarket = true
                        }

                        NavigationLink {
                            GroceryStudio()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "list.bullet")
                                Text("Open the pick-up list (\(store.groceryItems.filter { !$0.acquired }.count) left)")
                            }
                            .font(Theme.rounded(.headline, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background { Capsule().fill(Color("AppSurface")) }
                            .cheapPlateShadow()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, Theme.dockClearance)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(Color.clear)
        .background(KitchenClearHost())
        .sheet(item: $pickingDay) { day in
            RecipePickSheet(day: day)
                .environmentObject(store)
        }
        .sheet(isPresented: $showMarket) {
            NavigationStack {
                GroceryStudio()
                    .environmentObject(store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showMarket = false }
                        }
                    }
            }
        }
    }

    private func dayPlate(_ day: PlanWeekday) -> some View {
        let recipe = store.plannedRecipe(on: day)
        let isToday = day == PlanWeekday.today

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.title)
                    .font(Theme.rounded(.headline, weight: .bold))
                    .foregroundStyle(.primary)
                if isToday {
                    Text("Today")
                        .font(Theme.rounded(.caption, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background { Capsule().fill(Color("AppAccent").opacity(0.9)) }
                }
                Spacer()
                if recipe != nil {
                    Button("Clear") {
                        store.setPlan(nil, day: day)
                    }
                    .font(Theme.rounded(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
                }
            }

            if let recipe {
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: recipe.kind.symbol)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.title)
                                .font(Theme.rounded(.body, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("\(recipe.minutes) min · \(recipe.kind.title)")
                                .font(Theme.rounded(.caption, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("AppSurface"))
                    }
                }
                .buttonStyle(.plain)

                Button("Change dish") { pickingDay = day }
                    .font(Theme.rounded(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    pickingDay = day
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pin a dish")
                                .font(Theme.rounded(.body, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Catalog or a dish you added")
                                .font(Theme.rounded(.caption, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("AppSurface"))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface").opacity(isToday ? 0.98 : 0.72))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isToday ? Color("AppAccent") : Color("AppPrimary").opacity(0.2), lineWidth: isToday ? 2 : 1)
        }
        .cheapPlateShadow()
    }
}

struct RecipePickSheet: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let day: PlanWeekday

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(store.allRecipes) { recipe in
                        Button {
                            store.setPlan(recipe.id, day: day)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recipe.title)
                                        .font(Theme.rounded(.body, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Text("\(recipe.kind.title) · \(recipe.minutes) min")
                                        .font(Theme.rounded(.caption, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if store.mealPlan[day.rawValue] == recipe.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("AppSurface"))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(day.title)
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
