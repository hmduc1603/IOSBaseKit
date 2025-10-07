//
//  AppSegmentView.swift
//  IOSBaseKit
//
//  Created by Dennis Hoang on 4/10/25.
//

import SwiftUI

public protocol SegmentDataProtocol: Identifiable, Equatable {
    var label: String { get }
}

public struct AppSegmentView<M: SegmentDataProtocol>: View {
    @Environment(\.theme) private var theme
    @Binding public var selectedItem: M
    public var items: [M]
    public var padding: CGFloat?

    public init(selectedItem: Binding<M>, items: [M], padding: CGFloat? = nil) {
        self._selectedItem = selectedItem
        self.items = items
        self.padding = padding
    }

    public var body: some View {
        HStack {
            HStack {
                ForEach(items, id: \.id) { item in
                    buildItem(item)
                }
            }
            .padding(.all, padding ?? 4)
        }
        .background(theme.cardColor)
        .cornerRadius(12)
    }

    private func buildItem(_ item: M) -> some View {
        AppCardView(
            padding: 8,
            radius: 10,
            backgroundColor: item == selectedItem ? theme.btnColor : .white
        ) {
            HStack {
                Text(item.label)
                    .themed(style: theme.textThemeT1.light.copyWith(color: item == selectedItem ? .white : nil))
                    .lineLimit(1)
            }
            .widthExpanded()
        }
        .onFullTapGesture {
            selectedItem = item
        }
    }
}
