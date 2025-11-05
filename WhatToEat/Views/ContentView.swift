import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @State private var filter = Filter()
    @State private var current: Dish?
    @State private var showingAll = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FilterBar(filter: $filter)
                Button(action: { current = state.roll(with: filter) }) {
                    Text("今天吃什么？🎲 随机一下")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                if let current {
                    ResultCard(dish: current)
                        .transition(.opacity)
                } else {
                    Text("点上面的按钮开始吧～")
                        .foregroundStyle(.secondary)
                }

                HistorySection()
            }
            .padding()
            .navigationTitle("今天吃点啥")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showingAdd.toggle() } label: { Image(systemName: "plus") }
                    Button { showingAll.toggle() } label: { Image(systemName: "list.bullet") }
                }
            }
            .sheet(isPresented: $showingAll) {
                AllDishesView()
                    .environmentObject(state)
            }
            .sheet(isPresented: $showingAdd) {
                AddDishView { newDish in
                    state.addDish(newDish)
                }
            }
        }
    }
}

struct FilterBar: View {
    @Binding var filter: Filter

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("关键词（如：辣/米饭/奶酪）", text: $filter.keyword)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct ResultCard: View {
    @Environment(\.openURL) private var openURL
    let dish: Dish

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DishImageView(url: dish.imageURL, style: .card)
            HStack {
                Button {
                    guard let url = dish.xiaohongshuSearchURL else { return }
                    openURL(url)
                } label: {
                    Text(dish.name)
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                        .underline()
                }
                .buttonStyle(.plain)
                Spacer()
            }
            Wrap(tags: dish.tags)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HistorySection: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("历史记录").font(.headline)
                Spacer()
                if !state.history.isEmpty {
                    Button("清空") { state.history.removeAll() }
                }
            }
            if state.history.isEmpty {
                Text("暂无记录").foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(state.history.prefix(12)) { dish in
                            Chip(title: dish.name)
                        }
                    }
                }
            }
        }
    }
}
