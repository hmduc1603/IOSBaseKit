//
//  AdCountingManager.swift
//  renoteai
//
//  Created by Dennis Hoang on 29/08/2024.
//

import Foundation

public class AdsCountingManager: @unchecked Sendable {
    static let shared = AdsCountingManager()
    private init() {}

    private var count = 0
    private let key = "_kAdsCounter"

    private var adsCounter: AdCounter {
        if let value = UserDefaults.standard.object(forKey: key) as? [String: Any] {
            return AdCounter.toObject(json: value)
        }
        return AdCounter(adsCounting: 0, updatedDate: Date())
    }

    public func checkShouldShowAds(onShouldShowAds: @escaping (Bool) -> Void) {
        var shouldShowAds = false
        guard let config = AdmobService.shared.config else {
            onShouldShowAds(shouldShowAds)
            return
        }

        if Calendar.current.isDateInToday(adsCounter.updatedDate) {
            if adsCounter.adsCounting < config.adLimitation.dailyInterstitialLimitation {
                if config.adLimitation.showInterstitialAfterEveryNumber > 0,
                   count == 0 || count % config.adLimitation.showInterstitialAfterEveryNumber == 0
                {
                    shouldShowAds = true
                    increaseCounter(adsCounter: adsCounter)
                }
                count += 1
            }
        } else {
            // reset to new day
            count += 1
            shouldShowAds = true
            increaseCounter(adsCounter: AdCounter(adsCounting: count, updatedDate: Date()))
        }

        onShouldShowAds(shouldShowAds)
        print("Should show ads: \(shouldShowAds)", "AdsCountingManager")
    }

    private func increaseCounter(adsCounter: AdCounter? = nil) {
        if adsCounter == nil {
            let newAdsCounter = AdCounter(
                adsCounting: 1, updatedDate: Date()
            )
            UserDefaults.standard.set(newAdsCounter.toJson(), forKey: key)
        } else {
            let newAdsCounter = AdCounter(
                adsCounting: adsCounter!.adsCounting + 1, updatedDate: Date()
            )
            UserDefaults.standard.set(newAdsCounter.toJson(), forKey: key)
        }
    }
}
