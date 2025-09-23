//
//  ViewExtension.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI
import UIKit

// MARK: Theme & Size

public extension View {
    func getRootViewCtr() -> UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController
    }

    func expanded() -> some View {
        modifier(ExpandViewModifier(maxWidth: .infinity, maxHeight: .infinity))
    }

    func widthExpanded() -> some View {
        modifier(ExpandViewModifier(maxWidth: .infinity))
    }

    func heightExpanded() -> some View {
        modifier(ExpandViewModifier(maxHeight: .infinity))
    }

    func getBottomSafeArea() -> CGFloat {
        guard let window = UIApplication.shared.firstKeyWindow else { return .init() }
        return window.safeAreaInsets.bottom
    }

    func getTopSafeArea() -> CGFloat {
        guard let window = UIApplication.shared.firstKeyWindow else { return .init() }
        return window.safeAreaInsets.top
    }
}

// MARK: Open Ads

public extension View {
    func showOpenAdOnAppBecomeActive() -> some View {
        modifier(OpenAdViewModifiler())
    }
}
