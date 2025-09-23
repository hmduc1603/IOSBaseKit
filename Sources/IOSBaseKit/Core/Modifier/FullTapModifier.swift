//
//  FullTapModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 6/9/25.
//

import SwiftUI

struct FullTapModifier: ViewModifier {
    var onTap: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                Color.white.opacity(0.00000009)
                    .onTapGesture {
                        onTap()
                    }
            }
    }
}

extension View {
    func onFullTapGesture(_ perform: @escaping () -> Void) -> some View {
        modifier(FullTapModifier(onTap: perform))
    }
}
