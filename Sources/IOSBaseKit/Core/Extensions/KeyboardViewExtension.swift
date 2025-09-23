//
//  KeyboardViewExtension.swift
//  renoteai
//
//  Created by Dennis Hoang on 05/09/2024.
//

import Combine
import Foundation
import SwiftUI

struct KeyboardPushUpViewModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            .padding(.bottom, keyboardHeight).onAppear {
                cancellable = Publishers.Merge(
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                        .map { notification in
                            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
                        },
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in CGFloat(0) }
                )
                .assign(to: \.keyboardHeight, on: self)
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension View {
    func keyboardAutoPushUp() -> some View {
        modifier(KeyboardPushUpViewModifier())
    }

    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
