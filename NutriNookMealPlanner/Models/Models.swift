import Foundation

enum KitchenStation: String, CaseIterable, Identifiable {
    case today
    case decoder
    case week
    case desk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Tonight"
        case .decoder: return "Decoder"
        case .week: return "Week"
        case .desk: return "Desk"
        }
    }

    var symbol: String {
        switch self {
        case .today: return "moon.stars.fill"
        case .decoder: return "book.fill"
        case .week: return "calendar"
        case .desk: return "slider.horizontal.3"
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

enum DishKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case bowl
    case skillet
    case simmer
    case cool

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bowl: return "Rice bowl"
        case .skillet: return "Skillet"
        case .simmer: return "Simmer"
        case .cool: return "Cool plate"
        }
    }

    var symbol: String {
        switch self {
        case .bowl: return "leaf.circle.fill"
        case .skillet: return "flame.fill"
        case .simmer: return "drop.fill"
        case .cool: return "snowflake"
        }
    }
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

enum IngredientCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case produce = "Produce"
    case spices = "Spices"
    case proteins = "Proteins"
    case pantry = "Pantry"

    var id: String { rawValue }
}

struct Recipe: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var kind: DishKind
    var minutes: Int
    var ingredients: [Ingredient]
    var steps: [String]
    var foreignName: String?
    var vegetarian: Bool
    var glutenFree: Bool
    var leftoverHints: [String]
    var isCustom: Bool

    init(
        id: String,
        title: String,
        kind: DishKind,
        minutes: Int,
        ingredients: [Ingredient],
        steps: [String],
        foreignName: String? = nil,
        vegetarian: Bool = false,
        glutenFree: Bool = false,
        leftoverHints: [String] = [],
        isCustom: Bool = false
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.minutes = minutes
        self.ingredients = ingredients
        self.steps = steps
        self.foreignName = foreignName
        self.vegetarian = vegetarian
        self.glutenFree = glutenFree
        self.leftoverHints = leftoverHints
        self.isCustom = isCustom
    }
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
}

struct LeftoverItem: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var fromRecipeID: String?
    var createdAt: Date
    var used: Bool

    init(
        id: UUID = UUID(),
        name: String,
        fromRecipeID: String? = nil,
        createdAt: Date = Date(),
        used: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fromRecipeID = fromRecipeID
        self.createdAt = createdAt
        self.used = used
    }
}

struct DecoderEntry: Identifiable, Hashable {
    var native: String
    var english: String
    var meaning: String
    var substitution: String

    var id: String { native }

    var searchBlob: String {
        "\(native) \(english) \(meaning)".lowercased()
    }
}

struct PantryMatch: Identifiable {
    var recipe: Recipe
    var have: [Ingredient]
    var missing: [Ingredient]

    var id: String { recipe.id }

    var total: Int { max(recipe.ingredients.count, 1) }
    var percent: Int { Int((Double(have.count) / Double(total) * 100).rounded()) }
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
