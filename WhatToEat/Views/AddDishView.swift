import SwiftUI

struct AddDishView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var tagsText = ""
    @State private var imageURLText = ""

    var onSave: (Dish) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("基础信息") {
                    TextField("菜名（必填）", text: $name)
                    TextField("图片 URL（可选）", text: $imageURLText)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                }
                Section("标签") {
                    TextField("逗号分隔：辣,米饭,奶酪", text: $tagsText)
                }
            }
            .navigationTitle("添加菜品")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let trimmedImage = imageURLText.trimmingCharacters(in: .whitespacesAndNewlines)
                        let imageURL = trimmedImage.isEmpty ? nil : URL(string: trimmedImage)

                        let dish = Dish(
                            name: name.isEmpty ? "未命名菜品" : name,
                            tags: tags,
                            imageURL: imageURL
                        )
                        onSave(dish)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
