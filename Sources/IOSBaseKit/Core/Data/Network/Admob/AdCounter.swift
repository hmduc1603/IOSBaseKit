#if os(iOS)
//
//  AdCounter.swift
//  renoteai
//
//  Created by Dennis Hoang on 29/08/2024.
//

import Foundation

public struct AdCounter: Codable {
    public var adsCounting: Int
    public var updatedDate: Date

    public enum CodingKeys: CodingKey {
        case adsCounting
        case updatedDate
    }

    // Convert to a JSON dictionary
    public func toJson() -> [String: Any] {
        let dateFormatter = ISO8601DateFormatter()
        return [
            "adsCounting": self.adsCounting,
            "updatedDate": dateFormatter.string(from: self.updatedDate),
        ]
    }

    // Convert to Object
    public static func toObject(json: [String: Any]) -> Self {
        let dateFormatter = ISO8601DateFormatter()

        if let adsCounting = json["adsCounting"] as? Int,
           let updatedDateString = json["updatedDate"] as? String,
           let updatedDate = dateFormatter.date(from: updatedDateString)
        {
            return Self(adsCounting: adsCounting, updatedDate: updatedDate)
        }
        return Self(adsCounting: 0, updatedDate: Date())
    }

    public mutating func reset() {
        self.adsCounting = 0
    }

    public mutating func countUp() {
        self.adsCounting += 1
    }
}
#endif
