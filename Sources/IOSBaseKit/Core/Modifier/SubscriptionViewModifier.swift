//
//  SubscriptionViewModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 16/8/25.
//

import Factory
import StoreKit
import SwiftUI

public struct SubscriptionViewModifier: ViewModifier {
    @Environment(\.theme) private var theme

    @State private var shouldShowSubScreen: Bool = false
    @State private var shouldIntroShowSubScreen: Bool = false

    public func body(content: Content) -> some View {
        content
            .onReceive(EvenBusManager.shared.subscribe(for: ShowSubscriptionViewEvent.self),
                       perform: { _ in
                           shouldShowSubScreen = true
                       })
            .onReceive(EvenBusManager.shared.subscribe(for: ShowIntroSubscriptionViewEvent.self),
                       perform: { _ in
                           shouldIntroShowSubScreen = true
                       })
            .sheet(
                isPresented: $shouldShowSubScreen,
            ) {
                SubscriptionFrameView { showLoading in
                    SubscriptionPickerView(
                        isIntroSub: false,
                        packages: PurchaseService.shared.packages,
                        showLoading: showLoading
                    )
                }
            }
            .sheet(
                isPresented: $shouldIntroShowSubScreen,
            ) {
                SubscriptionFrameView { showLoading in
                    SubscriptionPickerView(
                        isIntroSub: true,
                        packages: PurchaseService.shared.introPackages,
                        showLoading: showLoading
                    )
                }
            }
    }
}

public extension View {
    func enableSubscriptionStoreView() -> some View {
        modifier(SubscriptionViewModifier())
    }

    func showSubscriptionView() {
        EvenBusManager.shared.fire(event: ShowSubscriptionViewEvent())
    }

    func showIntroSubscriptionView() {
        EvenBusManager.shared.fire(event: ShowIntroSubscriptionViewEvent())
    }
}

private struct SubscriptionFrameView<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var showLoading: Bool = false
    @ViewBuilder var content: (_ showLoading: Binding<Bool>) -> Content

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    LinearGradient(
                        colors: AppColor.shared.subscriptionGradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .widthExpanded()
                    .frame(height: proxy.frame(in: .global).height * 0.7)
                    Spacer()
                }
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 26, height: 26)
                                .foregroundColor(AppColor.shared.subscriptionCloseButtonColor)
                        }
                    }
                    .padding(.top, 20)
                    ZStack {
                        VStack {
                            VStack {
                                VStack {}
                                    .frame(width: 60, height: 60)
                            }
                            .padding(.all, 15)
                        }
                        .background(AppColor.shared.subscriptionIconBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .rotationEffect(.degrees(25))
                        VStack {
                            Image("ic_app")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 60, height: 60)
                        }
                        .padding(.all, 15)
                    }
                    Text("Get Premium")
                        .themed(style: theme.textThemeT1.header1
                            .copyWith(color: theme.btnColor)
                        )
                        .padding(.top, 20)
                    buildFeatureList()
                        .padding(.bottom, 10)
                    content($showLoading)
                        .expanded()
                }
                .padding(.horizontal, 20)
                if showLoading {
                    AppLoadingHUD(message: "Purchasing...")
                }
            }
            .background(.white)
        }
    }

    private func buildFeatureList() -> some View {
        VStack(spacing: 5) {
            ForEach(RemoteConfigServiceImpl.shared.iosProducts.features, id: \.self) { item in
                Text(item)
                    .themed(style: theme.textThemeT1.title)
            }
        }
    }
}

public struct SubscriptionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme

    @State private var selectedPackage: SubscriptionPackage?

    public var isIntroSub: Bool
    public var packages: [SubscriptionPackage]
    @Binding public var showLoading: Bool

    public var body: some View {
        VStack(spacing: 15) {
            ScrollView {
                ForEach(packages, id: \.storeProduct) { item in
                    buildItemRow(item: item)
                }
            }
            .heightExpanded()
            VStack {
                if let selectedPackage = selectedPackage,
                   selectedPackage.storeProduct.type == .autoRenewable
                {
                    Text("Plan automatically renews for \(selectedPackage.storeProduct.displayPrice) until cancelled")
                        .themed(style: theme.textThemeT1.small.copyWith(
                            color: .black.opacity(0.5)
                        ))
                }
                AppPrimaryButton(
                    buttonTitle: selectedPackage?.remoteProduct.hasTrial == true ? "Get 3 Days Free" : "Continue")
                {
                    Task { @MainActor in
                        guard let product = selectedPackage?.storeProduct else {
                            return
                        }
                        showLoading = true
                        if await PurchaseService.shared.purchase(product: product, isIntroSub: isIntroSub) {
                            dismiss()
                        }
                        showLoading = false
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            selectedPackage = PurchaseService.shared.packages.last
        }
    }

    private func buildItemRow(item: SubscriptionPackage) -> some View {
        HStack {
            HStack {
                VStack {
                    HStack {
                        VStack(spacing: 4) {
                            Text(item.storeProduct.displayName)
                                .themed(style: theme.textThemeT1.title
                                    .copyWith(color: .black)
                                )
                                .leadingFullWidth()
                            Text(item.storeProduct.displayPrice)
                                .themed(style: theme.textThemeT1.body
                                    .copyWith(color: .black)
                                )
                                .leadingFullWidth()
                        }
                        Image(
                            systemName: item == selectedPackage ? "checkmark.circle.fill" : "circle"
                        )
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(theme.btnColor)
                        .frame(width: 20, height: 20)
                    }
                    Divider()
                        .foregroundColor(.black.opacity(1))
                    Text(item.storeProduct.description)
                        .themed(style: theme.textThemeT1.body
                            .copyWith(color: .gray)
                        )
                        .leadingFullWidth()
                }
                .widthExpanded()
                .padding(.all, 15)
            }
            .background(.white)
            .cornerRadiusWithBorder(
                radius: 12,
                borderLineWidth: item == selectedPackage  ? 2 : 0,
                borderColor: theme.btnColor,
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 0)
            .onTapGesture {
                selectedPackage = item
            }
        }
        .padding(.horizontal, 4)
    }
}
