//
//  RemoteProduct.swift
//  magiclight
//
//  Created by Dennis Hoang on 23/8/25.
//

public struct RemoteStoreProduct: Decodable {
    public let features: [String]
    public let normal: [Product]
    public let intro: [Product]

    public struct Product: Decodable {
        public let productId: String
        public var trialProductId: String? = nil
        public var isActive: Bool = false
        public var priceDesc: String? = nil
        public var trialDays: Int? = nil

        public var isYearly: Bool {
            productId.contains("yearly")
        }

        public var hasTrial: Bool {
            trialProductId != nil
        }
    }

    public var activeProductIds: [String] {
        return normal.filter { $0.isActive }.map { $0.productId }
    }

    public var activeIntroProductIds: [String] {
        return intro.filter { $0.isActive }.map { $0.productId }
    }
}
