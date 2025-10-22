//
//  AppPrimaryButton.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

public struct AppPrimaryButton: View {
    @Environment(\.theme) private var theme: AppTheme
    public var isButtonEnabled: Bool
    public var widthExpanded: Bool
    public var buttonTitle: String
    public var buttonColor: Color?
    public var textStyle: TextStyle?
    public var buttonHeight: CGFloat?
    public var action: () -> Void

    public init(
        isButtonEnabled: Bool = true,
        widthExpanded: Bool = true,
        buttonTitle: String,
        buttonColor: Color? = nil,
        textStyle: TextStyle? = nil,
        buttonHeight: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.isButtonEnabled = isButtonEnabled
        self.widthExpanded = widthExpanded
        self.buttonTitle = buttonTitle
        self.buttonColor = buttonColor
        self.buttonHeight = buttonHeight
        self.action = action
        self.textStyle = textStyle
    }

    public var body: some View {
        Button {
            action()
        } label: {
            VStack {
                if widthExpanded {
                    VStack {
                        Text(buttonTitle)
                            .themed(style: textStyle ?? theme.textThemeT1.button.copyWith(color: theme.textBtnColor))
                    }
                    .widthExpanded()
                } else {
                    VStack {
                        Text(buttonTitle)
                            .themed(style: textStyle ?? theme.textThemeT1.button.copyWith(color: theme.textBtnColor))
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: 50)
            .background(
                buttonColor ?? theme.btnColor
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .opacity(isButtonEnabled ? 1.0 : 0.3)
        .disabled(!isButtonEnabled)
    }
}
