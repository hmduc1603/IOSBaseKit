//
//  AppCardView.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

public struct AppCardView<Content: View>: View {
    @Environment(\.theme) private var theme: AppTheme
    public var padding: CGFloat
    public var radius: CGFloat
    public var backgroundColor: Color?
    @ViewBuilder public var content: () -> Content

    public init(padding: CGFloat = 12, radius: CGFloat = 12, backgroundColor: Color? = nil, content: @escaping () -> Content) {
        self.padding = padding
        self.radius = radius
        self.backgroundColor = backgroundColor
        self.content = content
    }

    public var body: some View {
        VStack {
            content()
        }.padding(padding)
            .background(backgroundColor ?? theme.cardColor)
            .cornerRadius(radius)
    }
}
