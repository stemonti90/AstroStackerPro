import Foundation
import StoreKit

final class PurchasesService {
    static let shared = PurchasesService()
    private init() {}

    func restore() async throws {
        try await AppStore.sync()
    }

    func currentEntitlements() async throws -> [Product] {
        return try await Product.products(for: ["com.example.pro"])
    }
}
