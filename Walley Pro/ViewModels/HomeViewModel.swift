import Combine
import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [WallpaperCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let dropboxService = DropboxService.shared

    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await dropboxService.fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func loadTemporaryLinks(forCategoryId categoryId: String) async {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }

        var updatedCategory = categories[index]
        let pendingIndices = updatedCategory.wallpapers.indices.filter {
            updatedCategory.wallpapers[$0].temporaryLink == nil
        }

        guard !pendingIndices.isEmpty else { return }

        await withTaskGroup(of: (Int, String?).self) { group in
            for wallpaperIndex in pendingIndices {
                let wallpaper = updatedCategory.wallpapers[wallpaperIndex]
                group.addTask {
                    do {
                        let link = try await self.dropboxService.getTemporaryLink(for: wallpaper.pathLower)
                        return (wallpaperIndex, link)
                    } catch {
                        print("Failed to get link for \(wallpaper.name): \(error)")
                        return (wallpaperIndex, nil)
                    }
                }
            }

            for await (wallpaperIndex, link) in group {
                guard let link else { continue }
                updatedCategory.wallpapers[wallpaperIndex].temporaryLink = link
                categories[index] = updatedCategory
            }
        }
    }
}
