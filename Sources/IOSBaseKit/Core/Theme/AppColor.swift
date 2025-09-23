//
//  AppColor.swift
//  IOSBaseKit
//
//  Created by Dennis Hoang on 23/9/25.
//

import DynamicColor
import SwiftUI

public final class AppColor: @unchecked Sendable {
    public static let shared = AppColor()

    private var colorDictionary: NSDictionary = {
        guard let filePath = Bundle.main.path(forResource: "Color", ofType: "plist")
        else {
            fatalError("Couldn't find file 'Color.plist'.")
        }
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'Color.plist'.")
        }
        return plist
    }()

    public func getColorValue(key: String) -> Color {
        guard let value = colorDictionary.object(forKey: key) as? String else {
            fatalError("Couldn't find value for \(key) in plist")
        }
        return Color(hexString: value)
    }

    public func getColorHex(key: String) -> String {
        guard let value = colorDictionary.object(forKey: key) as? String else {
            fatalError("Couldn't find value for \(key) in plist")
        }
        return value
    }
}

extension AppColor {
    var primaryColor: Color {
        getColorValue(key: "primaryColor")
    }

    var secondaryColor: Color {
        getColorValue(key: "secondaryColor")
    }

    var buttonColor: Color {
        getColorValue(key: "buttonColor")
    }

    var cardColor: Color {
        getColorValue(key: "cardColor")
    }

    var textColor: Color {
        getColorValue(key: "textColor")
    }

    var subscriptionIconBackgroundColor: Color {
        getColorValue(key: "subscriptionIconBackgroundColor")
    }

    var subscriptionGradientColors: [Color] {
        guard let values = colorDictionary.object(forKey: "subscriptionGradientColors") as? [String] else {
            fatalError("Couldn't find value for subscriptionGradientColors in plist")
        }
        return values.map { Color(hexString: $0) }
    }
}
