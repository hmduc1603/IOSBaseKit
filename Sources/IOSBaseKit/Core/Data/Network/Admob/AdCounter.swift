//
//  AdCounter.swift
//  renoteai
//
//  Created by Dennis Hoang on 29/08/2024.
//

import Foundation

struct AdCounter: Codable {
    var adsCounting: Int
    var updatedDate: Date

    enum CodingKeys: CodingKey {
        case adsCounting
        case updatedDate
    }

    // Convert to a JSON dictionary
    func toJson() -> [String: Any] {
        let dateFormatter = ISO8601DateFormatter()
        return [
            "adsCounting": self.adsCounting,
            "updatedDate": dateFormatter.string(from: self.updatedDate),
        ]
    }

    // Convert to Object
    static func toObject(json: [String: Any]) -> Self {
        let dateFormatter = ISO8601DateFormatter()

        if let adsCounting = json["adsCounting"] as? Int,
           let updatedDateString = json["updatedDate"] as? String,
           let updatedDate = dateFormatter.date(from: updatedDateString) {
            return Self(adsCounting: adsCounting, updatedDate: updatedDate)
        }
        return Self(adsCounting: 0, updatedDate: Date())
    }

    mutating func reset() {
        self.adsCounting = 0
    }

    mutating func countUp() {
        self.adsCounting += 1
    }
}
