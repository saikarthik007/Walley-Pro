import Foundation

struct Wallpaper: Identifiable, Hashable {
    let id: String
    let name: String
    let pathLower: String
    var temporaryLink: String?
    let size: Int?
    let clientModified: String?

    static func == (lhs: Wallpaper, rhs: Wallpaper) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
