//
//  AppPremiumIconView.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import SwiftUI

public struct AppPremiumIconView: View {
    @AppStorage(UserDefaults.Key.isPremium.rawValue) private var isPremium: Bool = false

    public var iconString: String
    public var onPremiumTapped: (() -> Void)?

    public init(iconString: String, onPremiumTapped: (() -> Void)? = nil) {
        self.iconString = iconString
        self.onPremiumTapped = onPremiumTapped
    }

    public var body: some View {
        if !isPremium {
            Button {
                onPremiumTapped?() ?? showSubscriptionView()
            } label: {
                Image(iconString)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 28, height: 28)
            }
        }
    }
}
