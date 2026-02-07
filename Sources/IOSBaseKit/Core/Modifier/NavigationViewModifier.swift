//
//  NavigationViewModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import FirebaseAnalytics
import SwiftUI

public class Navigator: ObservableObject {
    @Published public var path = NavigationPath()

    @MainActor
    public func push<V>(_ value: V) where V: Hashable {
        Analytics.logEvent(String(reflecting: V.self), parameters: nil)
        path.append(value)
    }

    @MainActor
    public func popAndPush<V>(_ value: V) where V: Hashable {
        Task { @MainActor in
            pop()
            try? await Task.sleep(for: .milliseconds(500))
            push(value)
        }
    }

    @MainActor
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

public struct NavigationViewModifier: ViewModifier {
    @StateObject private var navigator = Navigator()
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        NavigationStack(path: $navigator.path) {
            content
                .background(theme.primary)
        }
        .environmentObject(navigator)
    }
}

public extension View {
    func enableNavigationStack() -> some View {
        modifier(NavigationViewModifier())
    }
}

public struct NavigationBarViewModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigator: Navigator

    public var title: String
    public var trailingTitle: String?
    public var onTrailingTap: (() -> Void)? = nil

    private func enableSwipeBack() {
        #if os(iOS)
        /// Grab the underlying UINavigationController
        if let root = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController
        {
            if let nav = findNavController(from: root) {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        #endif
    }

    #if os(iOS)

    private func findNavController(from vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController {
            return nav
        }
        for child in vc.children {
            if let found = findNavController(from: child) {
                return found
            }
        }
        return nil
    }
    #endif

    public func body(content: Content) -> some View {
        content
            .onAppear {
                enableSwipeBack()
            }
            .navigationBarBackButtonHidden()
            .toolbarRole(.editor)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
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
                #else
                ToolbarItem(placement: .navigation) {
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
                #endif
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .themed(style: theme.textThemeT1.body.copyWith(weight: .bold))
                }
                #if os(iOS)
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
                #else
                ToolbarItem(placement: .automatic) {
                    if let title = trailingTitle {
                        Button {
                            onTrailingTap?()
                        } label: {
                            Text(title)
                                .themed(style: theme.textThemeT1.title.copyWith(color: theme.btnColor))
                        }
                    }
                }
                #endif
            }
    }
}

public extension View {
    func setupNavigationBar(
        title: String,
        trailingTitle: String? = nil,
        onTrailingTap: (() -> Void)? = nil
    ) -> some View {
        modifier(NavigationBarViewModifier(title: title, trailingTitle: trailingTitle, onTrailingTap: onTrailingTap))
    }

    func setupCustomNavigationBar(
        title: String,
        trailing: @escaping () -> some View
    ) -> some View {
        modifier(CustomNavigationBarViewModifier(title: title, trailing: trailing))
    }
}

public struct CustomNavigationBarViewModifier<Trailing: View>: ViewModifier {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigator: Navigator

    public var title: String
    public var trailing: () -> Trailing

    private func enableSwipeBack() {
        #if os(iOS)
        /// Grab the underlying UINavigationController
        if let root = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController
        {
            if let nav = findNavController(from: root) {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        #endif
    }

    #if os(iOS)

    private func findNavController(from vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController {
            return nav
        }
        for child in vc.children {
            if let found = findNavController(from: child) {
                return found
            }
        }
        return nil
    }
    #endif

    public func body(content: Content) -> some View {
        content
            .onAppear {
                enableSwipeBack()
            }
            .navigationBarBackButtonHidden()
            .toolbarRole(.editor)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
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
                #else
                ToolbarItem(placement: .navigation) {
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
                #endif
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .themed(style: theme.textThemeT1.body.copyWith(weight: .bold))
                }
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    trailing()
                }
                #else
                ToolbarItem(placement: .automatic) {
                    trailing()
                }
                #endif
            }
    }
}
