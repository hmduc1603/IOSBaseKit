//
//  KeyboardDimissModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import SwiftUI

struct KeyboardDimissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil,
                                            from: nil,
                                            for: nil)
        }
    }
}

extension View {
    func addKeyboardDimisser() -> some View {
        modifier(KeyboardDimissModifier())
    }
}
