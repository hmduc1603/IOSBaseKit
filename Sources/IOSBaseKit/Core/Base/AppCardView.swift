//
//  AppCardView.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

struct AppCardView<Content: View>: View {
    @Environment(\.theme) private var theme: AppTheme
    var padding: CGFloat = 12
    var radius: CGFloat = 12
    var backgroundColor: Color?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            content()
        }.padding(padding)
            .background(backgroundColor ?? theme.cardColor)
            .cornerRadius(radius)
    }
}
