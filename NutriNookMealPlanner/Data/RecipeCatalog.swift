import Foundation

enum RecipeCatalog {
    static let decoderEntries: [DecoderEntry] = [
        DecoderEntry(native: "味噌", english: "Miso", meaning: "Fermented soybean paste. White (shiromiso) is milder; red is saltier.", substitution: "1 tsp soy sauce + pinch of sugar, or doenjang thinned with water"),
        DecoderEntry(native: "醤油", english: "Soy sauce", meaning: "Brewed soy-and-wheat sauce. Use usukuchi if you want salt without dark color.", substitution: "Tamari (gluten-free) or coconut aminos plus a pinch of salt"),
        DecoderEntry(native: "みりん", english: "Mirin", meaning: "Sweet rice wine that glosses glazes and rounds salt.", substitution: "1 tbsp water + 1 tsp sugar + 1 tsp rice vinegar, or dry sherry"),
        DecoderEntry(native: "ごま油", english: "Sesame oil", meaning: "Toasted sesame oil. A few drops at the end; it burns if you fry with it.", substitution: "Neutral oil plus a pinch of toasted sesame seeds"),
        DecoderEntry(native: "だし", english: "Dashi", meaning: "Kelp-and-bonito stock. Instant granules are fine on a weeknight.", substitution: "Hot water with a splash of soy and the soaking liquid from dried mushrooms"),
        DecoderEntry(native: "ねぎ", english: "Scallion / negi", meaning: "Long green onion. Whites for frying, greens for garnish.", substitution: "Spring onion, or a thin leek"),
        DecoderEntry(native: "大根", english: "Daikon", meaning: "Mild winter radish that sweetens as it simmers.", substitution: "Turnip or peeled regular radish, cooked a little less"),
        DecoderEntry(native: "豆腐", english: "Tofu", meaning: "Bean curd. Soft for simmering, firm for skillet work.", substitution: "Extra mushrooms, or a fried egg for protein"),
        DecoderEntry(native: "白菜", english: "Napa cabbage", meaning: "Pale crinkly cabbage that wilts into broths and skillets.", substitution: "Savoy cabbage or the inner leaves of green cabbage"),
        DecoderEntry(native: "ごぼう", english: "Burdock root", meaning: "Earthy root used in kinpira. Scrub, don't peel heavily.", substitution: "Julienned carrot plus a pinch of sesame"),
        DecoderEntry(native: "わかめ", english: "Wakame", meaning: "Silky seaweed. Soak dried sheets 5 minutes.", substitution: "Nori scraps, or skip and add extra cucumber"),
        DecoderEntry(native: "ごま", english: "Sesame seeds", meaning: "White or black. Toast in a dry pan until they pop.", substitution: "Tahini thinned with water, a tiny amount"),
        DecoderEntry(native: "片栗粉", english: "Potato starch", meaning: "Glossy thickener; mix with cold water first.", substitution: "Cornstarch, same volume"),
        DecoderEntry(native: "昆布", english: "Kombu", meaning: "Dried kelp for vegetarian dashi. Wipe, don't wash.", substitution: "A strip of nori plus a pinch of MSG or mushroom powder"),
        DecoderEntry(native: "고추가루", english: "Gochugaru", meaning: "Korean chili flakes. Coarse for kimchi heat, fine for sauces.", substitution: "Aleppo pepper, or mild paprika plus a pinch of cayenne"),
        DecoderEntry(native: "된장", english: "Doenjang", meaning: "Korean soybean paste, funkier and saltier than miso.", substitution: "Red miso plus a splash of soy"),
        DecoderEntry(native: "깻잎", english: "Perilla / kkaennip", meaning: "Fragrant leaf, mint-meets-basil. Eat raw or wilted.", substitution: "Shiso, or basil plus a squeeze of lime"),
        DecoderEntry(native: "대파", english: "Korean leek / daepa", meaning: "Thicker than a scallion; the white is the prize.", substitution: "Leek whites or fat scallions"),
        DecoderEntry(native: "김", english: "Gim / roasted seaweed", meaning: "Crisp sheets for wrapping rice or crumbling over bowls.", substitution: "Nori snacks"),
        DecoderEntry(native: "生姜", english: "Ginger", meaning: "Fresh rhizome. Grate for heat, slice for simmering.", substitution: "1/4 tsp ground ginger, added later")
    ]

    static let pantryStaples: [String] = [
        "醤油", "味噌", "みりん", "ごま油", "だし", "ごま", "고추가루", "된장"
    ]

    static let recipes: [Recipe] = [
        Recipe(
            id: "negi-butter-gohan",
            title: "Negi Butter Gohan",
            kind: .bowl,
            minutes: 18,
            ingredients: [
                Ingredient(name: "Cooked rice", category: .pantry, quantity: "600 g"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "4 stalks"),
                Ingredient(name: "Butter", category: .pantry, quantity: "30 g"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1.5 tbsp"),
                Ingredient(name: "Eggs", category: .proteins, quantity: "4 pieces"),
                Ingredient(name: "ごま", category: .spices, quantity: "1 tsp")
            ],
            steps: [
                "Char ねぎ in a dry pan until the whites blister; chop.",
                "Melt butter, stir in 醤油, then fold through hot rice.",
                "Jammy-fry the eggs: whites set, yolks still gloss.",
                "Pile eggs on rice, scatter burnt ねぎ and ごま."
            ],
            foreignName: "ねぎバターご飯",
            vegetarian: true,
            glutenFree: false,
            leftoverHints: ["Cooked rice", "ねぎ"]
        ),
        Recipe(
            id: "sheet-miso-nasu",
            title: "Sheet Miso Nasu",
            kind: .skillet,
            minutes: 32,
            ingredients: [
                Ingredient(name: "Eggplant", category: .produce, quantity: "2 medium"),
                Ingredient(name: "豆腐", category: .proteins, quantity: "400 g firm"),
                Ingredient(name: "味噌", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Ginger", category: .produce, quantity: "1 tbsp grated")
            ],
            steps: [
                "Heat the oven to 220°C. Halve eggplant and cube 豆腐.",
                "Stir 味噌, みりん, ごま油, and ginger into a paste.",
                "Toss everything on a tray; roast 22 minutes until the paste caramelizes at the edges.",
                "Rest two minutes so the 豆腐 drinks the glaze."
            ],
            foreignName: "味噌ナスオーブン",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["豆腐", "Eggplant"]
        ),
        Recipe(
            id: "napa-chicken-nabe",
            title: "Napa Chicken Nabé",
            kind: .simmer,
            minutes: 28,
            ingredients: [
                Ingredient(name: "Leftover chicken", category: .proteins, quantity: "300 g"),
                Ingredient(name: "白菜", category: .produce, quantity: "400 g"),
                Ingredient(name: "だし", category: .pantry, quantity: "700 ml"),
                Ingredient(name: "醤油", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "生姜", category: .produce, quantity: "4 slices"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "2 stalks")
            ],
            steps: [
                "Bring だし, 醤油, and 生姜 to a quiet simmer.",
                "Lay 白菜 in first so it wilts into the stock.",
                "Add leftover chicken just to heat through — don't boil it hard.",
                "Finish with sliced ねぎ at the table."
            ],
            foreignName: "白菜と鶏の小鍋",
            glutenFree: true,
            leftoverHints: ["Leftover chicken", "白菜", "だし"]
        ),
        Recipe(
            id: "daikon-buta-simmer",
            title: "Daikon Buta Simmer",
            kind: .simmer,
            minutes: 40,
            ingredients: [
                Ingredient(name: "大根", category: .produce, quantity: "500 g"),
                Ingredient(name: "Pork shoulder", category: .proteins, quantity: "350 g"),
                Ingredient(name: "醤油", category: .pantry, quantity: "3 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "だし", category: .pantry, quantity: "400 ml"),
                Ingredient(name: "生姜", category: .produce, quantity: "1 tbsp")
            ],
            steps: [
                "Peel 大根 into chunks; blanch pork briefly and drain.",
                "Simmer 大根 in だし until a skewer slips in, about 20 minutes.",
                "Add pork, 醤油, みりん, and 生姜. Cover and cook 15 minutes more.",
                "Uncover to reduce until the 大根 looks lacquered."
            ],
            foreignName: "大根と豚肉の煮物",
            glutenFree: false,
            leftoverHints: ["大根", "Pork shoulder"]
        ),
        Recipe(
            id: "gochugaru-cabbage-tofu",
            title: "Gochugaru Cabbage Tofu",
            kind: .skillet,
            minutes: 22,
            ingredients: [
                Ingredient(name: "白菜", category: .produce, quantity: "350 g"),
                Ingredient(name: "豆腐", category: .proteins, quantity: "350 g"),
                Ingredient(name: "고추가루", category: .spices, quantity: "1.5 tsp"),
                Ingredient(name: "된장", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "대파", category: .produce, quantity: "1 stalk")
            ],
            steps: [
                "Bloom 고추가루 in ごま油 for 20 seconds — don't let it blacken.",
                "Stir in 된장 with a splash of water, then wilt 白菜.",
                "Nestle 豆腐 cubes; lid on for 6 minutes.",
                "Scatter 대파 and serve over rice if you have it."
            ],
            foreignName: "고추배추두부볶음",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["豆腐", "白菜"]
        ),
        Recipe(
            id: "smacked-cucumber-sesame",
            title: "Smacked Cucumber Sesame",
            kind: .cool,
            minutes: 12,
            ingredients: [
                Ingredient(name: "Cucumber", category: .produce, quantity: "2 large"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "ごま", category: .spices, quantity: "1 tbsp"),
                Ingredient(name: "Garlic", category: .produce, quantity: "1 clove"),
                Ingredient(name: "Rice vinegar", category: .pantry, quantity: "1 tbsp")
            ],
            steps: [
                "Smack cucumbers under a knife until they split; break into chunks.",
                "Salt 10 minutes, then squeeze out water.",
                "Toss with garlic, 醤油, vinegar, and ごま油.",
                "Finish with toasted ごま. Eat cold beside rice."
            ],
            foreignName: "たたききゅうり",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Cucumber"]
        ),
        Recipe(
            id: "ginger-mackerel-packets",
            title: "Ginger Mackerel Packets",
            kind: .skillet,
            minutes: 24,
            ingredients: [
                Ingredient(name: "Mackerel fillets", category: .proteins, quantity: "4 pieces"),
                Ingredient(name: "生姜", category: .produce, quantity: "8 slices"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "2 stalks"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Lemon", category: .produce, quantity: "1/2 fruit")
            ],
            steps: [
                "Lay each fillet on foil with 生姜 and ねぎ.",
                "Splash みりん and 醤油; seal the packets.",
                "Steam in a covered skillet over medium heat 12 minutes.",
                "Open carefully; finish with lemon."
            ],
            foreignName: "生姜さば包み蒸し",
            glutenFree: true,
            leftoverHints: ["Mackerel fillets"]
        ),
        Recipe(
            id: "carrot-kinpira-rice",
            title: "Carrot Kinpira Rice",
            kind: .bowl,
            minutes: 20,
            ingredients: [
                Ingredient(name: "Carrots", category: .produce, quantity: "400 g"),
                Ingredient(name: "ごぼう", category: .produce, quantity: "1 small, optional"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1.5 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Cooked rice", category: .pantry, quantity: "600 g"),
                Ingredient(name: "ごま", category: .spices, quantity: "1 tsp")
            ],
            steps: [
                "Julienne carrots (and ごぼう if using).",
                "Stir-fry in ごま油 until they squeak, about 4 minutes.",
                "Add 醤油 and みりん; cook until the pan looks dry and shiny.",
                "Spoon over leftover rice and dust with ごま."
            ],
            foreignName: "きんぴらにんじんご飯",
            vegetarian: true,
            glutenFree: false,
            leftoverHints: ["Cooked rice", "Carrots"]
        ),
        Recipe(
            id: "soft-tofu-jorim",
            title: "Soft Tofu Jorim",
            kind: .simmer,
            minutes: 18,
            ingredients: [
                Ingredient(name: "豆腐", category: .proteins, quantity: "400 g soft"),
                Ingredient(name: "Spinach", category: .produce, quantity: "150 g"),
                Ingredient(name: "醤油", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "고추가루", category: .spices, quantity: "1 tsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "Garlic", category: .produce, quantity: "2 cloves")
            ],
            steps: [
                "Slide soft 豆腐 into a shallow pan with a splash of water.",
                "Spoon over garlic, 醤油, and 고추가루.",
                "Simmer gently 8 minutes; tuck spinach around the edges.",
                "Finish with ごま油. Eat with a spoon, not chopsticks."
            ],
            foreignName: "순두부조림",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["豆腐"]
        ),
        Recipe(
            id: "leek-mushroom-miso",
            title: "Leek Mushroom Miso Skillet",
            kind: .skillet,
            minutes: 22,
            ingredients: [
                Ingredient(name: "Leeks", category: .produce, quantity: "2 medium"),
                Ingredient(name: "Mixed mushrooms", category: .produce, quantity: "300 g"),
                Ingredient(name: "味噌", category: .pantry, quantity: "1.5 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Butter", category: .pantry, quantity: "15 g"),
                Ingredient(name: "だし", category: .pantry, quantity: "80 ml")
            ],
            steps: [
                "Sweat sliced leeks in butter until they collapse.",
                "Add mushrooms; wait for their water to cook off.",
                "Loosen 味噌 with だし and みりん; pour in.",
                "Reduce until it coats a spoon. Good on barley or rice."
            ],
            foreignName: "ねぎきのこ味噌炒め",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Mixed mushrooms", "Leeks"]
        ),
        Recipe(
            id: "wakame-cucumber-bowl",
            title: "Wakame Cucumber Bowl",
            kind: .cool,
            minutes: 15,
            ingredients: [
                Ingredient(name: "わかめ", category: .produce, quantity: "10 g dried"),
                Ingredient(name: "Cucumber", category: .produce, quantity: "1 large"),
                Ingredient(name: "Rice vinegar", category: .pantry, quantity: "1.5 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "ごま", category: .spices, quantity: "1 tsp"),
                Ingredient(name: "Cooked rice", category: .pantry, quantity: "400 g")
            ],
            steps: [
                "Soak わかめ 5 minutes; drain well.",
                "Thin-slice cucumber and salt lightly.",
                "Dress seaweed and cucumber with vinegar and 醤油.",
                "Spoon over cool rice and finish with ごま."
            ],
            foreignName: "わかめきゅうり丼",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Cooked rice", "Cucumber", "わかめ"]
        ),
        Recipe(
            id: "tsukune-barley-bowl",
            title: "Tsukune Barley Bowl",
            kind: .bowl,
            minutes: 30,
            ingredients: [
                Ingredient(name: "Minced chicken", category: .proteins, quantity: "450 g"),
                Ingredient(name: "Barley", category: .pantry, quantity: "200 g dry"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "2 stalks"),
                Ingredient(name: "醤油", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "片栗粉", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "生姜", category: .produce, quantity: "1 tsp")
            ],
            steps: [
                "Cook barley until tender; keep warm.",
                "Mix chicken with chopped ねぎ, 生姜, and 片栗粉.",
                "Shape small ovals and brown in a pan.",
                "Glaze with 醤油 and みりん; rest on the barley."
            ],
            foreignName: "つくね麦ご飯",
            leftoverHints: ["Minced chicken", "Barley"]
        ),
        Recipe(
            id: "potato-soy-greens",
            title: "Potato Soy Greens",
            kind: .simmer,
            minutes: 26,
            ingredients: [
                Ingredient(name: "Potatoes", category: .produce, quantity: "500 g"),
                Ingredient(name: "Komatsuna or spinach", category: .produce, quantity: "200 g"),
                Ingredient(name: "醤油", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "だし", category: .pantry, quantity: "250 ml"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tsp")
            ],
            steps: [
                "Chunk potatoes; simmer in だし until just tender.",
                "Add 醤油 and みりん; cook until the liquid is syrupy.",
                "Fold greens through for 1 minute.",
                "Gloss with ごま油 off the heat."
            ],
            foreignName: "じゃがいもの含め煮",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Potatoes"]
        ),
        Recipe(
            id: "scallion-udon-broth",
            title: "Scallion Udon Broth",
            kind: .bowl,
            minutes: 16,
            ingredients: [
                Ingredient(name: "Udon noodles", category: .pantry, quantity: "400 g"),
                Ingredient(name: "だし", category: .pantry, quantity: "800 ml"),
                Ingredient(name: "醤油", category: .pantry, quantity: "2 tbsp"),
                Ingredient(name: "みりん", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "3 stalks"),
                Ingredient(name: "김", category: .pantry, quantity: "2 sheets")
            ],
            steps: [
                "Heat だし with 醤油 and みりん — taste for salt, not soy-darkness.",
                "Boil udon separately; drain well.",
                "Char ねぎ in a dry pan, then slice.",
                "Assemble: noodles, hot broth, ねぎ, crumbled 김. This is kake-style, not a long-simmered soup."
            ],
            foreignName: "ねぎかけうどん",
            vegetarian: true,
            leftoverHints: ["Udon noodles", "だし"]
        ),
        Recipe(
            id: "perilla-cucumber-crunch",
            title: "Perilla Cucumber Crunch",
            kind: .cool,
            minutes: 10,
            ingredients: [
                Ingredient(name: "깻잎", category: .produce, quantity: "20 leaves"),
                Ingredient(name: "Cucumber", category: .produce, quantity: "1 large"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "고추가루", category: .spices, quantity: "1/2 tsp"),
                Ingredient(name: "ごま", category: .spices, quantity: "1 tsp")
            ],
            steps: [
                "Stack 깻잎, roll, and slice into ribbons.",
                "Cut cucumber into matchsticks.",
                "Toss with ごま油, 醤油, and 고추가루.",
                "Eat as a side tonight; leftover mix is tomorrow's rice topper."
            ],
            foreignName: "깻잎오이무침",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["깻잎", "Cucumber"]
        ),
        Recipe(
            id: "evening-tea-rice",
            title: "Evening Tea Rice",
            kind: .bowl,
            minutes: 8,
            ingredients: [
                Ingredient(name: "Cooked rice", category: .pantry, quantity: "400 g"),
                Ingredient(name: "Green tea or だし", category: .pantry, quantity: "400 ml"),
                Ingredient(name: "김", category: .pantry, quantity: "1 sheet"),
                Ingredient(name: "ねぎ", category: .produce, quantity: "1 stalk"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "Pickled plum or salt", category: .pantry, quantity: "1 piece")
            ],
            steps: [
                "Heat leftover rice in a bowl.",
                "Brew strong green tea, or warm だし.",
                "Pour over the rice so grains loosen, not soup.",
                "Top with 김, ねぎ, a drop of 醤油, and the plum."
            ],
            foreignName: "夕方のお茶漬け",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Cooked rice"]
        ),
        Recipe(
            id: "goguma-gochujang-roast",
            title: "Goguma Chili Roast",
            kind: .skillet,
            minutes: 35,
            ingredients: [
                Ingredient(name: "Sweet potatoes", category: .produce, quantity: "700 g"),
                Ingredient(name: "고추가루", category: .spices, quantity: "1 tsp"),
                Ingredient(name: "된장", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "ごま油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Honey or rice syrup", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Sesame seeds", category: .spices, quantity: "1 tsp")
            ],
            steps: [
                "Heat oven to 210°C. Cube sweet potatoes.",
                "Stir 고추가루, 된장, ごま油, and honey.",
                "Coat the cubes; roast 28 minutes, turning once.",
                "They should be jammy at the edges. Sprinkle sesame."
            ],
            foreignName: "고구마고추구이",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Sweet potatoes"]
        ),
        Recipe(
            id: "spinach-gomaae-supper",
            title: "Spinach Goma-ae Supper",
            kind: .cool,
            minutes: 14,
            ingredients: [
                Ingredient(name: "Spinach", category: .produce, quantity: "400 g"),
                Ingredient(name: "ごま", category: .spices, quantity: "3 tbsp"),
                Ingredient(name: "醤油", category: .pantry, quantity: "1 tbsp"),
                Ingredient(name: "Sugar", category: .pantry, quantity: "1 tsp"),
                Ingredient(name: "Cooked rice", category: .pantry, quantity: "500 g"),
                Ingredient(name: "豆腐", category: .proteins, quantity: "200 g silken, optional")
            ],
            steps: [
                "Blanch spinach 30 seconds; squeeze dry and chop.",
                "Toast ごま; crush into a paste with 醤油 and sugar.",
                "Fold through spinach. Add silken 豆腐 if you want more supper.",
                "Eat with a wide bowl of rice — this is the meal, not a garnish."
            ],
            foreignName: "ほうれん草の胡麻和え定食",
            vegetarian: true,
            glutenFree: true,
            leftoverHints: ["Spinach", "Cooked rice"]
        )
    ]

    static func recipe(id: String) -> Recipe? {
        recipes.first { $0.id == id }
    }

    static func englishName(for ingredient: String) -> String? {
        decoderEntries.first { matches($0, ingredient: ingredient) }?.english
            ?? lookup(legacyEnglish, ingredient)
    }

    static func substitution(for ingredient: String) -> String? {
        decoderEntries.first { matches($0, ingredient: ingredient) }?.substitution
            ?? lookup(legacySubs, ingredient)
    }

    static func entry(for ingredient: String) -> DecoderEntry? {
        decoderEntries.first { matches($0, ingredient: ingredient) }
    }

    static func recipesContaining(_ entry: DecoderEntry) -> [Recipe] {
        recipes.filter { recipe in
            recipe.ingredients.contains { ingredient in
                matches(entry, ingredient: ingredient.name)
            }
        }
    }

    static func expandKeys(_ name: String) -> Set<String> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var keys: Set<String> = []
        let lowered = trimmed.lowercased()
        keys.insert(lowered)
        let stripped = lowered
            .replacingOccurrences(of: "leftover ", with: "")
            .replacingOccurrences(of: "cooked ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !stripped.isEmpty { keys.insert(stripped) }
        if let entry = entry(for: trimmed) {
            keys.insert(entry.native.lowercased())
            keys.insert(entry.english.lowercased())
        }
        return keys
    }

    static func namesOverlap(_ lhs: String, _ rhs: String) -> Bool {
        !expandKeys(lhs).isDisjoint(with: expandKeys(rhs))
    }

    private static func matches(_ entry: DecoderEntry, ingredient: String) -> Bool {
        let key = ingredient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if key == entry.native.lowercased() || key == entry.english.lowercased() { return true }
        if key.contains(entry.native.lowercased()) { return true }
        let english = entry.english.lowercased()
        if key == english { return true }
        if key.contains(english) && english.count > 3 { return true }
        return false
    }

    private static func lookup(_ table: [String: String], _ ingredient: String) -> String? {
        let key = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = table[key] { return exact }
        let lowered = key.lowercased()
        return table.first { $0.key.lowercased() == lowered }?.value
    }

    private static let legacyEnglish: [String: String] = [:]
    private static let legacySubs: [String: String] = [:]
}
