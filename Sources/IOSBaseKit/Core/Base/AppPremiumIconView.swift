//
//  AppPremiumIconView.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import SwiftUI

struct AppPremiumIconView: View {
    @AppStorage(UserDefaults.Key.isPremium.rawValue) private var isPremium: Bool = false
    
    var iconString: String
    var onPremiumTapped: (() -> Void)?

    var body: some View {
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
