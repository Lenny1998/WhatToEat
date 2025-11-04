import SwiftUI

struct AllDishesView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.openURL) private var openURL
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { dish in
                    Button {
                        openXiaohongshu(for: dish)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            DishImageView(url: dish.imageURL, style: .list)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(dish.name)
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                        .underline()
                                    Spacer()
                                }
                                Text("标签: \(dish.tags.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $search)
            .navigationTitle("全部菜品")
            .toolbar { EditButton() }
        }
    }

    private var filtered: [Dish] {
        if search.isEmpty { return state.allDishes }
        return state.allDishes.filter { dish in
            dish.name.localizedCaseInsensitiveContains(search) ||
            dish.tags.contains(where: { $0.localizedCaseInsensitiveContains(search) })
        }
    }

    private func delete(at offsets: IndexSet) {
        state.allDishes.remove(atOffsets: offsets)
    }

    private func openXiaohongshu(for dish: Dish) {
        guard let url = dish.xiaohongshuSearchURL else { return }
        openURL(url)
    }
}
