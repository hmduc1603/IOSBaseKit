//
//  DailyCountingManager.swift
//  renoteai
//
//  Created by Dennis Hoang on 11/09/2024.
//
import Foundation

struct DailyLimitation: Codable {
    let dailyLimitation: Int

    init(dailyLimitation: Int = 1) {
        self.dailyLimitation = dailyLimitation
    }
}

struct DailyCounter: Codable {
    var updatedDate: Date
    var counting: Int
    var type: String

    mutating func resetToNewDay() {
        counting = 0
        updatedDate = Date()
    }
}

class DailyCountingManager {
    static let shared = DailyCountingManager()
    private init() {}

    private let limitationKey = "DailyLimitation"
    private let counterKey = "DailyCounter"

    private var _limitation: DailyLimitation = .init()

    func setUpLimitation(_ limitation: DailyLimitation) {
        _limitation = limitation
        if let data = try? JSONEncoder().encode(limitation) {
            UserDefaults.standard.set(data, forKey: limitationKey)
        }
    }

    var dailyCounter: DailyCounter? {
        get {
            guard let data = UserDefaults.standard.data(forKey: counterKey),
                  let counter = try? JSONDecoder().decode(DailyCounter.self, from: data)
            else {
                return nil
            }
            return counter
        }
        set {
            if let newValue = newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: counterKey)
            } else {
                UserDefaults.standard.removeObject(forKey: counterKey)
            }
        }
    }

    func todayLeft(counter: DailyCounter?) -> Int {
        guard let counter = counter else {
            return _limitation.dailyLimitation
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(counter.updatedDate) {
            return max(_limitation.dailyLimitation - counter.counting, 0)
        } else {
            return _limitation.dailyLimitation
        }
    }

    func checkShouldProceed(onShouldProceed: (Bool, DailyCounter?) -> Void) {
        if UserDefaults.standard.isPremium {
            onShouldProceed(true, nil)
            return
        }
        if _limitation.dailyLimitation == 0 {
            onShouldProceed(false, nil)
            return
        }
        var shouldProceed = false
        var counter = dailyCounter
        let calendar = Calendar.current
        if counter == nil {
            shouldProceed = true
        } else if calendar.isDateInToday(counter!.updatedDate) {
            if counter!.counting < _limitation.dailyLimitation {
                shouldProceed = true
            }
        } else {
            counter!.resetToNewDay()
            shouldProceed = true
        }
        onShouldProceed(shouldProceed, counter)
    }

    func increaseCounter(type: String) {
        print("DailyCountingManager: increaseCounter")
        var counter = dailyCounter
        let calendar = Calendar.current
        if counter == nil || !calendar.isDateInToday(counter!.updatedDate) {
            counter = DailyCounter(updatedDate: Date(), counting: 1, type: type)
        } else {
            counter!.counting += 1
            counter!.updatedDate = Date()
        }
        dailyCounter = counter
    }

    func decreaseCounter(type: String) {
        print("DailyCountingManager: decreaseCounter")
        var counter = dailyCounter
        if let c = counter, c.counting > 0 {
            counter!.counting -= 1
            counter!.updatedDate = Date()
            dailyCounter = counter
        }
    }
}
