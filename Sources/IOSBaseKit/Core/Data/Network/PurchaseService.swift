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

public struct SubscriptionPackage: Equatable {
    public static func == (lhs: SubscriptionPackage, rhs: SubscriptionPackage) -> Bool {
        return lhs.remoteProduct.productId == rhs.remoteProduct.productId
    }

    public let storeProduct: Product
    public let remoteProduct: RemoteStoreProduct.Product

    static func demoPackage(storeProduct: Product) -> Self {
        .init(
            storeProduct: storeProduct,
            remoteProduct: .init(
                productId: storeProduct.id,
                trialProductId: "com.debug.storekit.trial.monthly",
                isActive: true,
                priceDesc: "(test) per month",
                trialDays: 3,
            )
        )
    }
}

public final class PurchaseService: @unchecked Sendable {
    public static let shared = PurchaseService()

    public var recorder: PurchaseRecordPotocol?

    private var transactionObservingTask: Task<Void, Never>?
    public var packages: [SubscriptionPackage] = []
    public var introPackages: [SubscriptionPackage] = []

    public func loadProducts(ids: [String], introIds: [String]) async {
        var productIds = ids + introIds
        #if DEBUG
            productIds = debugProductIds
        #endif
        do {
            let foundProducts = try await Product.products(for: productIds)
            print("PurchaseService: Loaded \(foundProducts.map { $0.id }).")
            #if DEBUG
                self.packages = foundProducts.map { SubscriptionPackage.demoPackage(storeProduct: $0) }
                self.introPackages = foundProducts.map { SubscriptionPackage.demoPackage(storeProduct: $0) }
            #else
                let remotes = RemoteConfigServiceImpl.shared.iosProducts
                self.packages = mergePackage(store: foundProducts, remote: remotes.normal)
                self.introPackages = mergePackage(store: foundProducts, remote: remotes.intro)
            #endif
        } catch { print("Load error: \(error)") }

        /// Helpers
        func mergePackage(store: [Product], remote: [RemoteStoreProduct.Product]) -> [SubscriptionPackage] {
            var packages = [SubscriptionPackage]()
            for r in remote {
                if r.isActive,
                   let s = store.first(where: { $0.id == r.productId })
                {
                    packages.append(.init(storeProduct: s, remoteProduct: r))
                }
            }
            return packages
        }
    }

    public func hasActiveEntitlement() async -> (Bool) {
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

    public func getCurrentTransaction() async -> (id: String, exp: Date?, product: String)? {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                switch transaction.productType {
                case .autoRenewable:
                    print("✅ Active subscription: \(transaction.productID)")
                    return (transaction.id.description, transaction.expirationDate, transaction.productID)
                case .nonConsumable:
                    print("✅ Purchased one-time IAP: \(transaction.productID)")
                    return (transaction.id.description, transaction.expirationDate, transaction.productID)
                default:
                    break
                }
            }
        }
        return nil
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
                        expirationDate: transaction.expirationDate,
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
            ///   "com.debug.storekit.lifetime",
            ///  "com.debug.storekit.weekly",
            "com.debug.storekit.monthly",
            "com.debug.storekit.yearly"
        ]
    }
}

public protocol PurchaseRecordPotocol {
    func recordPurchase(
        productId: String,
        transactionId: String,
        expirationDate: Date?,
        price: String,
        priceAsNum: Double,
        currency: String,
        isIntroSub: Bool
    )
}
