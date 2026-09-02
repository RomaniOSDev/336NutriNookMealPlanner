import Foundation

enum KitchenStation: String, CaseIterable, Identifiable {
    case recipes
    case plan
    case market
    case timers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recipes: return "Recipe Studio"
        case .plan: return "Week Plan"
        case .market: return "Market List"
        case .timers: return "Cook Timers"
        }
    }

    var symbol: String {
        switch self {
        case .recipes: return "fork.knife"
        case .plan: return "calendar"
        case .market: return "basket.fill"
        case .timers: return "timer"
        }
    }

    var dockLabel: String {
        switch self {
        case .recipes: return "Recipes"
        case .plan: return "Plan"
        case .market: return "Market"
        case .timers: return "Timers"
        }
    }
}

enum PlanWeekday: String, CaseIterable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var shortTitle: String {
        String(rawValue.prefix(3)).capitalized
    }

    static var today: PlanWeekday {
        switch Calendar.current.component(.weekday, from: Date()) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
}

struct DinnerFilters: Equatable {
    var quick = false
    var vegetarian = false
    var glutenFree = false
}

struct TimerPreset: Identifiable, Hashable {
    var name: String
    var minutes: Int
    var id: String { name }

    static let all: [TimerPreset] = [
        TimerPreset(name: "Rice", minutes: 15),
        TimerPreset(name: "Eggs", minutes: 7),
        TimerPreset(name: "Pasta", minutes: 9),
        TimerPreset(name: "Steam veg", minutes: 8),
        TimerPreset(name: "Rest dough", minutes: 20)
    ]
}

enum Cuisine: String, Codable, CaseIterable, Identifiable, Hashable {
    case japanese = "Japanese"
    case mexican = "Mexican"
    case italian = "Italian"
    case indian = "Indian"
    case thai = "Thai"
    case french = "French"

    var id: String { rawValue }

    var bannerName: String {
        switch self {
        case .japanese:
            return "BannerRamen"
        case .mexican:
            return "BannerPrep"
        case .indian:
            return "BannerSpices"
        case .thai:
            return "BannerThai"
        case .italian:
            return "BannerPasta"
        case .french:
            return "BannerFrench"
        }
    }
}

enum IngredientCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case produce = "Produce"
    case spices = "Spices"
    case proteins = "Proteins"
    case pantry = "Pantry"

    var id: String { rawValue }
}

struct Ingredient: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var category: IngredientCategory
    var quantity: String

    init(id: UUID = UUID(), name: String, category: IngredientCategory, quantity: String) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
    }
}

struct Recipe: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var cuisine: Cuisine
    var minutes: Int
    var ingredients: [Ingredient]
    var steps: [String]
    var foreignName: String?
    var vegetarian: Bool = false
    var glutenFree: Bool = false
}

struct GroceryItem: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var category: IngredientCategory
    var acquired: Bool
    var recipeId: String?

    init(
        id: UUID = UUID(),
        name: String,
        category: IngredientCategory,
        acquired: Bool = false,
        recipeId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.acquired = acquired
        self.recipeId = recipeId
    }
}

struct KitchenDayLog: Codable, Equatable, Identifiable {
    var day: String
    var saved: Int
    var checks: Int
    var cooks: Int
    var minutes: Int

    var id: String { day }
}

struct CookTimer: Codable, Identifiable, Equatable {
    var id: UUID
    var dishName: String
    var duration: TimeInterval
    var startedAt: Date?
    var isRunning: Bool
    var remaining: TimeInterval

    init(
        id: UUID = UUID(),
        dishName: String,
        duration: TimeInterval,
        startedAt: Date? = nil,
        isRunning: Bool = false,
        remaining: TimeInterval
    ) {
        self.id = id
        self.dishName = dishName
        self.duration = duration
        self.startedAt = startedAt
        self.isRunning = isRunning
        self.remaining = remaining
    }

    func displayedRemaining(at now: Date) -> TimeInterval {
        guard isRunning, let startedAt else { return max(0, remaining) }
        return max(0, remaining - now.timeIntervalSince(startedAt))
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        let left = displayedRemaining(at: Date())
        return min(1, max(0, 1 - (left / duration)))
    }
}

enum KitchenUnits {
    static let baseServings = 4

    static func scaled(_ quantity: String, servings: Int, base: Int = baseServings) -> String {
        guard servings != base, base > 0 else { return quantity }
        let factor = Double(servings) / Double(base)
        guard let regex = try? NSRegularExpression(pattern: #"(\d+(?:\.\d+)?)"#) else { return quantity }
        let nsrange = NSRange(quantity.startIndex..<quantity.endIndex, in: quantity)
        let matches = regex.matches(in: quantity, range: nsrange).reversed()
        var result = quantity
        for match in matches {
            guard let full = Range(match.range, in: result),
                  let value = Double(result[full]) else { continue }
            let scaled = value * factor
            let formatted: String
            if abs(scaled.rounded() - scaled) < 0.05 {
                formatted = String(Int(scaled.rounded()))
            } else {
                formatted = String(format: "%.1f", scaled)
            }
            result.replaceSubrange(full, with: formatted)
        }
        return result
    }

    static func display(_ quantity: String, preference: String, servings: Int = baseServings) -> String {
        let adjusted = KitchenUnits.scaled(quantity, servings: servings)
        guard preference == "imperial" else { return adjusted }

        var result = adjusted
        let pattern = #"(\d+(?:\.\d+)?)\s*g\b"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                guard let full = Range(match.range, in: result),
                      let numberRange = Range(match.range(at: 1), in: result),
                      let grams = Double(result[numberRange]) else { continue }
                let ounces = grams / 28.3495
                let formatted = ounces >= 10 ? String(format: "%.0f oz", ounces) : String(format: "%.1f oz", ounces)
                result.replaceSubrange(full, with: formatted)
            }
        }

        let mlPattern = #"(\d+(?:\.\d+)?)\s*ml\b"#
        if let regex = try? NSRegularExpression(pattern: mlPattern) {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                guard let full = Range(match.range, in: result),
                      let numberRange = Range(match.range(at: 1), in: result),
                      let ml = Double(result[numberRange]) else { continue }
                let floz = ml / 29.5735
                let formatted = floz >= 10 ? String(format: "%.0f fl oz", floz) : String(format: "%.1f fl oz", floz)
                result.replaceSubrange(full, with: formatted)
            }
        }

        return result
    }
}
