import SwiftUI
import UIKit

@MainActor
final class Store: ObservableObject {
    @Published var station: KitchenStation = .recipes
    @Published var selectedTimerID: UUID?
    @Published var favorites: [String] = []
    @Published var recentCuisineFilters: [String] = []
    @Published var groceryItems: [GroceryItem] = []
    @Published var preferredMeasurementUnits: String = "metric"
    @Published var timers: [CookTimer] = []
    @Published var lastActivityDate: Date?
    @Published var undoGroceryID: UUID?
    @Published var dayLogs: [KitchenDayLog] = []
    @Published var mealPlan: [String: String] = [:]
    @Published var pantryKeys: [String] = []
    @Published var recipeNotes: [String: String] = [:]
    @Published var servings: Int = 4

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let favorites = "nook.favorites"
        static let recentCuisineFilters = "nook.recentCuisineFilters"
        static let groceryItems = "nook.groceryItems"
        static let preferredMeasurementUnits = "nook.preferredMeasurementUnits"
        static let timers = "nook.timers"
        static let lastActivityDate = "nook.lastActivityDate"
        static let dayLogs = "nook.dayLogs"
        static let mealPlan = "nook.mealPlan"
        static let pantryKeys = "nook.pantryKeys"
        static let recipeNotes = "nook.recipeNotes"
        static let servings = "nook.servings"
    }

    init() {
        favorites = decode([String].self, key: Keys.favorites, fallback: [])
        recentCuisineFilters = decode([String].self, key: Keys.recentCuisineFilters, fallback: [])
        groceryItems = decode([GroceryItem].self, key: Keys.groceryItems, fallback: [])
        preferredMeasurementUnits = defaults.string(forKey: Keys.preferredMeasurementUnits) ?? "metric"
        timers = decode([CookTimer].self, key: Keys.timers, fallback: [])
        if defaults.object(forKey: Keys.lastActivityDate) != nil {
            lastActivityDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
        }
        dayLogs = decode([KitchenDayLog].self, key: Keys.dayLogs, fallback: [])
        mealPlan = decode([String: String].self, key: Keys.mealPlan, fallback: [:])
        pantryKeys = decode([String].self, key: Keys.pantryKeys, fallback: [])
        recipeNotes = decode([String: String].self, key: Keys.recipeNotes, fallback: [:])
        let storedServings = defaults.integer(forKey: Keys.servings)
        servings = [2, 4, 6].contains(storedServings) ? storedServings : 4
        freezeRunningTimers(at: Date())
        selectedTimerID = timers.first?.id
    }

    func recordActivity() {
        lastActivityDate = Date()
        if let lastActivityDate {
            defaults.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
        }
    }

    func isFavorite(_ recipeID: String) -> Bool {
        favorites.contains(recipeID)
    }

    func toggleFavorite(_ recipeID: String) {
        if let index = favorites.firstIndex(of: recipeID) {
            favorites.remove(at: index)
        } else {
            favorites.insert(recipeID, at: 0)
            bumpDayLog(saved: 1)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        persist(favorites, key: Keys.favorites)
        recordActivity()
    }

    func recordCuisineFilter(_ cuisine: String) {
        recentCuisineFilters.removeAll { $0 == cuisine }
        recentCuisineFilters.insert(cuisine, at: 0)
        if recentCuisineFilters.count > 8 {
            recentCuisineFilters = Array(recentCuisineFilters.prefix(8))
        }
        persist(recentCuisineFilters, key: Keys.recentCuisineFilters)
        recordActivity()
    }

    func addMissingIngredients(from recipe: Recipe) {
        var existing = Set(groceryItems.map { normalizedName($0.name) })
        var added = false
        for ingredient in recipe.ingredients {
            let key = normalizedName(ingredient.name)
            if existing.contains(key) { continue }
            if isInPantry(ingredient.name) { continue }
            groceryItems.append(
                GroceryItem(
                    name: listedName(for: ingredient),
                    category: ingredient.category,
                    acquired: false,
                    recipeId: recipe.id
                )
            )
            existing.insert(key)
            added = true
        }
        if added {
            persist(groceryItems, key: Keys.groceryItems)
            recordActivity()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    func addMissingIngredientsForWeek() {
        for recipeID in mealPlan.values {
            if let recipe = RecipeCatalog.recipe(id: recipeID) {
                addMissingIngredients(from: recipe)
            }
        }
    }

    func addGroceryItem(name: String, category: IngredientCategory) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        groceryItems.insert(
            GroceryItem(name: trimmed, category: category, acquired: false, recipeId: nil),
            at: 0
        )
        persist(groceryItems, key: Keys.groceryItems)
        recordActivity()
        return true
    }

    func removeGroceryItem(_ id: UUID) {
        groceryItems.removeAll { $0.id == id }
        if undoGroceryID == id { undoGroceryID = nil }
        persist(groceryItems, key: Keys.groceryItems)
        recordActivity()
    }

    func setAcquired(_ id: UUID, acquired: Bool) {
        guard let index = groceryItems.firstIndex(where: { $0.id == id }) else { return }
        groceryItems[index].acquired = acquired
        undoGroceryID = acquired ? id : nil
        persist(groceryItems, key: Keys.groceryItems)
        recordActivity()
        if acquired {
            bumpDayLog(checks: 1)
        }
        if acquired, categoryComplete(groceryItems[index].category) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func undoLastAcquired() {
        guard let id = undoGroceryID else { return }
        setAcquired(id, acquired: false)
        undoGroceryID = nil
    }

    func categoryComplete(_ category: IngredientCategory) -> Bool {
        let items = groceryItems.filter { $0.category == category }
        return !items.isEmpty && items.allSatisfy(\.acquired)
    }

    func items(in category: IngredientCategory) -> [GroceryItem] {
        groceryItems.filter { $0.category == category }
    }

    func setPreferredUnits(_ units: String) {
        preferredMeasurementUnits = units
        defaults.set(units, forKey: Keys.preferredMeasurementUnits)
        recordActivity()
    }

    func setServings(_ value: Int) {
        servings = value
        defaults.set(value, forKey: Keys.servings)
        recordActivity()
    }

    func isInPantry(_ name: String) -> Bool {
        pantryKeys.contains(normalizedName(name))
    }

    func togglePantry(_ name: String) {
        let key = normalizedName(name)
        guard !key.isEmpty else { return }
        if let index = pantryKeys.firstIndex(of: key) {
            pantryKeys.remove(at: index)
        } else {
            pantryKeys.insert(key, at: 0)
        }
        persist(pantryKeys, key: Keys.pantryKeys)
        recordActivity()
    }

    func addPantry(_ name: String) {
        let key = normalizedName(name)
        guard !key.isEmpty, !pantryKeys.contains(key) else { return }
        pantryKeys.insert(key, at: 0)
        persist(pantryKeys, key: Keys.pantryKeys)
        recordActivity()
    }

    func removePantryKey(_ key: String) {
        pantryKeys.removeAll { $0 == key }
        persist(pantryKeys, key: Keys.pantryKeys)
        recordActivity()
    }

    func note(for recipeID: String) -> String {
        recipeNotes[recipeID] ?? ""
    }

    func setNote(_ text: String, for recipeID: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            recipeNotes.removeValue(forKey: recipeID)
        } else {
            recipeNotes[recipeID] = text
        }
        persist(recipeNotes, key: Keys.recipeNotes)
        recordActivity()
    }

    func plannedRecipe(on day: PlanWeekday) -> Recipe? {
        guard let id = mealPlan[day.rawValue] else { return nil }
        return RecipeCatalog.recipe(id: id)
    }

    func setPlan(_ recipeID: String?, day: PlanWeekday) {
        if let recipeID {
            mealPlan[day.rawValue] = recipeID
        } else {
            mealPlan.removeValue(forKey: day.rawValue)
        }
        persist(mealPlan, key: Keys.mealPlan)
        recordActivity()
    }

    func onHandKeys() -> Set<String> {
        var keys = Set(pantryKeys)
        for item in groceryItems where item.acquired {
            keys.insert(normalizedName(item.name))
        }
        return keys
    }

    func recipesFromStock() -> [(Recipe, Int)] {
        let onHand = onHandKeys()
        return RecipeCatalog.recipes
            .map { recipe -> (Recipe, Int) in
                let hits = recipe.ingredients.filter { onHand.contains(normalizedName($0.name)) }.count
                return (recipe, hits)
            }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0.minutes < rhs.0.minutes
            }
    }

    func randomDinner(filters: DinnerFilters, preferSaved: Bool) -> Recipe? {
        var pool = RecipeCatalog.recipes
        if preferSaved, !favorites.isEmpty {
            pool = pool.filter { favorites.contains($0.id) }
        }
        pool = pool.filter { recipe in
            if filters.quick && recipe.minutes > 30 { return false }
            if filters.vegetarian && !recipe.vegetarian { return false }
            if filters.glutenFree && !recipe.glutenFree { return false }
            return true
        }
        if pool.isEmpty, preferSaved {
            return randomDinner(filters: filters, preferSaved: false)
        }
        return pool.randomElement()
    }

    func stepMinutes(for recipe: Recipe) -> Int {
        max(1, recipe.minutes / max(recipe.steps.count, 1))
    }

    func startCookTimer(dishName: String, minutes: Int) {
        let duration = TimeInterval(max(1, minutes) * 60)
        let timer = CookTimer(
            dishName: dishName,
            duration: duration,
            startedAt: Date(),
            isRunning: true,
            remaining: duration
        )
        timers.insert(timer, at: 0)
        selectedTimerID = timer.id
        station = .timers
        persist(timers, key: Keys.timers)
        recordActivity()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func addManualTimer(dishName: String, minutes: Int) -> Bool {
        let trimmed = dishName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, minutes > 0 else { return false }
        startCookTimer(dishName: trimmed, minutes: minutes)
        return true
    }

    func pauseTimer(_ id: UUID, at now: Date = Date()) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        let left = timers[index].displayedRemaining(at: now)
        timers[index].remaining = left
        timers[index].isRunning = false
        timers[index].startedAt = nil
        persist(timers, key: Keys.timers)
        recordActivity()
    }

    func resumeTimer(_ id: UUID, at now: Date = Date()) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        guard timers[index].remaining > 0 else { return }
        timers[index].startedAt = now
        timers[index].isRunning = true
        persist(timers, key: Keys.timers)
        recordActivity()
    }

    func toggleTimer(_ id: UUID, at now: Date = Date()) {
        guard let timer = timers.first(where: { $0.id == id }) else { return }
        if timer.isRunning {
            pauseTimer(id, at: now)
        } else {
            resumeTimer(id, at: now)
        }
    }

    func deleteTimer(_ id: UUID) {
        timers.removeAll { $0.id == id }
        if selectedTimerID == id {
            selectedTimerID = timers.first?.id
        }
        persist(timers, key: Keys.timers)
        recordActivity()
    }

    func pauseAllRunningTimers(at now: Date = Date()) {
        var changed = false
        for index in timers.indices where timers[index].isRunning {
            let left = timers[index].displayedRemaining(at: now)
            timers[index].remaining = left
            timers[index].isRunning = false
            timers[index].startedAt = nil
            changed = true
        }
        if changed {
            persist(timers, key: Keys.timers)
        }
    }

    func completeExpired(at now: Date) {
        var changed = false
        var finishedCooks = 0
        var finishedMinutes = 0
        for index in timers.indices {
            let left = timers[index].displayedRemaining(at: now)
            if timers[index].isRunning && left <= 0 {
                finishedCooks += 1
                finishedMinutes += max(1, Int((timers[index].duration / 60).rounded()))
                timers[index].remaining = 0
                timers[index].isRunning = false
                timers[index].startedAt = nil
                changed = true
            }
        }
        if changed {
            persist(timers, key: Keys.timers)
            bumpDayLog(cooks: finishedCooks, minutes: finishedMinutes)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func selectedTimer() -> CookTimer? {
        if let selectedTimerID, let match = timers.first(where: { $0.id == selectedTimerID }) {
            return match
        }
        return timers.first
    }

    func resetAllData() {
        favorites = []
        recentCuisineFilters = []
        groceryItems = []
        preferredMeasurementUnits = "metric"
        timers = []
        lastActivityDate = nil
        undoGroceryID = nil
        selectedTimerID = nil
        dayLogs = []
        mealPlan = [:]
        pantryKeys = []
        recipeNotes = [:]
        servings = 4
        station = .recipes

        defaults.removeObject(forKey: Keys.favorites)
        defaults.removeObject(forKey: Keys.recentCuisineFilters)
        defaults.removeObject(forKey: Keys.groceryItems)
        defaults.removeObject(forKey: Keys.preferredMeasurementUnits)
        defaults.removeObject(forKey: Keys.timers)
        defaults.removeObject(forKey: Keys.lastActivityDate)
        defaults.removeObject(forKey: Keys.dayLogs)
        defaults.removeObject(forKey: Keys.mealPlan)
        defaults.removeObject(forKey: Keys.pantryKeys)
        defaults.removeObject(forKey: Keys.recipeNotes)
        defaults.removeObject(forKey: Keys.servings)

        NotificationCenter.default.post(name: Notification.Name("dataReset"), object: nil)
    }

    private func freezeRunningTimers(at now: Date) {
        var changed = false
        for index in timers.indices where timers[index].isRunning {
            let left = timers[index].displayedRemaining(at: now)
            timers[index].remaining = left
            timers[index].isRunning = false
            timers[index].startedAt = nil
            changed = true
        }
        if changed {
            persist(timers, key: Keys.timers)
        }
    }

    func bumpDayLog(saved: Int = 0, checks: Int = 0, cooks: Int = 0, minutes: Int = 0) {
        let key = Self.dayStamp(Date())
        if let index = dayLogs.firstIndex(where: { $0.day == key }) {
            dayLogs[index].saved += saved
            dayLogs[index].checks += checks
            dayLogs[index].cooks += cooks
            dayLogs[index].minutes += minutes
        } else {
            dayLogs.append(
                KitchenDayLog(day: key, saved: saved, checks: checks, cooks: cooks, minutes: minutes)
            )
        }
        if dayLogs.count > 60 {
            dayLogs = Array(dayLogs.suffix(60))
        }
        persist(dayLogs, key: Keys.dayLogs)
    }

    static func dayStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func listedName(for ingredient: Ingredient) -> String {
        let quantity = KitchenUnits.display(
            ingredient.quantity,
            preference: preferredMeasurementUnits,
            servings: servings
        )
        return "\(ingredient.name) — \(quantity)"
    }

    private func normalizedName(_ name: String) -> String {
        let base = name.split(separator: "—").first.map(String.init) ?? name
        return base.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String, fallback: T) -> T {
        guard let data = defaults.data(forKey: key) else { return fallback }
        return (try? decoder.decode(type, from: data)) ?? fallback
    }
}
