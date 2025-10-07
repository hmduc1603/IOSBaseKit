//
//  AppSelectionField.swift
//  magiclight
//
//  Created by Dennis Hoang on 4/9/25.
//

import SwiftUI

public struct AppSelectionField<M: Hashable & ItemLabelProtocol>: View {
    @Environment(\.theme) private var theme

    @Binding public var selectedItem: M
    public var height: CGFloat?
    public var title: String
    public var titleStyle: TextStyle?
    public var borderLineWidth: CGFloat?
    public var borderLineColor: Color?
    public var backgroundColor: Color?
    public var onTap: () -> Void

    public init(selectedItem: Binding<M>, height: CGFloat? = nil, title: String, titleStyle: TextStyle? = nil, borderLineWidth: CGFloat? = 1, borderLineColor: Color? = nil, backgroundColor: Color? = nil, onTap: @escaping () -> Void) {
        self._selectedItem = selectedItem
        self.title = title
        self.height = height
        self.titleStyle = titleStyle
        self.borderLineWidth = borderLineWidth
        self.borderLineColor = borderLineColor
        self.backgroundColor = backgroundColor
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: 20) {
            Text(title)
                .themed(style: titleStyle ?? theme.textThemeT1.title)
            HStack {
                HStack {
                    Text(selectedItem.label)
                        .themed()
                        .lineLimit(1)
                    Spacer()
                    Image("ic_down")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(theme.btnColor)
                        .frame(width: 17, height: 17)
                }
                .padding(.all, 15)
            }
            .background(backgroundColor ?? .clear)
            .cornerRadiusWithBorder(radius: 12, borderLineWidth: borderLineWidth ?? 1, borderColor: borderLineColor ?? theme.textColor.opacity(0.5))
        }
        .frame(height: height ?? 35)
        .overlay {
            Color.white.opacity(0.000000009)
                .onTapGesture {
                    onTap()
                }
        }
    }
}
