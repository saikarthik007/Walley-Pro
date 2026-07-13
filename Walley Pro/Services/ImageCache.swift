import SwiftUI

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks: [String: Task<UIImage, Error>] = [:]
    private let lock = NSLock()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024
    }

    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }

    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }

    func loadImage(from urlString: String) async throws -> UIImage {
        if let cached = image(for: urlString) {
            return cached
        }

        lock.lock()
        if let existingTask = activeTasks[urlString] {
            lock.unlock()
            return try await existingTask.value
        }

        let task = Task<UIImage, Error> {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(from: url)

            guard let downloadedImage = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            ImageCache.shared.setImage(downloadedImage, for: urlString)
            return downloadedImage
        }

        activeTasks[urlString] = task
        lock.unlock()

        do {
            let result = try await task.value
            lock.lock()
            activeTasks.removeValue(forKey: urlString)
            lock.unlock()
            return result
        } catch {
            lock.lock()
            activeTasks.removeValue(forKey: urlString)
            lock.unlock()
            throw error
        }
    }

    func clearCache() {
        cache.removeAllObjects()
        lock.lock()
        activeTasks.removeAll()
        lock.unlock()
    }
}
