import Combine
import Foundation
import Photos
import SwiftUI

@MainActor
class WallpaperDetailViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var isDownloading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""

    private let imageCache = ImageCache.shared
    private let photoLibraryManager = PhotoLibraryManager.shared
    private let dropboxService = DropboxService.shared

    func loadImage(for wallpaper: Wallpaper) async {
        guard let urlString = wallpaper.temporaryLink else {
            isLoading = true
            do {
                let link = try await dropboxService.getTemporaryLink(for: wallpaper.pathLower)
                isLoading = false
                await loadFromURL(link)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
            return
        }

        await loadFromURL(urlString)
    }

    private func loadFromURL(_ urlString: String) async {
        if let cached = imageCache.image(for: urlString) {
            image = cached
            return
        }

        isLoading = true
        do {
            let loadedImage = try await imageCache.loadImage(from: urlString)
            image = loadedImage
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func downloadAndSave(wallpaper: Wallpaper) async {
        isDownloading = true

        do {
            var urlString = wallpaper.temporaryLink
            if urlString == nil {
                urlString = try await dropboxService.getTemporaryLink(for: wallpaper.pathLower)
            }

            guard let finalURLString = urlString, let url = URL(string: finalURLString) else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(from: url)

            guard let downloadedImage = UIImage(data: data) else {
                throw PhotoLibraryError.imageConversionFailed
            }

            try await photoLibraryManager.saveImage(downloadedImage)

            successMessage = "\"\(wallpaper.name)\" saved to Photos"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isDownloading = false
    }

    func shareImage(from wallpaper: Wallpaper) -> [Any] {
        if let image = image {
            return [image]
        }
        return []
    }
}
