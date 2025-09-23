//
//  TextModifier.swift
//  lgremote
//
//  Created by Dennis Hoang on 21/09/2024.
//

import SwiftUI

public struct TextModifierLeadingFullWidth: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public extension View {
    func leadingFullWidth() -> some View {
        modifier(TextModifierLeadingFullWidth())
    }
}
