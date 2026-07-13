import SwiftUI

struct CategoryView: View {
    @ObservedObject var viewModel: HomeViewModel
    let categoryId: String

    private var category: WallpaperCategory? {
        viewModel.categories.first { $0.id == categoryId }
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]
    }

    var body: some View {
        Group {
            if let category {
                categoryContent(category)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(category?.name ?? "Category")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: categoryId) {
            await viewModel.loadTemporaryLinks(forCategoryId: categoryId)
        }
    }

    @ViewBuilder
    private func categoryContent(_ category: WallpaperCategory) -> some View {
        ScrollView {
            if category.wallpapers.isEmpty {
                EmptyStateView(
                    title: "No Wallpapers",
                    message: "This category doesn't have any wallpapers yet.",
                    systemImage: "photo.badge.plus"
                )
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(category.wallpapers) { wallpaper in
                        NavigationLink(destination: WallpaperDetailView(wallpaper: wallpaper)) {
                            WallpaperCard(
                                wallpaper: wallpaper,
                                size: CGSize(
                                    width: UIScreen.main.bounds.width / 3 - 12,
                                    height: UIScreen.main.bounds.width / 3 * 1.4
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }
        }
    }
}
