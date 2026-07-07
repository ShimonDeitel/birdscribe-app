import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Binding var isPresented: Bool
    @AppStorage("birdscribe_notif_enabled") var notifEnabled: Bool = true
    @AppStorage("birdscribe_showPhotos") var showPhotos: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Reminders", isOn: $notifEnabled)
                        .accessibilityIdentifier("toggle_reminders")
                    Toggle("Show Photos", isOn: $showPhotos)
                        .accessibilityIdentifier("toggle_photos")
                }
                Section("Pro") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundColor(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            Task { await purchases.purchase() }
                        }
                        .accessibilityIdentifier("upgrade_pro_button")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restore_purchases_button")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/birdscribe-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/birdscribe-app/terms.html")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPresented = false }
                        .accessibilityIdentifier("close_settings_button")
                }
            }
        }
    }
}
