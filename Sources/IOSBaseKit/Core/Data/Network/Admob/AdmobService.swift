//
//  AdmobService.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import AppTrackingTransparency
import Combine
import Factory
import FirebaseAnalytics
import Foundation
@preconcurrency import GoogleMobileAds
@preconcurrency import UserMessagingPlatform

public class AdmobService: @unchecked Sendable {
    public static let shared = AdmobService()

    public var config: AdConfig?

    private var interstitialAd: InterstitialAd?
    private var adDelegate: AdDelegate?
    private var openAd: AppOpenAd?
    private var rewardedAd: RewardedAd?

    public func setup(_ config: AdConfig) async throws {
        print("AdmobService: setup")
        guard !UserDefaults.standard.isPremium else {
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            MobileAds.shared.start { _ in
                // No explicit error handling provided by the GADMobileAds API.
                // Call continuation.resume() to indicate the async operation is complete.
                continuation.resume()
            }
        }

        /// Show consent form first
        await requestConsentForm()

        self.config = config
        if !UserDefaults.standard.isPremium {
            await preloadAppOpenAd()
            Task {
                await preloadInterstitial()
                await preloadRewardedAd()
            }
        }
    }

    public func preloadInterstitialSync() {
        Task {
            await preloadInterstitial()
        }
    }

    public func preloadInterstitial() async {
        guard config?.enableInterstitialAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        let adUnitId = AdUnitConfig.getAdUnitConfig().interstitialId
        await withUnsafeContinuation { continuation in
            InterstitialAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                if let error {
                    print("Failed to load interstitial ad: \(error)")
                    continuation.resume()
                    return
                }
                print("AdmobService: Preloaded Interstitial Ad!")
                self?.interstitialAd = ad
                continuation.resume()
            }
        }
    }

    // MARK: - Preload Rewarded Ad

    public func preloadRewardedAd() async {
        guard config?.enableRewardAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        let adUnitId = AdUnitConfig.getAdUnitConfig().rewardId
        await withUnsafeContinuation { continuation in
            RewardedAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                if let error {
                    print("Failed to load rewarded ad: \(error.localizedDescription)")
                    continuation.resume()
                    return
                }
                print("AdmobService: Preloaded Rewarded Ad!")
                self?.rewardedAd = ad
                continuation.resume()
            }
        }
    }

    // MARK: - Show Rewarded Ad

    @MainActor
    public func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard config?.enableRewardAd == true, !UserDefaults.standard.isPremium else {
            completion(false)
            return
        }

        guard let ad = rewardedAd else {
            print("Rewarded ad not ready")
            completion(false)
            return
        }

        ad.fullScreenContentDelegate = AdDelegate(
            onAdDismissed: { [weak self] in
                print("Rewarded ad dismissed")
                Task { await self?.preloadRewardedAd() }
                completion(false)
            },
            onAdFailedToPresent: { [weak self] error in
                print("Rewarded ad failed to present: \(error.localizedDescription)")
                Task { await self?.preloadRewardedAd() }
                completion(false)
            }
        )
        ad.present(from: nil) {
            Task { await self.preloadRewardedAd() }
            completion(true)
        }
    }

    public func preloadOpenSync() {
        do {
            Task {
                await preloadAppOpenAd()
            }
        }
    }

    public func preloadAppOpenAd() async {
        guard config?.enableOpenAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        let adUnitId = AdUnitConfig.getAdUnitConfig().appOpenId
        await withUnsafeContinuation { continuation in
            AppOpenAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                if let error {
                    print("Failed to load Open ad: \(error)")
                    continuation.resume()
                    return
                }
                print("AdmobService: Preloaded Open Ad!")
                self?.openAd = ad
                continuation.resume()
            }
        }
    }

    public func showInterstitial(completion: @escaping () -> Void) {
        guard config?.enableInterstitialAd == true, !UserDefaults.standard.isPremium else {
            completion()
            return
        }
        print("AdmobService: showInterstitial")
        AdsCountingManager.shared.checkShouldShowAds { shouldShow in
            if shouldShow {
                if let interstitial = self.interstitialAd {
                    // Set up the custom delegate
                    self.adDelegate = AdDelegate(
                        onAdDismissed: {
                            print("Ad was dismissed, calling completion.")
                            Analytics.logEvent("did_show_interstitial_ad", parameters: nil)
                            completion()
                            self.preloadInterstitialSync()
                        },
                        onAdFailedToPresent: { error in
                            print("Ad failed to present: \(error.localizedDescription)")
                            Analytics.logEvent("failed_show_interstitial_ad", parameters: nil)
                            completion()
                            self.preloadInterstitialSync()
                        }
                    )
                    interstitial.fullScreenContentDelegate = self.adDelegate
                    DispatchQueue.main.async {
                        interstitial.present(from: UIApplication.shared.connectedScenes.first?.inputViewController)
                    }
                } else {
                    print("Interstitial ad is not ready.")
                }
            } else {
                completion()
                self.preloadInterstitialSync()
            }
        }
    }

    public func showOpenAdAsync() async {
        guard config?.enableOpenAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        print("AdmobService: showOpenAd")
        await withCheckedContinuation { continuation in
            if let open = openAd {
                adDelegate = AdDelegate(
                    onAdDismissed: {
                        print("Ad was dismissed, calling completion.")
                        Analytics.logEvent("did_show_open_ad", parameters: nil)
                        self.preloadOpenSync()
                        continuation.resume()
                    },
                    onAdFailedToPresent: { error in
                        Analytics.logEvent("failed_to_show_open_ad", parameters: nil)
                        print("Ad failed to present: \(error.localizedDescription)")
                        self.preloadOpenSync()
                        continuation.resume()
                    }
                )
                open.fullScreenContentDelegate = adDelegate
                DispatchQueue.main.async {
                    open.present(from: UIApplication.shared.connectedScenes.first?.inputViewController)
                }
            } else {
                print("Open ad is not ready.")
                continuation.resume()
            }
        }
    }

    public func showOpenAd(completion: (() -> Void)? = nil) {
        guard config?.enableOpenAd == true, !UserDefaults.standard.isPremium else {
            completion?()
            return
        }
        print("AdmobService: showOpenAd")
        if let open = openAd {
            adDelegate = AdDelegate(
                onAdDismissed: {
                    print("Ad was dismissed, calling completion.")
                    Analytics.logEvent("did_show_open_ad", parameters: nil)
                    self.preloadOpenSync()
                    completion?()
                },
                onAdFailedToPresent: { error in
                    print("Ad failed to present: \(error.localizedDescription)")
                    Analytics.logEvent("failed_to_show_open_ad", parameters: nil)
                    self.preloadOpenSync()
                    completion?()
                }
            )
            open.fullScreenContentDelegate = adDelegate
            DispatchQueue.main.async {
                open.present(from: UIApplication.shared.connectedScenes.first?.inputViewController)
            }
        } else {
            print("Open ad is not ready.")
            completion?()
        }
    }
}

// Define a custom delegate class to handle interstitial ad events
class AdDelegate: NSObject, FullScreenContentDelegate {
    var onAdDismissed: (() -> Void)?
    var onAdFailedToPresent: ((Error) -> Void)?

    init(onAdDismissed: @escaping () -> Void, onAdFailedToPresent: @escaping (Error) -> Void) {
        self.onAdDismissed = onAdDismissed
        self.onAdFailedToPresent = onAdFailedToPresent
    }

    // Called when the ad is dismissed
    func adDidDismissFullScreenContent(_: FullScreenPresentingAd) {
        print("Ad was dismissed.")
        onAdDismissed?() // Call the provided closure when the ad is dismissed
    }

    // Called when the ad fails to present
    func ad(_: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        onAdFailedToPresent?(error) // Call the provided closure when the ad fails
    }
}

// MARK: Consent

public extension AdmobService {
    func requestConsentForm() async {
        if ConsentInformation.shared.consentStatus == .required {
            return await withCheckedContinuation { continuation in
                // Request consent information
                let parameters = RequestParameters()
                parameters.isTaggedForUnderAgeOfConsent = false
                ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
                    if let error = error {
                        print("Failed to request consent info: \(error.localizedDescription)")
                        continuation.resume()
                        return
                    }

                    // Check if form is available
                    let formStatus = ConsentInformation.shared.formStatus
                    if formStatus == .available {
                        // Load and present the form
                        ConsentForm.load { form, error in
                            if let error = error {
                                print("Failed to load consent form: \(error.localizedDescription)")
                                continuation.resume()
                                return
                            }

                            guard let form = form else {
                                continuation.resume()
                                return
                            }

                            Task { @MainActor in
                                if let windowScene = UIApplication.shared.connectedScenes
                                    .compactMap({ $0 as? UIWindowScene })
                                    .first(where: { $0.activationState == .foregroundActive }),
                                    let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
                                {
                                    form.present(from: rootVC) { dismissError in
                                        if let dismissError = dismissError {
                                            print("Consent form dismissed with error: \(dismissError.localizedDescription)")
                                        } else {
                                            print("Consent form dismissed successfully")
                                        }

                                        let status = ConsentInformation.shared.consentStatus
                                        print("Consent status: \(status.rawValue)")
                                        continuation.resume()
                                    }
                                } else {
                                    continuation.resume()
                                }
                            }
                        }
                    } else {
                        print("Consent form not available")
                        continuation.resume()
                    }
                }
            }
        } else {
            await ATTrackingManager.requestTrackingAuthorization()
        }
    }
}
