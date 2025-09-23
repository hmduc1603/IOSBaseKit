//
//  LoadingHUD.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import SwiftUI

public struct AppLoadingHUD: View {
    @Environment(\.theme) private var theme
    public var message: String?

    public var body: some View {
        ZStack {
            VStack {
                AppLoadingIndicator()
                if message != nil {
                    Spacer().frame(height: 30)
                    Text(message!).themed(style: theme.textThemeT1.body.copyWith(color: theme.primary))
                        .multilineTextAlignment(.center)
                }
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        }.background(Color.black.opacity(0.85))
    }
}

struct AppLoadingView: View {
    @Environment(\.theme) private var theme
    var message: String?

    var body: some View {
        VStack {
            AppLoadingIndicator()
            if message != nil {
                Spacer().frame(height: 30)
                Text(message!).themed()
            }
        }
    }
}

public struct AppLoadingIndicator: View {
    @Environment(\.theme) private var theme

    var scaleEffect: Double = 1.2

    public init(scaleEffect: Double = 1.2) {
        self.scaleEffect = scaleEffect
    }

    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: theme.btnColor))
            .scaleEffect(scaleEffect)
    }
}
