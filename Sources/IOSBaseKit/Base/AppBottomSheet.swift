//
//  AppBottomSheet.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

struct AppBottomSheet<Content: View>: View {
    @Environment(\.theme) private var theme: AppTheme
    @Binding var isPresented: Bool
    var sheetColor: Color? = nil
    var cornerRadius: CGFloat = 20
    let content: Content

    init(
        isPresented: Binding<Bool>,
        sheetColor: Color? = nil,
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content)
    {
        self._isPresented = isPresented
        self.sheetColor = sheetColor
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Dim background
            if isPresented {
                Color.black.opacity(0.5)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .ignoresSafeArea()
                // Bottom sheet
                VStack {
                    Spacer()
                    content
                        .background(sheetColor ?? theme.primary)
                        .cornerRadius(cornerRadius)
                }.transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea()
        .expanded()
        .animation(.easeInOut(duration: 0.4), value: isPresented)
    }
}
