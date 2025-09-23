//
//  AppSelectionField.swift
//  magiclight
//
//  Created by Dennis Hoang on 4/9/25.
//

import SwiftUI

struct AppSelectionField<M: Hashable & ItemLabelProtocol>: View {
    @Environment(\.theme) private var theme

    @Binding var selectedItem: M
    var title: String
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Text(title)
                .themed(style: theme.textThemeT1.title)
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
            .cornerRadiusWithBorder(radius: 12, borderLineWidth: 1, borderColor: theme.textColor.opacity(0.5))
        }
        .frame(height: 35)
        .overlay {
            Color.white.opacity(0.000000009)
                .onTapGesture {
                    onTap()
                }
        }
    }
}
