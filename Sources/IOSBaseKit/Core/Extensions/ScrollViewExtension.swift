#if os(iOS)
//
//  ScrollViewExtension.swift
//  lgremote
//
//  Created by Dennis Hoang on 30/09/2024.
//

import Combine
import Foundation
import SwiftUI

public struct ScrollOnKeyboardViewModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    public var scrollToID: String

    public func body(content: Content) -> some View {
        ScrollViewReader { scrollViewProxy in
            content
                .onChange(of: keyboardHeight) { _, newValue in
                    if newValue > 0 {
                        scrollViewProxy.scrollTo(scrollToID)
                    }
                }
        }.onAppear {
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

public extension View {
    func scrollToBottomOnKeyboard(scrollToID: String) -> some View {
        modifier(ScrollOnKeyboardViewModifier(scrollToID: scrollToID))
    }
}
#endif
