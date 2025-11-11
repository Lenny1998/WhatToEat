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
        .init(name: "肥牛饭", tags: ["快餐", "日式"], imageURL: URL(string: "https://i3.meishichina.com/atta/recipe/2017/09/17/2017091715056277922246793799.jpg?x-oss-process=style/p800")),
        .init(name: "照烧鸡腿饭", tags: ["快餐", "日式"], imageURL: URL(string: "https://www.onceuponachef.com/images/2024/01/chicken-teriyaki.jpg")),
        .init(name: "爆炒鱿鱼", tags: ["辣", "中餐"], imageURL: URL(string: "https://q7.itc.cn/images01/20250314/8a01694391ac45ca89fdadb80622e3a7.jpeg")),
        .init(name: "西红柿鸡蛋面", tags: ["中餐"], imageURL: URL(string: "https://i.ytimg.com/vi/WhpDt5LA184/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBX94_I3kfkeIn62EXj410f-vfsFg")),
        .init(name: "黑椒牛柳", tags: ["辣", "中餐"], imageURL: URL(string: "https://imgs.gvm.com.tw/upload/gallery/health/65453_01.jpg")),
        .init(name: "煲仔饭", tags: ["中餐"], imageURL: URL(string: "https://pic2.zhimg.com/v2-abd2adf1a21ec77d775954865bf9a37b_1440w.jpg")),
    ]
}
