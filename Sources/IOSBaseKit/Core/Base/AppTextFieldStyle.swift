//
//  AppTextField.swift
//  lgremote
//
//  Created by Dennis Hoang on 30/09/2024.
//

import SwiftUI

public struct AppTextField: View {
    @Environment(\.theme) private var theme
    @Binding public var inputText: String
    public var keyboardType: UIKeyboardType = .default
    public var placeholder: String?

    public init(inputText: Binding<String>, keyboardType: UIKeyboardType = .default, placeholder: String? = nil) {
        self._inputText = inputText
        self.keyboardType = keyboardType
        self.placeholder = placeholder
    }

    public var body: some View {
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

public struct AppTextEditor: View {
    @Environment(\.theme) private var theme
    @Binding public var inputText: String
    public var keyboardType: UIKeyboardType = .default
    public var placeholder: String?
    public var fieldHeight: CGFloat = 100
    public var borderLineWidth: CGFloat?
    public var borderLineColor: Color?
    public var backgroundColor: Color?

    public init(inputText: Binding<String>, borderLineWidth: CGFloat? = nil,
                borderLineColor: Color? = nil,
                backgroundColor: Color? = nil,
                keyboardType: UIKeyboardType = .default, placeholder: String? = nil, fieldHeight: CGFloat = 100)
    {
        self._inputText = inputText
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.fieldHeight = fieldHeight
        self.borderLineColor = borderLineColor
        self.backgroundColor = backgroundColor
        self.borderLineWidth = borderLineWidth
    }

    public var body: some View {
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
                .background(backgroundColor ?? Color.clear)
                .tint(theme.btnColor) /// Cursor
                .foregroundColor(theme.textColor)
                .keyboardType(keyboardType)
                .disableAutocorrection(true)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderLineColor ?? theme.textColor.opacity(0.5), lineWidth: borderLineWidth ?? 1)
                        .frame(height: fieldHeight)
                )
                .scrollContentBackground(.hidden)
        }
    }
}
