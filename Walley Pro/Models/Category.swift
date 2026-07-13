import Foundation

struct WallpaperCategory: Identifiable {
    let id: String
    let name: String
    let pathLower: String
    var wallpapers: [Wallpaper]
    var previewWallpaper: Wallpaper? {
        wallpapers.first
    }

    static func == (lhs: WallpaperCategory, rhs: WallpaperCategory) -> Bool {
        lhs.id == rhs.id
    }
}
