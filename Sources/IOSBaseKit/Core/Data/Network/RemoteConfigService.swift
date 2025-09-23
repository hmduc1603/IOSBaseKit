//
//  RemoteConfigService.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Combine
import FirebaseCrashlytics
import FirebaseRemoteConfig
import Foundation

protocol RemoteConfigService {
    func initConfig() async throws
    var adConfig: AdConfig { get }
    var iosProducts: RemoteStoreProduct { get }
    var setPremiumUsers: [String] { get }
    var reviewConfig: Int { get }
    var dailyLimitation: DailyLimitation { get }
    var trendingStories: [TrendingStory] { get }
    var chatGPTConfig: ChatGPTConfig { get }
    var replicateConfig: ReplicateConfig { get }
    var isBlockFreemiumOnVideoCreation: Bool { get }
    var ttsConfig: TTSConfig { get }
    var transcribeConfig: TranscribeConfig { get }
    var videoConfig: VideoConfig { get }
    var purchaseConfig: PurchaseConfig { get }
    var stickerConfig: StickerConfig { get }
    var defaultChars: CharacterConfig   { get }
}

class RemoteConfigServiceImpl: RemoteConfigService {
    static let shared = RemoteConfigServiceImpl()
    private let remoteConfig = RemoteConfig.remoteConfig()

    // Keys
    private let kAdConfig = "adConfig"
    private let kSetPremiumUsers = "setPremiumUsers"
    private let kReviewConfig = "reviewConfig"
    private let kDailyLimitation = "dailyLimitation"
    private let kTrendingStories = "trendingStories"
    private let kChatGPTConfig = "chatGPTConfig"
    private let kReplicateConfig = "replicateConfig"
    private let kIsBlockFreemiumOnVideoCreation = "isBlockFreemiumOnVideoCreation"
    private let kIosProducts = "iosProducts"

    func initConfig() async throws {
        print("RemoteConfigServiceImpl: initConfig")

        if let path = Bundle.main.path(forResource: "remote_config", ofType: "json") {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                var defaults: [String: NSObject] = [:]
                for (key, value) in json {
                    if let value = value as? [Any] {
                        defaults[key] = try? JSONSerialization.data(withJSONObject: value, options: []) as NSObject
                    } else if let value = value as? [String: Any] {
                        defaults[key] = try? JSONSerialization.data(withJSONObject: value, options: []) as NSObject
                    } else {
                        defaults[key] = value as? NSObject
                    }
                }
                remoteConfig.setDefaults(defaults)
            }
        }

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = EnvConfig.isDebug ? 2 : 10
        settings.fetchTimeout = 7
        remoteConfig.configSettings = settings

        return try await withCheckedThrowingContinuation { continuation in
            remoteConfig.fetchAndActivate { status, error in
                if let error {
                    print("RemoteConfigServiceImpl: \(error.localizedDescription)")
                    Crashlytics.crashlytics().record(error: error)
                    continuation.resume(throwing: error)
                } else {
                    print("RemoteConfigServiceImpl: Fetch and activate succeeded with status: \(status)")
                    continuation.resume()
                }
            }
        }
    }

    var trendingStories: [TrendingStory] {
        let raw = remoteConfig[kTrendingStories].stringValue
        let data = Data(raw.utf8)
        let stories = try? JSONDecoder().decode([TrendingStory].self, from: data)
        return stories ?? []
    }

    var isBlockFreemiumOnVideoCreation: Bool {
        return remoteConfig[kIsBlockFreemiumOnVideoCreation].boolValue
    }

    var iosProducts: RemoteStoreProduct {
        let raw = remoteConfig[kIosProducts].stringValue
        let data = Data(raw.utf8)
        let iosProducts = try? JSONDecoder().decode(RemoteStoreProduct.self, from: data)
        return iosProducts ?? .init(features: [], normal: [], intro: [])
    }

    var adConfig: AdConfig {
        let raw = remoteConfig[kAdConfig].stringValue
        let data = Data(raw.utf8)
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let config = AdConfig.fromJsonData(json: jsonObject as! [String: Any]) else { fatalError("Invalid adConfig data") }
        return config
    }

    var setPremiumUsers: [String] {
        let raw = remoteConfig[kSetPremiumUsers].stringValue
        let data = Data(raw.utf8)
        guard let list = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return list
    }

    var reviewConfig: Int {
        // Check if we are in debug mode
        if EnvConfig.isDebug {
            return 1
        }
        // Use optional chaining and nil-coalescing to provide default value
        let numberValue = remoteConfig[kReviewConfig].numberValue.intValue
        guard numberValue != 0 else {
            return 1
        }
        return numberValue
    }

    var dailyLimitation: DailyLimitation {
        let raw = remoteConfig[kDailyLimitation].stringValue
        let data = Data(raw.utf8)
        guard let limitation = try? JSONDecoder().decode(DailyLimitation.self, from: data) else { fatalError("Invalid dailyLimitation data") }
        return limitation
    }

    var chatGPTConfig: ChatGPTConfig {
        let raw = remoteConfig[kChatGPTConfig].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(ChatGPTConfig.self, from: data) else { fatalError("Invalid ChatGPTConfig data") }
        return config
    }

    var replicateConfig: ReplicateConfig {
        let raw = remoteConfig[kReplicateConfig].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(ReplicateConfig.self, from: data) else { fatalError("Invalid ReplicateConfig data") }
        return config
    }

    var ttsConfig: TTSConfig {
        let raw = remoteConfig["ttsConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(TTSConfig.self, from: data) else { fatalError("Invalid TTSConfig data") }
        return config
    }

    var transcribeConfig: TranscribeConfig {
        let raw = remoteConfig["transcribeConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(TranscribeConfig.self, from: data) else { fatalError("Invalid TranscribeConfig data") }
        return config
    }

    var videoConfig: VideoConfig {
        let raw = remoteConfig["videoConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(VideoConfig.self, from: data) else { fatalError("Invalid VideoConfig data") }
        return config
    }

    var purchaseConfig: PurchaseConfig {
        let raw = remoteConfig["purchaseConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(PurchaseConfig.self, from: data) else { fatalError("Invalid PurchaseConfig data") }
        return config
    }

    var stickerConfig: StickerConfig {
        let raw = remoteConfig["stickerConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(StickerConfig.self, from: data) else { fatalError("Invalid StickerConfig data") }
        return config
    }
    
    var defaultChars: CharacterConfig {
        let raw = remoteConfig["defaultChars"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(CharacterConfig.self, from: data) else { fatalError("Invalid CharacterConfig data") }
        return config
    }
}
