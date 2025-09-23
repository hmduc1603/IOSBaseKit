//
//  FullTapModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 6/9/25.
//

import SwiftUI

public struct FullTapModifier: ViewModifier {
    public var onTap: () -> Void

    public func body(content: Content) -> some View {
        content
            .overlay {
                Color.white.opacity(0.00000009)
                    .onTapGesture {
                        onTap()
                    }
            }
    }
}

public extension View {
    func onFullTapGesture(_ perform: @escaping () -> Void) -> some View {
        modifier(FullTapModifier(onTap: perform))
    }
}
