//
//  AppTheme.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import DynamicColor
import IOSBaseKit
import SwiftUI

public struct ThemeKey: EnvironmentKey {
    public static let defaultValue: AppTheme = .createDefaultTheme()
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

    public static func createDefaultTheme() -> Self {
        return .init(
            primary: AppColor.shared.primaryColor,
            secondary: AppColor.shared.secondaryColor,
            textColor: AppColor.shared.textColor,
            textBtnColor: AppColor.shared.textButtonColor,
            cardColor: AppColor.shared.cardColor,
            btnColor: AppColor.shared.buttonColor,
            splashColor: AppColor.shared.primaryColor,
            textThemeT1: AppTextTheme.create(color: AppColor.shared.textColor.opacity(1.0)),
            textThemeT2: AppTextTheme.create(color: AppColor.shared.textColor.opacity(0.75)),
            textThemeT3: AppTextTheme.create(color: AppColor.shared.textColor.opacity(0.5)),
            textThemeT4: AppTextTheme.create(color: AppColor.shared.textColor.opacity(0.25))
        )
    }
}

public class ThemeManager: ObservableObject {
    @Published public var currentTheme: AppTheme = .createDefaultTheme()
}
