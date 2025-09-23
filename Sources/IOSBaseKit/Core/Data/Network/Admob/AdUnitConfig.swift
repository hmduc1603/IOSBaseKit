//
//  AdUnitConfig.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

public struct AdUnitConfig: Codable {
    public let adId: String
    public let bannerId: String
    public let appOpenId: String
    public let rewardId: String
    public let interstitialId: String

    public enum CodingKeys: String, CodingKey {
        case adId
        case bannerId
        case appOpenId
        case rewardId
        case interstitialId
    }

    public init(
        adId: String,
        bannerId: String,
        appOpenId: String,
        rewardId: String,
        interstitialId: String
    ) {
        self.adId = adId
        self.bannerId = bannerId
        self.appOpenId = appOpenId
        self.rewardId = rewardId
        self.interstitialId = interstitialId
    }

    // Initialize from a JSON dictionary
    public init?(json: [String: Any]) {
        guard let adId = json["adId"] as? String,
              let bannerId = json["bannerId"] as? String,
              let appOpenId = json["appOpenId"] as? String,
              let rewardId = json["rewardId"] as? String,
              let interstitialId = json["interstitialId"] as? String
        else {
            return nil
        }
        self.adId = adId
        self.bannerId = bannerId
        self.appOpenId = appOpenId
        self.rewardId = rewardId
        self.interstitialId = interstitialId
    }

    // Convert to a JSON dictionary
    public func toJson() -> [String: Any] {
        [
            "adId": adId,
            "bannerId": bannerId,
            "appOpenId": appOpenId,
            "rewardId": rewardId,
            "interstitialId": interstitialId,
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

public extension AdUnitConfig {
    static func getAdUnitConfig() -> AdUnitConfig {
        AdUnitConfig(adId: EnvConfig.appUnitId.envValue as? String ?? "",
                     bannerId: EnvConfig.bannerAdUnitId.envValue as? String ?? "",
                     appOpenId: EnvConfig.openAdUnitId.envValue as? String ?? "",
                     rewardId: EnvConfig.rewardAdUnitId.envValue as? String ?? "",
                     interstitialId: EnvConfig.interstitialAdUnitId.envValue as? String ?? "")
    }
}
