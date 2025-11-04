import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var allDishes: [Dish] = Seed.dishes
    @Published var history: [Dish] = []
    @Published var favorites: Set<Dish> = []

    func roll(with filter: Filter) -> Dish? {
        let filtered = allDishes.filter { dish in
            filter.keyword.isEmpty ||
            dish.name.contains(filter.keyword) ||
            dish.tags.contains(where: { $0.contains(filter.keyword) })
        }
        guard let pick = filtered.randomElement() else { return nil }
        history.insert(pick, at: 0)
        return pick
    }

    func addDish(_ dish: Dish) {
        allDishes.insert(dish, at: 0)
    }
}

struct Filter {
    var keyword: String = ""
}
