//
//  ExpanModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 15/8/25.
//

import SwiftUI

struct ExpandViewModifier: ViewModifier {
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}
