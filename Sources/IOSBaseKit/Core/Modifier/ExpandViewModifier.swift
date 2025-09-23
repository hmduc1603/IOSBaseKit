//
//  ExpanModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 15/8/25.
//

import SwiftUI

public struct ExpandViewModifier: ViewModifier {
    public var maxWidth: CGFloat?
    public var maxHeight: CGFloat?

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}
