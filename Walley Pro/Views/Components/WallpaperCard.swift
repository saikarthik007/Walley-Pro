import SwiftUI

struct CachedRemoteImage: View {
    let urlString: String
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if failed {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: urlString) {
            failed = false
            image = ImageCache.shared.image(for: urlString)

            guard image == nil else { return }

            do {
                image = try await ImageCache.shared.loadImage(from: urlString)
            } catch {
                failed = true
            }
        }
    }
}

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let size: CGSize

    var body: some View {
        Group {
            if let urlString = wallpaper.temporaryLink {
                CachedRemoteImage(urlString: urlString, contentMode: .fill)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray5))
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

struct CategoryCard: View {
    let category: WallpaperCategory
    let size: CGSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let preview = category.previewWallpaper,
               let urlString = preview.temporaryLink {
                CachedRemoteImage(urlString: urlString, contentMode: .fill)
            } else {
                gradientPlaceholder
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("\(category.wallpapers.count) wallpapers")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(12)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
        )
    }
}
