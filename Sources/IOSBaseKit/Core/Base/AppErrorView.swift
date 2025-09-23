//
//  AppErrorViw.swift
//  lgremote
//
//  Created by Dennis Hoang on 21/09/2024.
//

import SwiftUI

struct AppErrorView: View {
    @Environment(\.theme) private var theme
    var errorMessage: String?
    var onRetry: (() -> Void)? = nil

    var body: some View {
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
