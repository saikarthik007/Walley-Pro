import Foundation

struct ListFolderResponse: Codable {
    let entries: [DropboxEntry]
    let cursor: String?
    let hasMore: Bool?

    enum CodingKeys: String, CodingKey {
        case entries
        case cursor
        case hasMore = "has_more"
    }
}

struct DropboxEntry: Codable {
    let tag: String
    let name: String
    let pathLower: String
    let pathDisplay: String?
    let id: String?
    let size: Int?
    let isDownloadable: Bool?
    let clientModified: String?
    let serverModified: String?

    enum CodingKeys: String, CodingKey {
        case tag = ".tag"
        case name
        case pathLower = "path_lower"
        case pathDisplay = "path_display"
        case id
        case size
        case isDownloadable = "is_downloadable"
        case clientModified = "client_modified"
        case serverModified = "server_modified"
    }
}

struct TemporaryLinkResponse: Codable {
    let link: String
    let metadata: DropboxEntry
}
