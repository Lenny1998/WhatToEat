import SwiftUI

struct AllDishesView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.openURL) private var openURL
    @Binding var filter: Filter
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List {
                if !state.allTags.isEmpty {
                    Section("标签筛选") {
                        FlowLayout(state.allTags) { tag in
                            let isSelected = filter.selectedTags.contains(tag)
                            Button {
                                if isSelected {
                                    filter.selectedTags.remove(tag)
                                } else {
                                    filter.selectedTags.insert(tag)
                                }
                            } label: {
                                SelectableChip(title: tag, isSelected: isSelected)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                ForEach(filtered) { dish in
                    Button {
                        openDishLink(for: dish)
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
        let base = state.dishes(matching: filter)
        guard !search.isEmpty else { return base }
        return base.filter { dish in
            dish.name.localizedCaseInsensitiveContains(search) ||
            dish.tags.contains(where: { $0.localizedCaseInsensitiveContains(search) })
        }
    }

    private func delete(at offsets: IndexSet) {
        state.allDishes.remove(atOffsets: offsets)
    }

    private func openDishLink(for dish: Dish) {
        guard let url = dish.xiaohongshuSearchURL else { return }
        openURL(url)
    }
}
