//
//  RemoteProduct.swift
//  magiclight
//
//  Created by Dennis Hoang on 23/8/25.
//

struct RemoteStoreProduct: Decodable {
    let features: [String]
    let normal: [Product]
    let intro: [Product]

    struct Product: Decodable {
        let productId: String
        var isActive: Bool = false
    }

    var activeProductIds: [String] {
        return normal.filter { $0.isActive }.map { $0.productId }
    }

    var activeIntroProductIds: [String] {
        return intro.filter { $0.isActive }.map { $0.productId }
    }
}
