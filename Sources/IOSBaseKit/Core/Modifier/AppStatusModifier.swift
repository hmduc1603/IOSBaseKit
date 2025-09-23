//
//  AppStatusModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 16/8/25.
//

import SwiftUI

public struct AppStatusModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Binding public var status: AppStatus
    public var onRetry: (() -> Void)?

    public func body(content: Content) -> some View {
        if case .error(let error) = status,
           onRetry != nil
        {
            VStack {
                Text(error ?? "Something went wrong!")
                    .themed()
                Button {
                    onRetry?()
                } label: {
                    Text(error ?? "Something went wrong!")
                        .themed(style: theme.textThemeT1.button)
                }
            }
        } else {
            content
                .overlay {
                    if case .loading(let message) = status {
                        AppLoadingHUD(message: message)
                    }
                }
        }
    }
}

public extension View {
    func observeAppStatus(
        status: Binding<AppStatus>,
        onRetry: (() -> Void)? = nil
    ) -> some View {
        modifier(AppStatusModifier(status: status, onRetry: onRetry))
    }
}
