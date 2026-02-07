#if os(iOS)
//
//  ApplicationExtension.swift
//  renoteai
//
//  Created by Dennis Hoang on 31/08/2024.
//

import Foundation
import UIKit

public extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}
#endif
