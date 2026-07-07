import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var isPro: Bool = false
    let productId = "birdscribe_pro_monthly"
    @Published var product: Product?
    private var updatesTask: Task<Void, Never>?

    init() {
        Task {
            await loadProducts()
            await updatePurchasedStatus()
        }
        updatesTask = Task { await listenForTransactions() }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPro = true
                }
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedStatus()
    }

    func updatePurchasedStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productId {
                isPro = true
            }
        }
    }

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result, transaction.productID == productId {
                isPro = true
                await transaction.finish()
            }
        }
    }
}
