//
//  BorderCornerModifier.swift
//  Delta
//
//  Created by Dennis Hoang on 13/09/2024.
//  Copyright © 2024 AppVantage. All rights reserved.
//

import Foundation
import SwiftUI

public struct ModifierCornerRadiusWithBorder: ViewModifier {
    public var radius: CGFloat
    public var borderLineWidth: CGFloat = 1
    public var borderColor: Color = .gray
    public var antialiased = true

    public func body(content: Content) -> some View {
        content
            .cornerRadius(self.radius, antialiased: self.antialiased)
            .overlay(
                RoundedRectangle(cornerRadius: self.radius)
                    .strokeBorder(self.borderColor, lineWidth: self.borderLineWidth, antialiased: self.antialiased)
            )
    }
}

public extension View {
    func cornerRadiusWithBorder(radius: CGFloat, borderLineWidth: CGFloat = 1, borderColor: Color = .gray, antialiased: Bool = true) -> some View {
        modifier(ModifierCornerRadiusWithBorder(radius: radius, borderLineWidth: borderLineWidth, borderColor: borderColor, antialiased: antialiased))
    }
}
