//
//  SnackBarView.swift
//  lgremote
//
//  Created by Dennis Hoang on 30/09/2024.
//

import SwiftUI

struct SnackbarModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Binding var isShowing: Bool
    var message: () -> String

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer() // Push the Snackbar to the bottom
                if isShowing {
                    VStack {
                        Text(message())
                            .themed(style: theme.textThemeT1.button)
                            .multilineTextAlignment(.center)
                            .widthExpanded()
                            .bottomSafeArea()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(theme.btnColor)
                    .foregroundColor(theme.textColor)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .onAppear {
                        // Hide Snackbar after 3 seconds
                        Task { @MainActor in
                            try await Task.sleep(for: 3)
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut, value: isShowing)
            .ignoresSafeArea()
        }
    }
}

extension View {
    func snackbar(
        isShowing: Binding<Bool>,
        message: @escaping () -> String
    ) -> some View {
        modifier(SnackbarModifier(isShowing: isShowing, message: message))
    }
}
