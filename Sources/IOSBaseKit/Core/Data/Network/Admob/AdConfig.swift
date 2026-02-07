#if os(iOS)
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
    public let numberOfRewardAd: Int
    public let forceTestAd: Bool?
    public let adLimitation: AdLimitation

    public enum CodingKeys: String, CodingKey {
        case enableInterstitialAd
        case enableOpenAd
        case enableBannerAd
        case enableRewardAd
        case numberOfRewardAd
        case adLimitation
        case forceTestAd
    }

    public init(
        enableInterstitialAd: Bool,
        enableOpenAd: Bool,
        enableBannerAd: Bool,
        numberOfRewardAd: Int = 1,
        enableRewardAd: Bool = false,
        forceTestAd: Bool = false,
        adLimitation: AdLimitation
    ) {
        self.enableInterstitialAd = enableInterstitialAd
        self.enableOpenAd = enableOpenAd
        self.enableBannerAd = enableBannerAd
        self.enableRewardAd = enableRewardAd
        self.numberOfRewardAd = numberOfRewardAd
        self.adLimitation = adLimitation
        self.forceTestAd = forceTestAd
    }

    // Initialize from a JSON dictionary
    public init?(json: [String: Any]) {
        self.enableInterstitialAd = json["enableInterstitialAd"] as? Bool
        self.enableOpenAd = json["enableOpenAd"] as? Bool
        self.enableBannerAd = json["enableBannerAd"] as? Bool
        self.enableRewardAd = json["enableRewardAd"] as? Bool
        self.numberOfRewardAd = json["numberOfRewardAd"] as? Int ?? 1
        self.adLimitation = AdLimitation(json: json["adLimitation"] as! [String: Any])!
        self.forceTestAd = json["forceTestAd"] as? Bool
    }

    // Create an instance from JSON data
    public static func fromJsonData(json: [String: Any]) -> Self? {
        Self(json: json)
    }
}
#endif
