//
//  AppTextField.swift
//  lgremote
//
//  Created by Dennis Hoang on 30/09/2024.
//

import SwiftUI

struct AppTextField: View {
    @Environment(\.theme) private var theme
    @Binding var inputText: String
    var keyboardType: UIKeyboardType = .default
    var placeholder: String?

    var body: some View {
        ZStack {
            if let placeholder = placeholder {
                if $inputText.wrappedValue.isEmpty {
                    Text(placeholder)
                        .themed(style: theme.textThemeT4.body)
                        .padding(12)
                        .leadingFullWidth()
                        .multilineTextAlignment(.leading)
                }
            }
            TextField("", text: $inputText)
                .font(theme.textThemeT1.body.font)
                .padding(12)
                .tint(theme.btnColor) /// Cursor
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.textColor.opacity(0.5), lineWidth: 1)
                )
                .foregroundColor(theme.textColor)
                .keyboardType(keyboardType)
                .disableAutocorrection(true)
        }
    }
}

struct AppTextEditor: View {
    @Environment(\.theme) private var theme
    @Binding var inputText: String
    var keyboardType: UIKeyboardType = .default
    var placeholder: String?
    var fieldHeight: CGFloat = 100

    var body: some View {
        ZStack {
            if let placeholder = placeholder {
                VStack(spacing: 0) {
                    if $inputText.wrappedValue.isEmpty {
                        Text(placeholder)
                            .themed(style: theme.textThemeT4.body)
                            .padding(12)
                            .leadingFullWidth()
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .frame(height: fieldHeight)
            }
            TextEditor(text: $inputText)
                .frame(height: fieldHeight)
                .font(theme.textThemeT1.body.font)
                .background(Color.clear)
                .tint(theme.btnColor) /// Cursor
                .foregroundColor(theme.textColor)
                .keyboardType(keyboardType)
                .disableAutocorrection(true)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.textColor.opacity(0.5), lineWidth: 1)
                        .frame(height: fieldHeight)
                )
                .scrollContentBackground(.hidden)
        }
    }
}
