import Foundation

enum RecipeCatalog {
    static let translations: [String: String] = [
        "味噌": "Miso (fermented soybean paste)",
        "のり": "Nori (dried seaweed)",
        "醤油": "Soy sauce",
        "みりん": "Mirin (sweet rice wine)",
        "だし": "Dashi (soup stock)",
        "豆腐": "Tofu",
        "ネギ": "Green onion / scallion",
        "ごま油": "Sesame oil",
        "chile ancho": "Dried ancho chile",
        "cilantro": "Fresh coriander leaf",
        "masa harina": "Nixtamalized corn flour",
        "cotija": "Aged Mexican crumbling cheese",
        "jalapeño": "Fresh jalapeño pepper",
        "achiote": "Annatto seed paste",
        "guanciale": "Cured pork jowl",
        "pecorino romano": "Hard sheep’s milk cheese",
        "arborio": "Short-grain risotto rice",
        "passata": "Strained tomato puree",
        "parmigiano": "Parmesan cheese",
        "garam masala": "Warm Indian spice blend",
        "ghee": "Clarified butter",
        "paneer": "Fresh Indian cheese",
        "jeera": "Cumin seeds",
        "haldi": "Turmeric",
        "น้ำปลา": "Fish sauce",
        "กะทิ": "Coconut milk",
        "ใบมะกรูด": "Makrut / kaffir lime leaves",
        "เส้นผัดไทย": "Pad Thai rice noodles",
        "น้ำตาลปี๊บ": "Palm sugar",
        "lardons": "Thick bacon strips",
        "bouquet garni": "Tied herb bundle (thyme, bay, parsley)",
        "herbes de Provence": "Dried southern-French herb mix",
        "crème fraîche": "Cultured thick cream",
        "shallot": "Mild small onion"
    ]

    static let substitutions: [String: String] = [
        "みりん": "Dry sherry, or 1 tbsp sugar + 1 tbsp water + 1 tsp rice vinegar",
        "だし": "Instant dashi, or hot water with a splash of soy and mushroom soaking liquid",
        "味噌": "Soybean paste; in a pinch, 1 tsp soy sauce plus a pinch of sugar",
        "醤油": "Tamari or coconut aminos",
        "ごま油": "Toasted sesame oil, or a neutral oil plus a pinch of sesame seeds",
        "のり": "Toasted seaweed snacks, or skip as garnish",
        "豆腐": "Firm tofu, or extra mushrooms for body",
        "chile ancho": "Mild paprika plus a pinch of smoked paprika",
        "cilantro": "Flat-leaf parsley and a squeeze of lime",
        "masa harina": "Ready-made corn tortillas; skip homemade chips",
        "cotija": "Feta or finely grated Parmesan",
        "jalapeño": "Serrano, or a pinch of chili flakes",
        "achiote": "Sweet paprika plus a pinch of cumin",
        "guanciale": "Pancetta or thick-cut bacon",
        "pecorino romano": "Parmesan or aged Asiago",
        "arborio": "Carnaroli or sushi rice",
        "passata": "Blended canned tomatoes",
        "parmigiano": "Pecorino or Grana Padano",
        "ghee": "Unsalted butter",
        "paneer": "Firm tofu or halloumi",
        "jeera": "Ground cumin, added a little later",
        "haldi": "Ground turmeric",
        "น้ำปลา": "Soy sauce plus a pinch of salt",
        "กะทิ": "Coconut cream, or evaporated milk with coconut extract",
        "ใบมะกรูด": "Lime zest plus a bay leaf",
        "เส้นผัดไทย": "Any flat rice noodle, or linguine in a pinch",
        "น้ำตาลปี๊บ": "Brown sugar or maple syrup",
        "lardons": "Thick bacon strips",
        "bouquet garni": "A thyme sprig, a bay leaf, and parsley stems",
        "herbes de Provence": "Thyme, rosemary, and oregano mixed",
        "crème fraîche": "Sour cream or thick yogurt",
        "shallot": "Mild onion or a small leek"
    ]

    static let recipes: [Recipe] = [
        Recipe(
            id: "jp-tonkotsu-ramen",
            title: "Tonkotsu Ramen",
            cuisine: .japanese,
            minutes: 90,
            ingredients: [
                Ingredient(name: "Pork bones", category: .proteins, quantity: "1.2 kg"),
                Ingredient(name: "だし", category: .pantry, quantity: "500 ml"),
                Ingredient(name: "味噌", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "3 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Ramen noodles", category: .pantry, quantity: "400 g"),
                Ingredient(name: "のり", category: .produce, quantity: "4 sheets"),
                Ingredient(name: "ネギ", category: .produce, quantity: "2 stalks")
            ],
            steps: [
                "Simmer pork bones in water for at least an hour, skimming foam so the broth stays creamy.",
                "Stir だし, 味噌, 醤油, and みりん into a ladle of hot broth to make the tare.",
                "Boil noodles until just springy, then drain well.",
                "Divide tare and broth into bowls, add noodles, and finish with のり and sliced ネギ."
            ],
            foreignName: "豚骨ラーメン"
        ),
        Recipe(
            id: "jp-chicken-teriyaki",
            title: "Chicken Teriyaki",
            cuisine: .japanese,
            minutes: 35,
            ingredients: [
                Ingredient(name: "Chicken thighs", category: .proteins, quantity: "600 g"),
                Ingredient(name: "醤油", category: .pantry, quantity: "4 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "3 tbsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Fresh ginger", category: .produce, quantity: "1 tbsp grated"),
                Ingredient(name: "ネギ", category: .produce, quantity: "1 stalk")
            ],
            steps: [
                "Pat chicken dry and brown in ごま油, skin side first, until golden.",
                "Pour in 醤油 and みりん with ginger; simmer until the glaze turns glossy.",
                "Spoon the sauce over the chicken and rest two minutes.",
                "Slice and scatter ネギ over the top."
            ],
            foreignName: "照り焼きチキン",
            glutenFree: true
        ),
        Recipe(
            id: "mx-street-tacos",
            title: "Street Tacos",
            cuisine: .mexican,
            minutes: 30,
            ingredients: [
                Ingredient(name: "Corn tortillas", category: .pantry, quantity: "8 pieces"),
                Ingredient(name: "Pork shoulder", category: .proteins, quantity: "500 g"),
                Ingredient(name: "achiote", category: .spices, quantity: "1 tbsp"),
                Ingredient(name: "jalapeño", category: .produce, quantity: "2 pieces"),
                Ingredient(name: "cilantro", category: .produce, quantity: "1 bunch"),
                Ingredient(name: "White onion", category: .produce, quantity: "1 small"),
                Ingredient(name: "cotija", category: .proteins, quantity: "60 g")
            ],
            steps: [
                "Rub pork with achiote and a pinch of salt, then sear until charred at the edges.",
                "Warm tortillas on a dry pan until they puff.",
                "Chop cilantro, onion, and jalapeño for a quick salsa.",
                "Fill tortillas, crumble cotija, and serve immediately."
            ],
            foreignName: "Tacos al Pastor",
            glutenFree: true
        ),
        Recipe(
            id: "mx-guacamole-bowl",
            title: "Market Guacamole",
            cuisine: .mexican,
            minutes: 15,
            ingredients: [
                Ingredient(name: "Ripe avocados", category: .produce, quantity: "3 pieces"),
                Ingredient(name: "Lime juice", category: .produce, quantity: "2 tbsp"),
                Ingredient(name: "cilantro", category: .produce, quantity: "1 handful"),
                Ingredient(name: "jalapeño", category: .produce, quantity: "1 piece"),
                Ingredient(name: "Tomato", category: .produce, quantity: "1 small"),
                Ingredient(name: "masa harina", category: .pantry, quantity: "for chips, 120 g")
            ],
            steps: [
                "Mash avocados with lime until chunky, not puree.",
                "Fold in chopped tomato, jalapeño, and cilantro.",
                "Taste for salt; keep the texture rustic.",
                "If making chips, press masa harina dough thin and toast until crisp."
            ],
            foreignName: "Guacamole",
            vegetarian: true,
            glutenFree: true
        ),
        Recipe(
            id: "it-cacio-e-pepe",
            title: "Cacio e Pepe",
            cuisine: .italian,
            minutes: 25,
            ingredients: [
                Ingredient(name: "Spaghetti", category: .pantry, quantity: "320 g"),
                Ingredient(name: "pecorino romano", category: .proteins, quantity: "90 g"),
                Ingredient(name: "Black pepper", category: .spices, quantity: "2 tsp"),
                Ingredient(name: "guanciale", category: .proteins, quantity: "80 g"),
                Ingredient(name: "Salt", category: .pantry, quantity: "for pasta water")
            ],
            steps: [
                "Toast cracked pepper in a dry pan until fragrant.",
                "Crisp guanciale, then keep the rendered fat in the pan.",
                "Boil spaghetti in well-salted water; save a cup of starchy water.",
                "Toss pasta with pecorino romano, pepper, and splashes of water until creamy."
            ],
            foreignName: "Cacio e Pepe"
        ),
        Recipe(
            id: "it-mushroom-risotto",
            title: "Mushroom Risotto",
            cuisine: .italian,
            minutes: 40,
            ingredients: [
                Ingredient(name: "arborio", category: .pantry, quantity: "300 g"),
                Ingredient(name: "Mixed mushrooms", category: .produce, quantity: "350 g"),
                Ingredient(name: "shallot", category: .produce, quantity: "2 pieces"),
                Ingredient(name: "Vegetable stock", category: .pantry, quantity: "1 L"),
                Ingredient(name: "parmigiano", category: .proteins, quantity: "70 g"),
                Ingredient(name: "passata", category: .pantry, quantity: "2 tbsp")
            ],
            steps: [
                "Sauté shallot and mushrooms until they give up their moisture.",
                "Toast arborio in the pan, then melt in a spoon of passata.",
                "Add hot stock one ladle at a time, stirring until each is absorbed.",
                "Finish off heat with parmigiano and rest one minute."
            ],
            foreignName: "Risotto ai Funghi",
            vegetarian: true,
            glutenFree: true
        ),
        Recipe(
            id: "in-tikka-masala",
            title: "Chicken Tikka Masala",
            cuisine: .indian,
            minutes: 55,
            ingredients: [
                Ingredient(name: "Chicken breast", category: .proteins, quantity: "650 g"),
                Ingredient(name: "ghee", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "garam masala", category: .spices, quantity: "2 tsp"),
                Ingredient(name: "haldi", category: .spices, quantity: "1 tsp"),
                Ingredient(name: "jeera", category: .spices, quantity: "1 tsp"),
                Ingredient(name: "Tomato puree", category: .pantry, quantity: "400 g"),
                Ingredient(name: "Yogurt", category: .proteins, quantity: "120 g"),
                Ingredient(name: "Fresh ginger", category: .produce, quantity: "1 tbsp")
            ],
            steps: [
                "Marinate chicken in yogurt, ginger, haldi, and half the garam masala.",
                "Sear in ghee until spotted with char.",
                "Bloom jeera in the same pan, then add tomato puree and remaining spices.",
                "Simmer chicken in the sauce until tender and the oil blips to the surface."
            ],
            foreignName: "चिकन टिक्का मसाला",
            glutenFree: true
        ),
        Recipe(
            id: "th-pad-thai",
            title: "Pad Thai",
            cuisine: .thai,
            minutes: 35,
            ingredients: [
                Ingredient(name: "เส้นผัดไทย", category: .pantry, quantity: "250 g"),
                Ingredient(name: "Shrimp", category: .proteins, quantity: "300 g"),
                Ingredient(name: "น้ำปลา", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "น้ำตาลปี๊บ", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Bean sprouts", category: .produce, quantity: "150 g"),
                Ingredient(name: "Garlic chives", category: .produce, quantity: "1 handful"),
                Ingredient(name: "Eggs", category: .proteins, quantity: "2 pieces"),
                Ingredient(name: "Tamarind paste", category: .pantry, quantity: "1 tbsp")
            ],
            steps: [
                "Soak เส้นผัดไทย until flexible, then drain.",
                "Stir-fry shrimp, push aside, and scramble the eggs.",
                "Add noodles with น้ำปลา, tamarind, and น้ำตาลปี๊บ; toss on high heat.",
                "Finish with bean sprouts and garlic chives so they stay crisp."
            ],
            foreignName: "ผัดไทย",
            glutenFree: true
        ),
        Recipe(
            id: "th-green-curry",
            title: "Green Curry",
            cuisine: .thai,
            minutes: 40,
            ingredients: [
                Ingredient(name: "กะทิ", category: .pantry, quantity: "400 ml"),
                Ingredient(name: "Green curry paste", category: .spices, quantity: "3 tbsp"),
                Ingredient(name: "Chicken thigh", category: .proteins, quantity: "450 g"),
                Ingredient(name: "Thai eggplant", category: .produce, quantity: "6 pieces"),
                Ingredient(name: "ใบมะกรูด", category: .produce, quantity: "6 leaves"),
                Ingredient(name: "น้ำปลา", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Thai basil", category: .produce, quantity: "1 handful")
            ],
            steps: [
                "Fry curry paste in a splash of กะทิ until the oil separates.",
                "Add remaining กะทิ and bring to a gentle bubble.",
                "Slide in chicken, eggplant, and torn ใบมะกรูด.",
                "Season with น้ำปลา and fold in Thai basil just before serving."
            ],
            foreignName: "แกงเขียวหวาน",
            glutenFree: true
        ),
        Recipe(
            id: "fr-coq-au-vin",
            title: "Coq au Vin",
            cuisine: .french,
            minutes: 90,
            ingredients: [
                Ingredient(name: "Chicken legs", category: .proteins, quantity: "1.1 kg"),
                Ingredient(name: "Red wine", category: .pantry, quantity: "500 ml"),
                Ingredient(name: "lardons", category: .proteins, quantity: "120 g"),
                Ingredient(name: "shallot", category: .produce, quantity: "4 pieces"),
                Ingredient(name: "bouquet garni", category: .spices, quantity: "1 bundle"),
                Ingredient(name: "Button mushrooms", category: .produce, quantity: "200 g"),
                Ingredient(name: "Carrots", category: .produce, quantity: "2 pieces")
            ],
            steps: [
                "Brown chicken and lardons; set aside the golden pieces.",
                "Soften shallot and carrots in the same pot.",
                "Return chicken, pour wine, and tuck in the bouquet garni.",
                "Simmer covered until the meat yields, adding mushrooms in the last 15 minutes."
            ],
            foreignName: "Coq au Vin",
            glutenFree: true
        ),
        Recipe(
            id: "fr-ratatouille",
            title: "Ratatouille",
            cuisine: .french,
            minutes: 60,
            ingredients: [
                Ingredient(name: "Eggplant", category: .produce, quantity: "1 large"),
                Ingredient(name: "Zucchini", category: .produce, quantity: "2 pieces"),
                Ingredient(name: "Ripe tomatoes", category: .produce, quantity: "4 pieces"),
                Ingredient(name: "Bell pepper", category: .produce, quantity: "1 piece"),
                Ingredient(name: "herbes de Provence", category: .spices, quantity: "2 tsp"),
                Ingredient(name: "Olive oil", category: .pantry, quantity: "3 tbsp"),
                Ingredient(name: "crème fraîche", category: .proteins, quantity: "optional, 2 tbsp")
            ],
            steps: [
                "Salt eggplant slices and pat dry after ten minutes.",
                "Sauté each vegetable in olive oil until just colored; keep pieces distinct.",
                "Layer in a pan with herbes de Provence and a splash of water.",
                "Bake until jammy; serve with a ribbon of crème fraîche if you like."
            ],
            foreignName: "Ratatouille Niçoise",
            vegetarian: true,
            glutenFree: true
        )
    ]

    static func recipe(id: String) -> Recipe? {
        recipes.first { $0.id == id }
    }

    static func englishName(for ingredient: String) -> String? {
        lookup(translations, ingredient)
    }

    static func substitution(for ingredient: String) -> String? {
        lookup(substitutions, ingredient)
    }

    private static func lookup(_ table: [String: String], _ ingredient: String) -> String? {
        let key = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = table[key] { return exact }
        let lowered = key.lowercased()
        return table.first { $0.key.lowercased() == lowered }?.value
    }

    static func staples(for cuisine: Cuisine) -> [String] {
        switch cuisine {
        case .japanese:
            return ["醤油", "みりん", "ごま油", "だし"]
        case .mexican:
            return ["cumin", "dried chiles", "masa harina", "lime"]
        case .italian:
            return ["olive oil", "garlic", "pecorino romano", "passata"]
        case .indian:
            return ["garam masala", "ghee", "jeera", "haldi"]
        case .thai:
            return ["น้ำปลา", "กะทิ", "palm sugar", "rice noodles"]
        case .french:
            return ["bouquet garni", "shallot", "butter", "herbes de Provence"]
        }
    }
}
