//
//  PurchaseService.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Combine
import Factory
import FirebaseAnalytics
import Foundation
import StoreKit
import SwiftUI

public final class PurchaseService: @unchecked Sendable {
    public static let shared = PurchaseService()

    public var recorder: PurchaseRecordPotocol?

    private var transactionObservingTask: Task<Void, Never>?
    public var products: [Product] = []
    public var introProducts: [Product] = []

    public func loadProducts(ids: [String], introIds: [String]) async {
        var productIds = ids + introIds
        #if DEBUG
            productIds = debugProductIds
        #endif
        do {
            let foundProducts = try await Product.products(for: productIds)
            print("PurchaseService: Loaded \(foundProducts.map { $0.id }).")
            #if DEBUG
                self.products = foundProducts
                self.introProducts = foundProducts
            #else
                self.products = foundProducts.filter { ids.contains($0.id) }
                self.introProducts = foundProducts.filter { introIds.contains($0.id) }
            #endif
        } catch { print("Load error: \(error)") }
    }

    public func hasActiveEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                switch transaction.productType {
                case .autoRenewable:
                    print("✅ Active subscription: \(transaction.productID)")
                    UserDefaults.standard.setIsPremium()
                    return true
                case .nonConsumable:
                    print("✅ Purchased one-time IAP: \(transaction.productID)")
                    UserDefaults.standard.setIsPremium()
                    return true
                default:
                    break
                }
            }
        }
        UserDefaults.standard.setIsPremium(isPremium: false)
        return false
    }

    /// Call this function to start observing transactions
    public func startObservingTransactions() {
        self.transactionObservingTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // ✅ Success
                    print("Purchase success: \(transaction.productID)")

                    // Always finish the transaction
                    await transaction.finish()

                    UserDefaults.standard.setIsPremium()

                case .unverified(let transaction, let error):
                    // ⚠️ Failed or fraud
                    print("Purchase unverified: \(transaction.productID), error: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Function to restore completed transactions
    public func restoreCompletedTransactions() async {
        try? await AppStore.sync()
    }

    public func purchase(product: Product, isIntroSub: Bool) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("✅ Purchase successful: \(transaction.productID)")
                    await transaction.finish()
                    UserDefaults.standard.setIsPremium()

                    self.recorder?.recordPurchase(
                        productId: transaction.productID,
                        transactionId: transaction.id.description,
                        price: product.displayPrice,
                        priceAsNum: Double(truncating: product.price as NSNumber),
                        currency: product.priceFormatStyle.currencyCode,
                        isIntroSub: isIntroSub,
                    )
                    return true
                case .unverified(_, let error):
                    print("⚠️ Unverified purchase: \(error.localizedDescription)")
                    return false
                }
            case .userCancelled:
                print("❌ Purchase cancelled by user")
                return false
            case .pending:
                print("⏳ Purchase pending")
                return false
            @unknown default:
                print("⚠️ Unknown purchase result")
                return false
            }
        } catch {
            print("❌ Purchase error: \(error.localizedDescription)")
            return false
        }
    }

    @MainActor
    public func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            AppStore.requestReview(in: scene)
        }
    }

    deinit {
        transactionObservingTask?.cancel()
    }
}

public extension PurchaseService {
    /// You need to configure StoreKit Configuration
    var debugProductIds: [String] {
        [
            "com.debug.storekit.lifetime",
            "com.debug.storekit.weekly",
            "com.debug.storekit.monthly"
        ]
    }
}

public protocol PurchaseRecordPotocol {
    func recordPurchase(
        productId: String,
        transactionId: String,
        price: String,
        priceAsNum: Double,
        currency: String,
        isIntroSub: Bool
    )
}
