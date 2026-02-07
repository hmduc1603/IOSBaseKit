#if os(iOS)
//
//  SnackBarView.swift
//  magiclight
//
//  Created by Dennis Hoang on 16/8/25.
//

import SwiftUI

public struct SnackBarView: View {
    @Environment(\.theme) private var theme
    @State private var showSnackBar: Bool = false
    @State private var snackBarMessage: String = ""

    public var body: some View {
        VStack {
            Spacer()
            if showSnackBar {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text(snackBarMessage)
                            .themed(style: theme.textThemeT1.light)
                            .multilineTextAlignment(.center)
                            .widthExpanded()
                            .bottomSafeArea()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(theme.btnColor)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .onReceive(EvenBusManager.shared.subscribe(for: AppSnackBarEvent.self), perform: { event in
            snackBarMessage = event.message
            withAnimation {
                showSnackBar = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSnackBar = false
                }
            }
        })
    }
}

public extension View {
    func snackbar(
        isShowing: Binding<Bool>,
        message: @escaping () -> String
    ) -> some View {
        modifier(SnackbarModifier(isShowing: isShowing, message: message))
    }
}

public extension View {
    func observeSnackBar() -> some View {
        overlay(SnackBarView())
    }
}
#endif
