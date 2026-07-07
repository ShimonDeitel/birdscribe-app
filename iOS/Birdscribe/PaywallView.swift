import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.accent)
                Text("Birdscribe Pro")
                    .font(Theme.titleFont)
                Text("Photo attachments per sighting and species checklist by region")
                    .font(Theme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal)
                Spacer()
                Button {
                    Task {
                        await purchases.purchase()
                        if purchases.isPro { isPresented = false }
                    }
                } label: {
                    Text(purchases.product != nil ? "Unlock Pro - \(purchases.product!.displayPrice)" : "Unlock Pro")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .accessibilityIdentifier("paywall_purchase_button")
                .padding(.horizontal)

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywall_restore_button")
            }
            .padding()
            .background(Theme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { isPresented = false }
                        .accessibilityIdentifier("paywall_close_button")
                }
            }
        }
    }
}
