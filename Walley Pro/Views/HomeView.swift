import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingCategoryView()
                } else if viewModel.categories.isEmpty {
                    EmptyStateView(
                        title: "No Categories",
                        message: "Add folders to your Dropbox path to see wallpaper categories here.",
                        systemImage: "folder.badge.questionmark"
                    )
                } else {
                    categoryGrid
                }
            }
            .navigationTitle("Wallpapers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.loadCategories()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.loadCategories()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Retry") {
                    Task { await viewModel.loadCategories() }
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
            .task {
                await viewModel.loadCategories()
                await loadTemporaryLinks()
            }
        }
    }

    private var categoryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(destination: CategoryView(viewModel: viewModel, categoryId: category.id)) {
                        CategoryCard(category: category, size: CGSize(width: 170, height: 200))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func loadTemporaryLinks() async {
        for category in viewModel.categories {
            await viewModel.loadTemporaryLinks(forCategoryId: category.id)
        }
    }
}
