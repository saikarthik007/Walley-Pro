import SwiftUI

struct WallpaperDetailView: View {
    let wallpaper: Wallpaper
    @StateObject private var viewModel = WallpaperDetailViewModel()
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
            } else if let image = viewModel.image {
                imageView(image)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Failed to load image")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            if viewModel.isDownloading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Saving...")
                    .tint(.white)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
                .disabled(viewModel.image == nil)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.image {
                ShareSheet(items: [image])
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .alert("Saved!", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.successMessage)
        }
        .task {
            await viewModel.loadImage(for: wallpaper)
        }
    }

    private func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .pinchToZoom()
            .overlay(alignment: .bottom) {
                actionButtons
                    .padding(.bottom, 20)
            }
    }

    private var actionButtons: some View {
        HStack(spacing: 40) {
            Button {
                Task {
                    await viewModel.downloadAndSave(wallpaper: wallpaper)
                }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 32))
                    Text("Save")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            .disabled(viewModel.isDownloading)

            Button {
                showShareSheet = true
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 32))
                    Text("Share")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PinchToZoom: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { newScale in
                        scale = lastScale * newScale
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3)) {
                            if scale < 1.0 {
                                scale = 1.0
                            } else if scale > 5.0 {
                                scale = 5.0
                            }
                            lastScale = scale
                        }
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring(response: 0.3)) {
                    if scale > 1.0 {
                        scale = 1.0
                        lastScale = 1.0
                    } else {
                        scale = 2.0
                        lastScale = 2.0
                    }
                }
            }
    }
}

extension View {
    func pinchToZoom() -> some View {
        modifier(PinchToZoom())
    }
}
