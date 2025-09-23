//
//  AppTheme.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import IOSBaseKit
import SwiftUI

public struct ThemeKey: EnvironmentKey {
    public static let defaultValue: AppTheme = .default
}

public extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public struct AppTheme: Sendable {
    // Colors
    public var primary: Color
    public var secondary: Color
    public var textColor: Color
    public var textBtnColor: Color
    public var cardColor: Color
    public var btnColor: Color
    public var splashColor: Color
    // Text
    public var textThemeT1: AppTextTheme
    public var textThemeT2: AppTextTheme
    public var textThemeT3: AppTextTheme
    public var textThemeT4: AppTextTheme

    public static let light = Self(
        primary: AppColor.primary.color,
        secondary: AppColor.button.color,
        textColor: Color.white,
        textBtnColor: AppColor.primary.color,
        cardColor: AppColor.card.color,
        btnColor: AppColor.button.color,
        splashColor: AppColor.primary.color,
        textThemeT1: AppTextTheme.create(color: Color.white.opacity(1.0)),
        textThemeT2: AppTextTheme.create(color: Color.white.opacity(0.75)),
        textThemeT3: AppTextTheme.create(color: Color.white.opacity(0.5)),
        textThemeT4: AppTextTheme.create(color: Color.white.opacity(0.25))
    )

    public static let dark = Self(
        primary: AppColor.primary.color,
        secondary: AppColor.button.color,
        textColor: Color.white,
        textBtnColor: Color.white,
        cardColor: Color.clear,
        btnColor: AppColor.button.color,
        splashColor: AppColor.primary.color,
        textThemeT1: AppTextTheme.create(color: Color.white.opacity(1.0)),
        textThemeT2: AppTextTheme.create(color: Color.white.opacity(0.75)),
        textThemeT3: AppTextTheme.create(color: Color.white.opacity(0.5)),
        textThemeT4: AppTextTheme.create(color: Color.white.opacity(0.25))
    )

    public static let `default` = light
}

public class ThemeManager: ObservableObject {
    @Published public var currentTheme: AppTheme = .default

    public func switchToDarkMode() {
        currentTheme = .dark
    }

    public func switchToLightMode() {
        currentTheme = .light
    }
}
