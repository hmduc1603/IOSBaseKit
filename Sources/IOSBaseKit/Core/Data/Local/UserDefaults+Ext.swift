//
//  LocalStorage.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case firstOpen
        case isPremium
        case reviewCount
        case voiceLanguage
    }

    var didFirstOpen: Bool {
        UserDefaults.standard.bool(forKey: Key.firstOpen.rawValue)
    }

    func setDidFirstOpen() {
        UserDefaults.standard.set(true, forKey: Key.firstOpen.rawValue)
    }

    var reviewCount: Int {
        UserDefaults.standard.integer(forKey: Key.reviewCount.rawValue)
    }

    func increaseReviewCount() {
        let currentCount = reviewCount
        UserDefaults.standard.set(currentCount + 1, forKey: Key.reviewCount.rawValue)
    }

    var isPremium: Bool {
        UserDefaults.standard.bool(forKey: Key.isPremium.rawValue)
    }

    func setIsPremium(isPremium: Bool = true) {
        UserDefaults.standard.set(isPremium, forKey: Key.isPremium.rawValue)
    }

    var voiceLanguage: String {
        UserDefaults.standard.string(forKey: Key.voiceLanguage.rawValue) ?? StoryVoiceLanguages.english.rawValue
    }

    func setVoiceLanguage(lang: StoryVoiceLanguages) {
        UserDefaults.standard.set(lang.rawValue, forKey: Key.voiceLanguage.rawValue)
    }
}
