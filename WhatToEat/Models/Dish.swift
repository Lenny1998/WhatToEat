import Foundation

struct Dish: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var tags: [String]
    var imageURL: URL?

    init(id: UUID = UUID(), name: String, tags: [String] = [], imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.tags = tags
        self.imageURL = imageURL
    }

    var xiaohongshuSearchURL: URL? {
        var components = URLComponents(string: "https://www.xiaohongshu.com/search_result")
        components?.queryItems = [URLQueryItem(name: "keyword", value: name)]
        return components?.url
    }
}

struct Seed {
    static let dishes: [Dish] = [
        .init(name: "麻婆豆腐", tags: ["辣", "中餐"], imageURL: URL(string: "https://i.ytimg.com/vi/JDRlmbk7YOI/maxresdefault.jpg")),
        .init(name: "宫保鸡丁", tags: ["下饭", "中餐"], imageURL: URL(string: "https://images.unsplash.com/photo-1604908177522-4023acbdef0c")),
        .init(name: "玛格丽特披萨", tags: ["奶酪", "意式"], imageURL: URL(string: "https://images.unsplash.com/photo-1548365328-5473d2fb0fc8")),
        .init(name: "沙拉碗", tags: ["清淡", "美式"], imageURL: URL(string: "https://images.unsplash.com/photo-1498837167922-ddd27525d352")),
        .init(name: "咖喱饭", tags: ["咖喱", "日式"], imageURL: URL(string: "https://images.unsplash.com/photo-1551183053-bf91a1d81141")),
        .init(name: "牛肉饭", tags: ["快餐", "日式"], imageURL: URL(string: "https://images.unsplash.com/photo-1478144592103-25e218a04891")),
        .init(name: "泰式冬阴功", tags: ["酸辣", "东南亚"], imageURL: URL(string: "https://images.unsplash.com/photo-1567157743317-934d0e53d3c1")),
        .init(name: "越南河粉", tags: ["米粉", "东南亚"], imageURL: URL(string: "https://images.unsplash.com/photo-1533777419517-3e4017e2e9ac"))
    ]
}
