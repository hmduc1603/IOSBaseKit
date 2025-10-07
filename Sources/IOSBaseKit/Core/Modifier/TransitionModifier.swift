//
//  TransitionModifier.swift
//  IOSBaseKit
//
//  Created by Dennis Hoang on 3/10/25.
//

import SwiftUI

public struct TransitionModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .transition(.scale.combined(with: .opacity).animation(.bouncy))
    }
}

public extension View {
    func bouncyTransition() -> some View {
        modifier(TransitionModifier())
    }
}
