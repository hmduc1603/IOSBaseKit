//
//  DailyCountingManager.swift
//  renoteai
//
//  Created by Dennis Hoang on 11/09/2024.
//
import Foundation

public struct DailyLimitation: Codable {
    public let dailyLimitation: Int

    public init(dailyLimitation: Int = 1) {
        self.dailyLimitation = dailyLimitation
    }
}

public struct DailyCounter: Codable {
    public var updatedDate: Date
    public var counting: Int
    public var type: String

    public mutating func resetToNewDay() {
        counting = 0
        updatedDate = Date()
    }
}

public class DailyCountingManager: @unchecked Sendable {
    public static let shared = DailyCountingManager()
    private init() {}

    private let limitationKey = "DailyLimitation"
    private let counterKey = "DailyCounter"

    private var _limitation: DailyLimitation = .init()

    public func setUpLimitation(_ limitation: DailyLimitation) {
        _limitation = limitation
        if let data = try? JSONEncoder().encode(limitation) {
            UserDefaults.standard.set(data, forKey: limitationKey)
        }
    }

    public var dailyCounter: DailyCounter? {
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

    public func todayLeft(counter: DailyCounter?) -> Int {
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

    public func checkShouldProceed(onShouldProceed: (Bool, DailyCounter?) -> Void) {
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

    public func increaseCounter(type: String) {
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

    public func decreaseCounter(type: String) {
        print("DailyCountingManager: decreaseCounter")
        var counter = dailyCounter
        if let c = counter, c.counting > 0 {
            counter!.counting -= 1
            counter!.updatedDate = Date()
            dailyCounter = counter
        }
    }
}
