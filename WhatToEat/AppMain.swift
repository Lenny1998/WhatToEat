import SwiftUI
import Combine

// MARK: - Domain Model
struct Dish: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var cuisine: String
    var tags: [String]
    init(id: UUID = UUID(), name: String, cuisine: String, tags: [String] = []) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.tags = tags
    }

    var xiaohongshuSearchURL: URL? {
        var components = URLComponents(string: "https://www.xiaohongshu.com/search_result")
        components?.queryItems = [URLQueryItem(name: "keyword", value: name)]
        return components?.url
    }
}

// MARK: - In‑memory Seed Data (replace later with persistence)
struct Seed {
    static let dishes: [Dish] = [
        .init(name: "豚骨拉面", cuisine: "日式", tags: ["面", "汤"]),
        .init(name: "寿司套餐", cuisine: "日式", tags: ["米饭", "生食"]),
        .init(name: "麻婆豆腐", cuisine: "中餐", tags: ["辣"]),
        .init(name: "宫保鸡丁", cuisine: "中餐", tags: ["下饭"]),
        .init(name: "玛格丽特披萨", cuisine: "意式", tags: ["奶酪"]),
        .init(name: "沙拉碗", cuisine: "美式", tags: ["清淡"]),
        .init(name: "咖喱饭", cuisine: "日式", tags: ["咖喱"]),
        .init(name: "牛肉饭", cuisine: "日式", tags: ["快餐"]),
        .init(name: "泰式冬阴功", cuisine: "东南亚", tags: ["酸辣"]),
        .init(name: "越南河粉", cuisine: "东南亚", tags: ["米粉"])
    ]
}

// MARK: - App State
final class AppState: ObservableObject {
    @Published var allDishes: [Dish] = Seed.dishes
    @Published var history: [Dish] = []
    @Published var favorites: Set<Dish> = []

    func roll(with filter: Filter) -> Dish? {
        let filtered = allDishes.filter { d in
            (filter.cuisine == "全部" || d.cuisine == filter.cuisine) &&
            (filter.keyword.isEmpty || d.name.contains(filter.keyword) || d.tags.contains(where: { $0.contains(filter.keyword) }))
        }
        guard let pick = filtered.randomElement() else { return nil }
        history.insert(pick, at: 0)
        return pick
    }

    func addDish(_ dish: Dish) {
        allDishes.insert(dish, at: 0)
    }
}

// MARK: - Filter State
struct Filter {
    var cuisine: String = "全部"
    var keyword: String = ""
}

// MARK: - Root App
@main
struct WhatToEatApp: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
        }
    }
}

// MARK: - Main Content
struct ContentView: View {
    @EnvironmentObject var state: AppState
    @State private var filter = Filter()
    @State private var current: Dish?
    @State private var showingAll = false
    @State private var showingAdd = false

    private var cuisines: [String] {
        let uniques = Set(state.allDishes.map { $0.cuisine })
        return ["全部"] + uniques.sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FilterBar(filter: $filter, cuisines: cuisines)
                Button(action: { current = state.roll(with: filter) }) {
                    Text("今天吃什么？🎲 随机一下")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                if let current = current {
                    ResultCard(dish: current)
                        .transition(.opacity)
                } else {
                    Text("点上面的按钮开始吧～")
                        .foregroundStyle(.secondary)
                }

                HistorySection()
            }
            .padding()
            .navigationTitle("吃啥")
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


// MARK: - UI Pieces
struct FilterBar: View {
    @Binding var filter: Filter
    let cuisines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Picker("菜系", selection: $filter.cuisine) {
                    ForEach(cuisines, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
            }
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
            HStack(spacing: 8) {
                Label(dish.cuisine, systemImage: "fork.knife")
            }
            .foregroundStyle(.secondary)
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
                        ForEach(state.history.prefix(12)) { d in
                            Chip(title: d.name)
                        }
                    }
                }
            }
        }
    }
}

struct AllDishesView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.openURL) private var openURL
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { d in
                    Button {
                        openXiaohongshu(for: d)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(d.name)
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                    .underline()
                                Spacer()
                            }
                            Text("\(d.cuisine) · 标签: \(d.tags.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
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

    var filtered: [Dish] {
        if search.isEmpty { return state.allDishes }
        return state.allDishes.filter { d in
            d.name.localizedCaseInsensitiveContains(search) ||
            d.cuisine.localizedCaseInsensitiveContains(search) ||
            d.tags.contains(where: { $0.localizedCaseInsensitiveContains(search) })
        }
    }

    func delete(at offsets: IndexSet) {
        state.allDishes.remove(atOffsets: offsets)
    }

    private func openXiaohongshu(for dish: Dish) {
        guard let url = dish.xiaohongshuSearchURL else { return }
        openURL(url)
    }
}

// MARK: - Add Dish
struct AddDishView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var cuisine = "日式"
    @State private var tagsText = ""

    var onSave: (Dish) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("基础信息") {
                    TextField("菜名（必填）", text: $name)
                    TextField("菜系（如：日式/中餐/意式）", text: $cuisine)
                }
                Section("标签") {
                    TextField("逗号分隔：辣,米饭,奶酪", text: $tagsText)
                }
            }
            .navigationTitle("添加菜品")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let dish = Dish(name: name.isEmpty ? "未命名菜品" : name,
                                        cuisine: cuisine.isEmpty ? "其他" : cuisine,
                                        tags: tags)
                        onSave(dish)
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Small UI Helpers
struct Chip: View { let title: String; var body: some View { Text(title).padding(.horizontal, 10).padding(.vertical, 6).background(Color.gray.opacity(0.15)).clipShape(Capsule()) } }

struct Wrap: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading) {
            if tags.isEmpty { EmptyView() } else {
                FlowLayout(tags) { Chip(title: $0) }
            }
        }
    }
}

// A simple flow layout for tags
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let data: Data
    private let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == data.last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == data.last { height = 0 } else {}
                        return result
                    }
            }
        }
        .background(GeometryReader { geo -> Color in
            DispatchQueue.main.async { totalHeight = geo.size.height }
            return .clear
        })
    }
}
