//
//  ViewExtension.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

// MARK: Theme & Size

public extension View {
    #if os(iOS)
    func getRootViewCtr() -> UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController
    }
    #endif


    #if os(iOS)
    func getBottomSafeArea() -> CGFloat {
        guard let window = UIApplication.shared.firstKeyWindow else { return .init() }
        return window.safeAreaInsets.bottom
    }

    func getTopSafeArea() -> CGFloat {
        guard let window = UIApplication.shared.firstKeyWindow else { return .init() }
        return window.safeAreaInsets.top
    }
    #endif
}

// MARK: Open Ads

#if os(iOS)
public extension View {
    func showOpenAdOnAppBecomeActive() -> some View {
        modifier(OpenAdViewModifiler())
    }
}
#endif
