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

public protocol RemoteConfigService {
    func initConfig() async throws
    var adConfig: AdConfig { get }
    var iosProducts: RemoteStoreProduct { get }
    var setPremiumUsers: [String] { get }
    var reviewConfig: Int { get }
    var dailyLimitation: DailyLimitation { get }
    var purchaseConfig: PurchaseConfig { get }
}

public class RemoteConfigServiceImpl: RemoteConfigService, @unchecked Sendable {
    public static let shared = RemoteConfigServiceImpl()
    public let remoteConfig = RemoteConfig.remoteConfig()

    // Keys
    private let kAdConfig = "adConfig"
    private let kSetPremiumUsers = "setPremiumUsers"
    private let kReviewConfig = "reviewConfig"
    private let kDailyLimitation = "dailyLimitation"
    private let kIosProducts = "iosProducts"

    public func initConfig() async throws {
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

    public var iosProducts: RemoteStoreProduct {
        let raw = remoteConfig[kIosProducts].stringValue
        let data = Data(raw.utf8)
        let iosProducts = try? JSONDecoder().decode(RemoteStoreProduct.self, from: data)
        return iosProducts ?? .init(features: [], normal: [], intro: [])
    }

    public var adConfig: AdConfig {
        let raw = remoteConfig[kAdConfig].stringValue
        let data = Data(raw.utf8)
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let config = AdConfig.fromJsonData(json: jsonObject as! [String: Any]) else { fatalError("Invalid adConfig data") }
        return config
    }

    public var setPremiumUsers: [String] {
        let raw = remoteConfig[kSetPremiumUsers].stringValue
        let data = Data(raw.utf8)
        guard let list = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return list
    }

    public var reviewConfig: Int {
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

    public var dailyLimitation: DailyLimitation {
        let raw = remoteConfig[kDailyLimitation].stringValue
        let data = Data(raw.utf8)
        guard let limitation = try? JSONDecoder().decode(DailyLimitation.self, from: data) else { fatalError("Invalid dailyLimitation data") }
        return limitation
    }

    public var purchaseConfig: PurchaseConfig {
        let raw = remoteConfig["purchaseConfig"].stringValue
        let data = Data(raw.utf8)
        guard let config = try? JSONDecoder().decode(PurchaseConfig.self, from: data) else { fatalError("Invalid PurchaseConfig data") }
        return config
    }
}
