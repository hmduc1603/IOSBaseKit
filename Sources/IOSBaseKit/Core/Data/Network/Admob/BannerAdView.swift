#if os(iOS)
//
//  BannerAds.swift
//  renoteai
//
//  Created by Dennis Hoang on 29/08/2024.
//

import Factory
import GoogleMobileAds
import SwiftUI
import UIKit

public struct BannerAdView: View {
    public var body: some View {
        VStack {
            BannerAdViewWrapper()
                .widthExpanded()
                .frame(height: AdSizeFullBanner.size.height)
        }
        .frame(height: AdSizeFullBanner.size.height)
    }
}

private struct BannerAdViewWrapper: UIViewRepresentable {
    func makeUIView(context _: Context) -> BannerView {
        guard AdmobService.shared.config?.enableBannerAd == true else {
            print("Banner Ad is not enable by remote config")
            return BannerView(frame: CGRect.zero)
        }
        let adUnitId = AdUnitConfig.getAdUnitConfig().bannerId
        let bannerView = BannerView(adSize: AdSizeFullBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = UIApplication.shared.connectedScenes.first?.inputViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context _: Context) {
        uiView.load(Request())
    }
}
#endif
