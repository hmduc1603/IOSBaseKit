//
//  AdLimitation.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

struct AdLimitation: Codable {
    let dailyInterstitialLimitation: Int
    let showInterstitialAfterEveryNumber: Int

    enum CodingKeys: String, CodingKey {
            case dailyInterstitialLimitation
            case showInterstitialAfterEveryNumber
        }

    init(
        dailyInterstitialLimitation: Int = 1,
        showInterstitialAfterEveryNumber: Int = 2
    ) {
        self.dailyInterstitialLimitation = dailyInterstitialLimitation
        self.showInterstitialAfterEveryNumber = showInterstitialAfterEveryNumber
    }

    // Initialize from a JSON dictionary
    init?(json: [String: Any]) {
        guard let dailyInterstitialLimitation = json["dailyInterstitialLimitation"] as? Int,
              let showInterstitialAfterEveryNumber = json["showInterstitialAfterEveryNumber"] as? Int else {
            return nil
        }
        self.dailyInterstitialLimitation = dailyInterstitialLimitation
        self.showInterstitialAfterEveryNumber = showInterstitialAfterEveryNumber
    }

    // Convert to a JSON dictionary
    func toJson() -> [String: Any] {
        [
            "dailyInterstitialLimitation": dailyInterstitialLimitation,
            "showInterstitialAfterEveryNumber": showInterstitialAfterEveryNumber,
        ]
    }

    // Convert to JSON data
    func toJsonData() -> Data? {
        try? JSONSerialization.data(withJSONObject: toJson(), options: .prettyPrinted)
    }

    // Create an instance from JSON data
    static func fromJsonData(_ data: Data) -> Self? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return Self(json: json)
    }
}
