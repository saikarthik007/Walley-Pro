import SwiftUI

struct SettingsView: View {
    @AppStorage("dropboxToken") private var storedToken = Constants.defaultDropboxToken
    @AppStorage("dropboxRootPath") private var storedRootPath = Constants.defaultDropboxRootPath
    @State private var showClearCacheConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("App Name", systemImage: "app.fill")
                        Spacer()
                        Text("Walley Pro")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Dropbox API Token", systemImage: "key.fill")
                            .font(.subheadline)
                        TextField("Paste your Dropbox API token", text: $storedToken)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Root Folder Path", systemImage: "folder.fill")
                            .font(.subheadline)
                        TextField("/Wallpapers", text: $storedRootPath)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                } header: {
                    Text("Dropbox Configuration")
                } footer: {
                    Text("Enter your Dropbox API token and the path to the folder containing your wallpaper categories.")
                }

                Section {
                    Button(role: .destructive) {
                        showClearCacheConfirmation = true
                    } label: {
                        Label("Clear Image Cache", systemImage: "trash")
                    }
                } header: {
                    Text("Cache")
                } footer: {
                    Text("Clearing the cache will remove all downloaded images. They will be re-downloaded when needed.")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Cache?", isPresented: $showClearCacheConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    ImageCache.shared.clearCache()
                }
            } message: {
                Text("This will remove all cached images from memory.")
            }
        }
    }
}
