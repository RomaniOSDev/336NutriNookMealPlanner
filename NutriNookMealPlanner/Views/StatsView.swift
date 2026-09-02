import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 18) {
                    summaryRow
                    weekChart
                    cuisineChart
                    marketChart
                    minutesChart
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .kitchenCanvas()
    }

    private var header: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(Theme.rounded(.body, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text("Kitchen Stats")
                .font(Theme.rounded(.headline, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
            Color.clear.frame(width: 52, height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    private var summaryRow: some View {
        HStack(spacing: 10) {
            summaryPlate(value: "\(store.favorites.count)", label: "Saved")
            summaryPlate(value: "\(store.groceryItems.filter(\.acquired).count)/\(max(store.groceryItems.count, 1))", label: "Market")
            summaryPlate(value: "\(totalCooks)", label: "Cooks")
        }
    }

    private func summaryPlate(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(Theme.rounded(.title3, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(Theme.rounded(.caption, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppSurface").opacity(0.94))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
        }
        .cheapPlateShadow()
    }

    private var weekChart: some View {
        chartCard(title: "This week at the stove") {
            Chart(weekSeries) { row in
                AreaMark(
                    x: .value("Day", row.label),
                    y: .value("Actions", row.actions)
                )
                .foregroundStyle(Color("AppPrimary").opacity(0.22))
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Day", row.label),
                    y: .value("Actions", row.actions)
                )
                .foregroundStyle(Color("AppPrimary"))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                PointMark(
                    x: .value("Day", row.label),
                    y: .value("Actions", row.actions)
                )
                .foregroundStyle(Color("AppAccent"))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(Theme.rounded(.caption2, weight: .semibold))
                        }
                    }
                }
            }
            .frame(height: 180)
        }
    }

    private var cuisineChart: some View {
        chartCard(title: cuisineChartTitle) {
            Chart(cuisineSeries) { row in
                BarMark(
                    x: .value("Cuisine", row.label),
                    y: .value("Count", row.value)
                )
                .foregroundStyle(Color("AppPrimary"))
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(Theme.rounded(.caption2, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
            .frame(height: 180)
        }
    }

    private var marketChart: some View {
        chartCard(title: "Market aisles") {
            if store.groceryItems.isEmpty {
                chartPlaceholder("Add items from a recipe or the plus plate.")
            } else {
                Chart {
                    ForEach(marketSeries) { row in
                        BarMark(
                            x: .value("Aisle", row.label),
                            y: .value("Count", row.value)
                        )
                        .foregroundStyle(by: .value("State", row.series))
                        .cornerRadius(5)
                    }
                }
                .chartForegroundStyleScale([
                    "In basket": Color("AppAccent"),
                    "Still need": Color("AppPrimary")
                ])
                .chartLegend(position: .bottom, alignment: .leading)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(Theme.rounded(.caption2, weight: .semibold))
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }

    private var minutesChart: some View {
        chartCard(title: "Stove minutes this week") {
            Chart(weekSeries) { row in
                BarMark(
                    x: .value("Day", row.label),
                    y: .value("Minutes", row.minutes)
                )
                .foregroundStyle(Color("AppPrimary"))
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 180)
        }
    }

    private func chartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.rounded(.headline, weight: .bold))
                .foregroundStyle(.primary)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface").opacity(0.94))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
        }
        .cheapPlateShadow()
    }

    private func chartPlaceholder(_ message: String) -> some View {
        Text(message)
            .font(Theme.rounded(.subheadline, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 120)
            .multilineTextAlignment(.center)
    }

    private var totalCooks: Int {
        store.dayLogs.reduce(0) { $0 + $1.cooks }
    }

    private var cuisineChartTitle: String {
        store.favorites.isEmpty ? "Recipe shelf by cuisine" : "Saved clippings by cuisine"
    }

    private var weekSeries: [StatBar] {
        let calendar = Calendar.current
        let weekday = DateFormatter()
        weekday.locale = .current
        weekday.setLocalizedDateFormatFromTemplate("EE")
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { index in
            let offset = index - 6
            let day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            let log = store.dayLogs.first { $0.day == Store.dayStamp(day) }
            return StatBar(
                id: Store.dayStamp(day),
                label: weekday.string(from: day),
                value: Double((log?.saved ?? 0) + (log?.checks ?? 0) + (log?.cooks ?? 0)),
                series: "Actions",
                minutes: Double(log?.minutes ?? 0)
            )
        }
    }

    private var cuisineSeries: [StatBar] {
        let source: [Recipe]
        if store.favorites.isEmpty {
            source = RecipeCatalog.recipes
        } else {
            source = store.favorites.compactMap { RecipeCatalog.recipe(id: $0) }
        }
        return Cuisine.allCases.map { cuisine in
            StatBar(
                id: cuisine.rawValue,
                label: cuisine.rawValue,
                value: Double(source.filter { $0.cuisine == cuisine }.count),
                series: "Cuisine"
            )
        }
    }

    private var marketSeries: [StatBar] {
        IngredientCategory.allCases.flatMap { category -> [StatBar] in
            let items = store.items(in: category)
            return [
                StatBar(
                    id: "\(category.rawValue)-need",
                    label: category.rawValue,
                    value: Double(items.filter { !$0.acquired }.count),
                    series: "Still need"
                ),
                StatBar(
                    id: "\(category.rawValue)-got",
                    label: category.rawValue,
                    value: Double(items.filter(\.acquired).count),
                    series: "In basket"
                )
            ]
        }
    }
}

private struct StatBar: Identifiable {
    var id: String
    var label: String
    var value: Double
    var series: String
    var minutes: Double = 0
    var actions: Double { value }
}
