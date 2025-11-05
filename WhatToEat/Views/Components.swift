import SwiftUI

struct Chip: View {
    let title: String

    var body: some View {
        Text(title)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
            .foregroundStyle(isSelected ? Color.blue : Color.primary)
            .clipShape(Capsule())
    }
}

struct DishImageView: View {
    enum Style {
        case card
        case list
    }

    let url: URL?
    var style: Style = .card

    private var cornerRadius: CGFloat {
        switch style {
        case .card:
            return 16
        case .list:
            return 12
        }
    }

    private var frameWidth: CGFloat? {
        switch style {
        case .card:
            return nil
        case .list:
            return 72
        }
    }

    private var frameHeight: CGFloat {
        switch style {
        case .card:
            return 180
        case .list:
            return 72
        }
    }

    var body: some View {
        let placeholder = ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.1))
            Image(systemName: "photo")
                .foregroundStyle(.gray)
        }

        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        placeholder.overlay(ProgressView())
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .frame(maxWidth: style == .card ? .infinity : nil, alignment: .leading)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct Wrap: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading) {
            if tags.isEmpty {
                EmptyView()
            } else {
                FlowLayout(tags) { Chip(title: $0) }
            }
        }
    }
}

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

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item == data.last {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == data.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    totalHeight = geo.size.height
                }
                return .clear
            }
        )
    }
}
