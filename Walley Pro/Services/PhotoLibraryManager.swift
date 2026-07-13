import Photos
import UIKit

enum PhotoLibraryError: LocalizedError {
    case denied
    case restricted
    case saveFailed(Error)
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Photo library access denied. Please enable it in Settings."
        case .restricted:
            return "Photo library access restricted."
        case .saveFailed(let error):
            return "Failed to save image: \(error.localizedDescription)"
        case .imageConversionFailed:
            return "Failed to convert image for saving."
        }
    }
}

class PhotoLibraryManager {
    static let shared = PhotoLibraryManager()

    private init() {}

    func requestPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func saveImage(_ image: UIImage) async throws {
        let hasPermission = await requestPermission()
        guard hasPermission else {
            throw PhotoLibraryError.denied
        }

        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(error))
                } else {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(
                        NSError(domain: "PhotoLibrary", code: -1)
                    ))
                }
            }
        }
    }
}
