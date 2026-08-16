#if os(iOS)
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

    private var bannerId: String?
    private var appOpenId: String?
    private var appOpenHighFloorId: String?
    private var interstitialHighFloorId: String?
    private var rewardId: String?
    private var rewardHighFloorId: String?
    private var interstitialId: String?

    private var interstitialAd: InterstitialAd?
    private var interstitialHighFloorAd: InterstitialAd?
    private var adDelegate: AdDelegate?
    private var openAd: AppOpenAd?
    private var openHighFloorAd: AppOpenAd?
    private var rewardedAd: RewardedAd?
    private var rewardedHighFloorAd: RewardedAd?

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

        if config.forceTestAd == true {
            print("AdmobService: Force Test Ad!")
            appOpenId = AdUnitConfig.getDebugAdUnitConfig().appOpenId
            interstitialId = AdUnitConfig.getDebugAdUnitConfig().interstitialId
            bannerId = AdUnitConfig.getDebugAdUnitConfig().bannerId
            rewardId = AdUnitConfig.getDebugAdUnitConfig().rewardId
            appOpenHighFloorId = AdUnitConfig.getDebugAdUnitConfig().appOpenHighFloorId   
            interstitialHighFloorId = AdUnitConfig.getDebugAdUnitConfig().interstitialHighFloorId
            rewardHighFloorId = AdUnitConfig.getDebugAdUnitConfig().rewardHighFloorId
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
        let adUnitId = interstitialId ?? AdUnitConfig.getAdUnitConfig().interstitialId
        let highFloorAdUnitId = interstitialHighFloorId ?? AdUnitConfig.getAdUnitConfig().interstitialHighFloorId

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withUnsafeContinuation { continuation in
                    InterstitialAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                        if let error {
                            print("Failed to load interstitial ad: \(error)")
                        } else {
                            print("AdmobService: Preloaded Interstitial Ad!")
                            self?.interstitialAd = ad
                        }
                        continuation.resume()
                    }
                }
            }

            if let highFloorId = highFloorAdUnitId, !highFloorId.isEmpty {
                group.addTask {
                    await withUnsafeContinuation { continuation in
                        InterstitialAd.load(with: highFloorId, request: Request()) { [weak self] ad, error in
                            if let error {
                                print("Failed to load High Floor interstitial ad: \(error)")
                            } else {
                                print("AdmobService: Preloaded High Floor Interstitial Ad!")
                                self?.interstitialHighFloorAd = ad
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Preload Rewarded Ad

    public func preloadRewardedAd() async {
        guard config?.enableRewardAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        let adUnitId = rewardId ?? AdUnitConfig.getAdUnitConfig().rewardId
        let highFloorAdUnitId = rewardHighFloorId ?? AdUnitConfig.getAdUnitConfig().rewardHighFloorId

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withUnsafeContinuation { continuation in
                    RewardedAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                        if let error {
                            print("Failed to load rewarded ad: \(error.localizedDescription)")
                        } else {
                            print("AdmobService: Preloaded Rewarded Ad!")
                            self?.rewardedAd = ad
                        }
                        continuation.resume()
                    }
                }
            }

            if let highFloorId = highFloorAdUnitId, !highFloorId.isEmpty {
                group.addTask {
                    await withUnsafeContinuation { continuation in
                        RewardedAd.load(with: highFloorId, request: Request()) { [weak self] ad, error in
                            if let error {
                                print("Failed to load High Floor rewarded ad: \(error.localizedDescription)")
                            } else {
                                print("AdmobService: Preloaded High Floor Rewarded Ad!")
                                self?.rewardedHighFloorAd = ad
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }

    @MainActor public func forceShowRewardedAd(completion: @Sendable @escaping (Bool) -> Void) async {
        guard config?.enableRewardAd == true, !UserDefaults.standard.isPremium else {
            return
        }
        await preloadRewardedAd()
        await showRewardedAd(completion: completion)
    }

    // MARK: - Show Rewarded Ad

    @MainActor
    public func showRewardedAd(autoPreload: Bool = true, completion: @escaping (Bool) -> Void) {
        guard config?.enableRewardAd == true, !UserDefaults.standard.isPremium else {
            completion(false)
            return
        }

        guard let ad = rewardedHighFloorAd ?? rewardedAd else {
            print("Rewarded ad not ready")
            completion(false)
            return
        }
        rewardedAd = nil
        rewardedHighFloorAd = nil

        ad.fullScreenContentDelegate = AdDelegate(
            onAdDismissed: {
                print("Rewarded ad dismissed")
            },
            onAdFailedToPresent: { [weak self] error in
                print("Rewarded ad failed to present: \(error.localizedDescription)")
                if autoPreload {
                    Task { await self?.preloadRewardedAd() }
                }
                completion(false)
            }
        )
        ad.present(from: UIApplication.shared.connectedScenes.first?.inputViewController) {
            if autoPreload {
                Task { await self.preloadRewardedAd() }
            }
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
        let adUnitId = appOpenId ?? AdUnitConfig.getAdUnitConfig().appOpenId
        let highFloorAdUnitId = appOpenHighFloorId ?? AdUnitConfig.getAdUnitConfig().appOpenHighFloorId

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withUnsafeContinuation { continuation in
                    AppOpenAd.load(with: adUnitId, request: Request()) { [weak self] ad, error in
                        if let error {
                            print("Failed to load Open ad: \(error)")
                        } else {
                            print("AdmobService: Preloaded Open Ad!")
                            self?.openAd = ad
                        }
                        continuation.resume()
                    }
                }
            }

            if let highFloorId = highFloorAdUnitId, !highFloorId.isEmpty {
                group.addTask {
                    await withUnsafeContinuation { continuation in
                        AppOpenAd.load(with: highFloorId, request: Request()) { [weak self] ad, error in
                            if let error {
                                print("Failed to load High Floor Open ad: \(error)")
                            } else {
                                print("AdmobService: Preloaded High Floor Open Ad!")
                                self?.openHighFloorAd = ad
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }

    public func showInterstitial(completion: @escaping () -> Void) {
        guard config?.enableInterstitialAd == true, !UserDefaults.standard.isPremium else {
            completion()
            return
        }
        print("AdmobService: showInterstitial")
        AdsCountingManager.shared.checkShouldShowAds { [weak self] shouldShow in
            guard let self = self else {
                completion()
                return
            }
            if shouldShow {
                if let interstitial = self.interstitialHighFloorAd ?? self.interstitialAd {
                    // Set up the custom delegate
                    self.adDelegate = AdDelegate(
                        onAdDismissed: { [weak self] in
                            print("Ad was dismissed, calling completion.")
                            Analytics.logEvent("did_show_interstitial_ad", parameters: nil)
                            self?.interstitialAd = nil
                            self?.interstitialHighFloorAd = nil
                            completion()
                            self?.preloadInterstitialSync()
                        },
                        onAdFailedToPresent: { [weak self] error in
                            print("Ad failed to present: \(error.localizedDescription)")
                            Analytics.logEvent("failed_show_interstitial_ad", parameters: nil)
                            self?.interstitialAd = nil
                            self?.interstitialHighFloorAd = nil
                            completion()
                            self?.preloadInterstitialSync()
                        }
                    )
                    interstitial.fullScreenContentDelegate = self.adDelegate
                    DispatchQueue.main.async {
                        interstitial.present(from: UIApplication.shared.connectedScenes.first?.inputViewController)
                    }
                } else {
                    print("Interstitial ad is not ready.")
                    self.interstitialAd = nil
                    self.interstitialHighFloorAd = nil
                    completion()
                    self.preloadInterstitialSync()
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
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let safeContinuation = SafeCheckedContinuation(continuation)
            if let open = openHighFloorAd ?? openAd {
                adDelegate = AdDelegate(
                    onAdDismissed: { [weak self] in
                        print("Ad was dismissed, calling completion.")
                        Analytics.logEvent("did_show_open_ad", parameters: nil)
                        self?.openAd = nil
                        self?.openHighFloorAd = nil
                        self?.preloadOpenSync()
                        safeContinuation.resume(returning: ())
                    },
                    onAdFailedToPresent: { [weak self] error in
                        Analytics.logEvent("failed_to_show_open_ad", parameters: nil)
                        print("Ad failed to present: \(error.localizedDescription)")
                        self?.openAd = nil
                        self?.openHighFloorAd = nil
                        self?.preloadOpenSync()
                        safeContinuation.resume(returning: ())
                    }
                )
                open.fullScreenContentDelegate = adDelegate
                DispatchQueue.main.async {
                    open.present(from: UIApplication.shared.connectedScenes.first?.inputViewController)
                }
            } else {
                print("Open ad is not ready.")
                safeContinuation.resume(returning: ())
            }
        }
    }

    public func showOpenAd(completion: (() -> Void)? = nil) {
        guard config?.enableOpenAd == true, !UserDefaults.standard.isPremium else {
            completion?()
            return
        }
        print("AdmobService: showOpenAd")
        if let open = openHighFloorAd ?? openAd {
            adDelegate = AdDelegate(
                onAdDismissed: {
                    print("Ad was dismissed, calling completion.")
                    Analytics.logEvent("did_show_open_ad", parameters: nil)
                    self.openAd = nil
                    self.openHighFloorAd = nil
                    self.preloadOpenSync()
                    completion?()
                },
                onAdFailedToPresent: { error in
                    print("Ad failed to present: \(error.localizedDescription)")
                    Analytics.logEvent("failed_to_show_open_ad", parameters: nil)
                    self.openAd = nil
                    self.openHighFloorAd = nil
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
        if let onDismissed = onAdDismissed {
            self.onAdDismissed = nil
            self.onAdFailedToPresent = nil
            onDismissed()
        }
    }

    // Called when the ad fails to present
    func ad(_: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        if let onFailed = onAdFailedToPresent {
            self.onAdDismissed = nil
            self.onAdFailedToPresent = nil
            onFailed(error)
        }
    }
}

// A thread-safe wrapper to ensure CheckedContinuation is resumed exactly once.
private final class SafeCheckedContinuation<T: Sendable, E: Error>: @unchecked Sendable {
    private var continuation: CheckedContinuation<T, E>?
    private let lock = NSLock()

    init(_ continuation: CheckedContinuation<T, E>) {
        self.continuation = continuation
    }

    func resume(returning value: T) {
        lock.lock()
        defer { lock.unlock() }
        if let continuation = self.continuation {
            self.continuation = nil
            continuation.resume(returning: value)
        }
    }

    func resume(throwing error: E) {
        lock.lock()
        defer { lock.unlock() }
        if let continuation = self.continuation {
            self.continuation = nil
            continuation.resume(throwing: error)
        }
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
#endif
