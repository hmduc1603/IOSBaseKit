//
//  SheetPickerModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 4/9/25.
//

import SwiftUI

public protocol ItemLabelProtocol {
    var label: String { get }
}

#if os(iOS)
public struct SheetPickerModifier<M: Hashable & ItemLabelProtocol>: ViewModifier {
    @Environment(\.theme) private var theme

    @Binding public var showingPicker: Bool
    @Binding public var selectedItem: M
    public var items: [M]
    public var title: String

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingPicker) {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showingPicker = false
                        } label: {
                            Text("Done")
                                .themed(style: theme.textThemeT1.button.copyWith(color: theme.btnColor))
                        }
                        .padding()
                    }

                    Picker(title, selection: $selectedItem) {
                        ForEach(items, id: \.self) { item in
                            Text(item.label)
                                .themed(style: theme.textThemeT1.title)
                        }
                    }
                    .pickerStyle(.wheel) /// wheel style picker
                    .labelsHidden()
                }
                .presentationDetents([.fraction(0.3), .medium]) /// iOS 16+
                .presentationBackground(theme.primary)
            }
    }
}

public extension View {
    func sheetPicker<M: Hashable & ItemLabelProtocol>(
        showingPicker: Binding<Bool>,
        selectedItem: Binding<M>,
        items: [M],
        title: String
    ) -> some View {
        modifier(SheetPickerModifier(
            showingPicker: showingPicker, selectedItem: selectedItem, items: items, title: title
        ))
    }
}
#endif
