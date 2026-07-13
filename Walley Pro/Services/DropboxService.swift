import Foundation

enum DropboxError: LocalizedError {
    case invalidToken
    case pathNotFound
    case networkError(Error)
    case decodingError(Error)
    case rateLimited
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid Dropbox API token. Please check your token in Constants.swift."
        case .pathNotFound:
            return "The specified Dropbox folder was not found."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .rateLimited:
            return "Rate limited by Dropbox. Please try again later."
        case .unknown(let message):
            return message
        }
    }
}

class DropboxService {
    static let shared = DropboxService()
    private let session = URLSession.shared

    private init() {}

    private func makeRequest(endpoint: String, body: [String: Any]) throws -> URLRequest {
        guard Constants.dropboxToken != "YOUR_DROPBOX_API_TOKEN_HERE" else {
            throw DropboxError.invalidToken
        }

        guard let url = URL(string: "\(Constants.apiBaseURL)/\(endpoint)") else {
            throw DropboxError.unknown("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.dropboxToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    func fetchCategories() async throws -> [WallpaperCategory] {
        let request = try makeRequest(
            endpoint: "files/list_folder",
            body: ["path": Constants.dropboxRootPath]
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DropboxError.unknown("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw DropboxError.invalidToken
        case 404:
            throw DropboxError.pathNotFound
        case 429:
            throw DropboxError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw DropboxError.unknown("HTTP \(httpResponse.statusCode): \(body)")
        }

        do {
            let listResponse = try JSONDecoder().decode(ListFolderResponse.self, from: data)
            let folders = listResponse.entries.filter { $0.tag == "folder" }

            var categories: [WallpaperCategory] = []
            for folder in folders {
                let wallpapers = try await fetchWallpapers(in: folder.pathLower)
                let category = WallpaperCategory(
                    id: folder.id ?? folder.pathLower,
                    name: folder.name,
                    pathLower: folder.pathLower,
                    wallpapers: wallpapers
                )
                categories.append(category)
            }

            return categories
        } catch let error as DropboxError {
            throw error
        } catch {
            throw DropboxError.decodingError(error)
        }
    }

    func fetchWallpapers(in folderPath: String) async throws -> [Wallpaper] {
        let request = try makeRequest(
            endpoint: "files/list_folder",
            body: ["path": folderPath]
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DropboxError.unknown("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw DropboxError.invalidToken
        case 404:
            return []
        case 429:
            throw DropboxError.rateLimited
        default:
            return []
        }

        do {
            let listResponse = try JSONDecoder().decode(ListFolderResponse.self, from: data)
            let imageFiles = listResponse.entries.filter { entry in
                entry.tag == "file" && isImageFile(entry.name)
            }

            return imageFiles.map { entry in
                Wallpaper(
                    id: entry.id ?? entry.pathLower,
                    name: entry.name,
                    pathLower: entry.pathLower,
                    temporaryLink: nil,
                    size: entry.size,
                    clientModified: entry.clientModified
                )
            }
        } catch {
            throw DropboxError.decodingError(error)
        }
    }

    func getTemporaryLink(for path: String) async throws -> String {
        let request = try makeRequest(
            endpoint: "files/get_temporary_link",
            body: ["path": path]
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DropboxError.unknown("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw DropboxError.invalidToken
        case 429:
            throw DropboxError.rateLimited
        default:
            throw DropboxError.unknown("HTTP \(httpResponse.statusCode)")
        }

        let linkResponse = try JSONDecoder().decode(TemporaryLinkResponse.self, from: data)
        return linkResponse.link
    }

    private func isImageFile(_ filename: String) -> Bool {
        let ext = (filename as NSString).pathExtension.lowercased()
        return Constants.imageExtensions.contains(ext)
    }
}
