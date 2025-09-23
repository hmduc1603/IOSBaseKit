//
//  OpenAdViewModifiler.swift
//  Delta
//
//  Created by Dennis Hoang on 16/09/2024.
//  Copyright © 2024 AppVantage. All rights reserved.
//

import Foundation
import SwiftUI

public struct OpenAdViewModifiler: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var didEnterBG = false

    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    print("OpenAdViewModifiler: App did became active")
                    if didEnterBG {
                        didEnterBG = false
                        AdmobService.shared.showOpenAd()
                    }
                case .inactive:
                    print("OpenAdViewModifiler: App is inactive")
                case .background:
                    print("OpenAdViewModifiler: App is in background")
                    didEnterBG = true
                default:
                    break
                }
            }
    }
}
