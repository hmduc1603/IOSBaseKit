#if os(iOS)
//
//  AdLimitation.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

public struct AdLimitation: Codable {
    public let dailyInterstitialLimitation: Int
    public let showInterstitialAfterEveryNumber: Int

    public enum CodingKeys: String, CodingKey {
        case dailyInterstitialLimitation
        case showInterstitialAfterEveryNumber
    }

    public init(
        dailyInterstitialLimitation: Int = 1,
        showInterstitialAfterEveryNumber: Int = 2
    ) {
        self.dailyInterstitialLimitation = dailyInterstitialLimitation
        self.showInterstitialAfterEveryNumber = showInterstitialAfterEveryNumber
    }

    // Initialize from a JSON dictionary
    public init?(json: [String: Any]) {
        guard let dailyInterstitialLimitation = json["dailyInterstitialLimitation"] as? Int,
              let showInterstitialAfterEveryNumber = json["showInterstitialAfterEveryNumber"] as? Int
        else {
            return nil
        }
        self.dailyInterstitialLimitation = dailyInterstitialLimitation
        self.showInterstitialAfterEveryNumber = showInterstitialAfterEveryNumber
    }

    // Convert to a JSON dictionary
    public func toJson() -> [String: Any] {
        [
            "dailyInterstitialLimitation": dailyInterstitialLimitation,
            "showInterstitialAfterEveryNumber": showInterstitialAfterEveryNumber,
        ]
    }

    // Convert to JSON data
    public func toJsonData() -> Data? {
        try? JSONSerialization.data(withJSONObject: toJson(), options: .prettyPrinted)
    }

    // Create an instance from JSON data
    public static func fromJsonData(_ data: Data) -> Self? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return Self(json: json)
    }
}
#endif
