//
//  AppFont.swift
//  renoteai
//
//  Created by Dennis Hoang on 29/08/2024.
//

import IOSBaseKit
import SwiftUI

public struct AppTextTheme: Sendable {
    public let bigTitle: TextStyle
    public let title: TextStyle
    public let button: TextStyle
    public let textButton: TextStyle
    public let header0: TextStyle
    public let header1: TextStyle
    public let header2: TextStyle
    public let body: TextStyle
    public let light: TextStyle
    public let error: TextStyle
    public let placeHolder: TextStyle
    public let small: TextStyle
    public let caption: TextStyle

    public init(bigTitle: TextStyle, title: TextStyle, button: TextStyle, textButton: TextStyle, header0: TextStyle, header1: TextStyle, header2: TextStyle, body: TextStyle, light: TextStyle, error: TextStyle, placeHolder: TextStyle, small: TextStyle, caption: TextStyle) {
        self.bigTitle = bigTitle
        self.title = title
        self.button = button
        self.textButton = textButton
        self.header0 = header0
        self.header1 = header1
        self.header2 = header2
        self.body = body
        self.light = light
        self.error = error
        self.placeHolder = placeHolder
        self.small = small
        self.caption = caption
    }

    public static func create(color: Color) -> Self {
        Self(
            bigTitle: TextStyle(font: Font.system(size: 18).weight(.bold), color: color, weight: .bold),
            title: TextStyle(font: Font.system(size: 16).weight(.bold), color: color, weight: .bold),
            button: TextStyle(font: Font.system(size: 16).weight(.bold), color: color, weight: .bold),
            textButton: TextStyle(font: Font.system(size: 15), color: color),
            header0: TextStyle(font: Font.system(size: 40).weight(.bold), color: color, weight: .bold),
            header1: TextStyle(font: Font.system(size: 30).weight(.bold), color: color, weight: .bold),
            header2: TextStyle(font: Font.system(size: 20).weight(.bold), color: color, weight: .bold),
            body: TextStyle(font: Font.system(size: 15), color: color),
            light: TextStyle(font: Font.system(size: 13).weight(.light), color: color, weight: .light),
            error: TextStyle(font: Font.system(size: 17), color: color),
            placeHolder: TextStyle(font: Font.system(size: 15), color: color),
            small: TextStyle(font: Font.system(size: 10), color: color),
            caption: TextStyle(font: Font.system(size: 14), color: color)
        )
    }
}

public struct ThemedTextModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public var style: TextStyle?

    public func body(content: Content) -> some View {
        content
            .font(style?.font ?? theme.textThemeT1.body.font)
            .foregroundColor(style?.color ?? theme.textColor)
    }
}

public struct TextStyle: Sendable {
    public var font: Font
    public var color: Color
    public var weight: Font.Weight = .regular

    public func copyWith(font: Font? = nil, color: Color? = nil, weight: Font.Weight? = nil) -> Self {
        Self(font: font?.weight(weight ?? self.weight) ?? self.font, color: color ?? self.color, weight: weight ?? self.weight)
    }
}

public extension Text {
    func themed(style: TextStyle? = nil) -> some View {
        modifier(ThemedTextModifier(style: style))
    }
}
