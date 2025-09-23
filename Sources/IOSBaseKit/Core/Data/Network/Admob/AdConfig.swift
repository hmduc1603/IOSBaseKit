//
//  AdConfig.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

public struct AdConfig: Codable {
    public let enableInterstitialAd: Bool?
    public let enableOpenAd: Bool?
    public let enableBannerAd: Bool?
    public let enableRewardAd: Bool?
    public let adLimitation: AdLimitation

    public enum CodingKeys: String, CodingKey {
        case enableInterstitialAd
        case enableOpenAd
        case enableBannerAd
        case enableRewardAd
        case adLimitation
    }

    public init(
        enableInterstitialAd: Bool,
        enableOpenAd: Bool,
        enableBannerAd: Bool,
        enableRewardAd: Bool = false,
        adLimitation: AdLimitation
    ) {
        self.enableInterstitialAd = enableInterstitialAd
        self.enableOpenAd = enableOpenAd
        self.enableBannerAd = enableBannerAd
        self.enableRewardAd = enableRewardAd
        self.adLimitation = adLimitation
    }

    // Initialize from a JSON dictionary
    public init?(json: [String: Any]) {
        self.enableInterstitialAd = json["enableInterstitialAd"] as? Bool
        self.enableOpenAd = json["enableOpenAd"] as? Bool
        self.enableBannerAd = json["enableBannerAd"] as? Bool
        self.enableRewardAd = json["enableRewardAd"] as? Bool
        self.adLimitation = AdLimitation(json: json["adLimitation"] as! [String: Any])!
    }

    // Create an instance from JSON data
    public static func fromJsonData(json: [String: Any]) -> Self? {
        Self(json: json)
    }
}
