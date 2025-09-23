//
//  AppPrimaryButton.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

public struct AppPrimaryButton: View {
    @Environment(\.theme) private var theme: AppTheme
    @Binding public var isButtonEnabled: Bool
    public var buttonTitle: String
    public var buttonColor: Color?
    public var textStyle: TextStyle?
    public var buttonHeight: CGFloat?
    public var action: () -> Void

    public init(
        isButtonEnabled: Binding<Bool>? = nil,
        buttonTitle: String,
        buttonColor: Color? = nil,
        textStyle: TextStyle? = nil,
        buttonHeight: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self._isButtonEnabled = isButtonEnabled ?? .constant(true)
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
                Text(buttonTitle)
                    .themed(style: textStyle ?? theme.textThemeT1.button.copyWith(color: theme.textBtnColor))
            }
            .frame(height: 50)
            .widthExpanded()
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
