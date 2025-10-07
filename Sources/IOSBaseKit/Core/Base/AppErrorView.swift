//
//  AppErrorViw.swift
//  lgremote
//
//  Created by Dennis Hoang on 21/09/2024.
//

import SwiftUI

public struct AppErrorView: View {
    @Environment(\.theme) private var theme
    public var errorMessage: String?
    public var onRetry: (() -> Void)? = nil

    public init(errorMessage: String? = nil, onRetry: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack {
            Text(errorMessage ?? "Something wrong happned, please try again!").themed()
                .padding(.bottom, 8)
            Button {
                onRetry?()
            } label: {
                Text("Retry").themed(style: theme.textThemeT1.button.copyWith(color: theme.btnColor))
            }
        }
    }
}
