//
//  BuildConfig.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

enum EnvConfig: String {
    case termUrl
    case privacyUrl
    case debugPremium
    case contactEmail
    // Admob
    case appUnitId
    case bannerAdUnitId
    case openAdUnitId
    case rewardAdUnitId
    case interstitialAdUnitId

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    private var envKey: String {
        #if DEBUG
        return "debug"
        #else
        return "prod"
        #endif
    }

    private var envDictionary: NSDictionary {
        guard let filePath = Bundle.main.path(forResource: "Env", ofType: "plist")
        else {
            fatalError("Couldn't find file 'Env.plist'.")
        }
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'Env.plist'.")
        }
        guard let envValue = plist.object(forKey: envKey) as? NSDictionary else {
            fatalError("Couldn't find env key in plist")
        }
        return envValue
    }

    var envValue: Any {
        guard let value = envDictionary.object(forKey: self.rawValue) else {
            fatalError("Couldn't find value for \(self.rawValue) in plist")
        }
        return value
    }
}
