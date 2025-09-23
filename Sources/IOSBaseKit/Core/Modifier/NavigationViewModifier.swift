//
//  NavigationViewModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import FirebaseAnalytics
import SwiftUI

class Navigator: ObservableObject {
    @Published var path = NavigationPath()

    @MainActor
    func push<V>(_ value: V) where V: Hashable {
        Analytics.logEvent(String(reflecting: V.self), parameters: nil)
        path.append(value)
    }

    @MainActor
    func popAndPush<V>(_ value: V) where V: Hashable {
        Task { @MainActor in
            pop()
            try? await Task.sleep(for: .milliseconds(500))
            push(value)
        }
    }

    @MainActor
    func pop() {
        path.removeLast()
    }
}

struct NavigationViewModifier: ViewModifier {
    @StateObject private var navigator = Navigator()
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        NavigationStack(path: $navigator.path) {
            content
                .background(theme.primary)
        }
        .environmentObject(navigator)
    }
}

extension View {
    func enableNavigationStack() -> some View {
        modifier(NavigationViewModifier())
    }
}

struct NavigationBarViewModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigator: Navigator

    var title: String
    var trailingTitle: String?
    var onTrailingTap: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigator.path.removeLast()
                    }) {
                        Image("ic_back")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 26, height: 26)
                            .foregroundColor(theme.btnColor)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .themed(style: theme.textThemeT1.body.copyWith(weight: .bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let title = trailingTitle {
                        Button {
                            onTrailingTap?()
                        } label: {
                            Text(title)
                                .themed(style: theme.textThemeT1.title.copyWith(color: theme.btnColor))
                        }
                    }
                }
            }
    }
}

extension View {
    func setupNavigationBar(
        title: String,
        trailingTitle: String? = nil,
        onTrailingTap: (() -> Void)? = nil
    ) -> some View {
        modifier(NavigationBarViewModifier(title: title, trailingTitle: trailingTitle, onTrailingTap: onTrailingTap))
    }
}

// MARK: Enable swipe gesture to back

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && presentedViewController == nil
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
