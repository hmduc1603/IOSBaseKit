#if os(iOS)
//
//  SafePaddingModifier.swift
//  lgremote
//
//  Created by Dennis Hoang on 06/10/2024.
//

import SwiftUI

public struct SafePaddingModifier: ViewModifier {
    public var edge: Edge.Set = .bottom

    public func body(content: Content) -> some View {
        content
            .padding(edge, getSafeArea())
    }

    private func getSafeArea() -> CGFloat {
        guard let window = UIApplication.shared.firstKeyWindow else { return .init() }
        switch edge {
        case .bottom:
            return window.safeAreaInsets.bottom
        case .top:
            return window.safeAreaInsets.top
        case .trailing:
            return window.safeAreaInsets.right
        case .leading:
            return window.safeAreaInsets.left
        default:
            return 0
        }
    }
}

public extension View {
    func bottomSafeArea() -> some View {
        modifier(SafePaddingModifier())
    }

    func topSafeArea() -> some View {
        modifier(SafePaddingModifier(edge: .top))
    }
}
#endif
