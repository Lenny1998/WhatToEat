import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var allDishes: [Dish] = Seed.dishes
    @Published var history: [Dish] = []
    @Published var favorites: Set<Dish> = []

    var allTags: [String] {
        let unique = Set(allDishes.flatMap { $0.tags })
        return unique.sorted()
    }

    func roll(with filter: Filter) -> Dish? {
        let filtered = dishes(matching: filter)
        guard let pick = filtered.randomElement() else { return nil }
        history.insert(pick, at: 0)
        return pick
    }

    func addDish(_ dish: Dish) {
        allDishes.insert(dish, at: 0)
    }

    func dishes(matching filter: Filter) -> [Dish] {
        allDishes.filter { matches($0, with: filter) }
    }

    private func matches(_ dish: Dish, with filter: Filter) -> Bool {
        let keyword = filter.keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let matchesKeyword = keyword.isEmpty ||
            dish.name.localizedCaseInsensitiveContains(keyword) ||
            dish.tags.contains { $0.localizedCaseInsensitiveContains(keyword) }

        if !matchesKeyword { return false }

        if filter.selectedTags.isEmpty { return true }
        let dishTags = Set(dish.tags)
        return filter.selectedTags.isSubset(of: dishTags)
    }
}

struct Filter {
    var keyword: String = ""
    var selectedTags: Set<String> = []
}
