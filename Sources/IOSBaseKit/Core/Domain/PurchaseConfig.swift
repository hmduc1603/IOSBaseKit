//
//  PurchaseConfig.swift
//  magiclight
//
//  Created by Dennis Hoang on 13/9/25.
//

struct PurchaseConfig: Decodable {
    let headers: Headers
    let hostUrl: String

    struct Headers: Decodable {
        let appName: String
        let serviceName: String
        let projectId: String
    }
}
