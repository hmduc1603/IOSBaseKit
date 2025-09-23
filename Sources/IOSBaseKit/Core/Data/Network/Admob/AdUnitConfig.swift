//
//  AdUnitConfig.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

struct AdUnitConfig: Codable {
    let adId: String
    let bannerId: String
    let appOpenId: String
    let rewardId: String
    let interstitialId: String

    enum CodingKeys: String, CodingKey {
        case adId
        case bannerId
        case appOpenId
        case rewardId
        case interstitialId
    }

    init(
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
    init?(json: [String: Any]) {
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
    func toJson() -> [String: Any] {
        [
            "adId": adId,
            "bannerId": bannerId,
            "appOpenId": appOpenId,
            "rewardId": rewardId,
            "interstitialId": interstitialId,
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

extension AdUnitConfig {
    static func getAdUnitConfig() -> AdUnitConfig {
        AdUnitConfig(adId: EnvConfig.appUnitId.envValue as? String ?? "",
                     bannerId: EnvConfig.bannerAdUnitId.envValue as? String ?? "",
                     appOpenId: EnvConfig.openAdUnitId.envValue as? String ?? "",
                     rewardId: EnvConfig.rewardAdUnitId.envValue as? String ?? "",
                     interstitialId: EnvConfig.interstitialAdUnitId.envValue as? String ?? "")
    }
}
