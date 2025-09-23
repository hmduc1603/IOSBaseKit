//
//  PurchaseConfig.swift
//  magiclight
//
//  Created by Dennis Hoang on 13/9/25.
//

public struct PurchaseConfig: Decodable {
    public let headers: Headers
    public let hostUrl: String

    public struct Headers: Decodable {
        public let appName: String
        public let serviceName: String
        public let projectId: String
    }
}
