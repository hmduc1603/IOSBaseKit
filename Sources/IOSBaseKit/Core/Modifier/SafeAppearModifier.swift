//
//  SafeAppearModifier.swift
//  IOSBaseKit
//
//  Created by Dennis Hoang on 28/9/25.
//

import SwiftUI

public struct SafeAppearModifier: ViewModifier {
    @State private var isAppeared: Bool = false

    var onAppear: () -> Void

    public func body(content: Content) -> some View {
        content
            .onAppear {
                if !isAppeared {
                    isAppeared = true
                    onAppear()
                }
            }
    }
}

public extension View {
    func onSafeAppear(onAppear: @escaping () -> Void) -> some View {
        modifier(SafeAppearModifier(onAppear: onAppear))
    }
}
