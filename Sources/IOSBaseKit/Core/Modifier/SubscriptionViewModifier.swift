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
                        products: PurchaseService.shared.packages,
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
                        products: PurchaseService.shared.introPackages,
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
                VStack(spacing: 20) {
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
                                    .frame(width: 80, height: 80)
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
                                .frame(width: 80, height: 80)
                        }
                        .padding(.all, 15)
                    }
                    Text("Get Premium")
                        .themed(style: theme.textThemeT1.header1
                            .copyWith(color: theme.btnColor)
                        )
                        .padding(.top, 20)
                    buildFeatureList()
                    Spacer()
                    content($showLoading)
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

    @State private var selectedProduct: SubscriptionPackage?
    @State private var isTrialEnable: Bool = true

    public var isIntroSub: Bool
    public var products: [SubscriptionPackage]
    @Binding public var showLoading: Bool

    private func buildTrialToogleView() -> some View {
        HStack {
            HStack {
                Text("Free Trial Enabled")
                    .font(Font.system(size: 15, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
                Toggle("", isOn: $isTrialEnable)
                    .tint(theme.btnColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 0)
        .disabled(selectedProduct?.remoteProduct.hasTrial == false)
        .opacity(selectedProduct?.remoteProduct.hasTrial == true ? 1 : 0.2)
    }

    public var body: some View {
        VStack(spacing: 15) {
            ScrollView {
                ForEach(products, id: \.remoteProduct.productId) { item in
                    buildItemRow(item: item)
                }
            }
            .heightExpanded()
            VStack(spacing: 12) {
                if products.contains(where: { $0.remoteProduct.trialProductId != nil }) {
                    buildTrialToogleView()
                }
                AppPrimaryButton(
                    buttonTitle: "Continue")
                {
                    Task { @MainActor in
                        guard let product = selectedProduct else {
                            return
                        }
                        showLoading = true
                        var finalStoreProduct = product.storeProduct
                        if product.remoteProduct.hasTrial && isTrialEnable,
                           let trialProductId = product.remoteProduct.trialProductId,
                           let trialStoreProduct = try? await Product.products(for: [trialProductId]).first
                        {
                            /// Get trial product
                            finalStoreProduct = trialStoreProduct
                        }
                        if await PurchaseService.shared.purchase(
                            product: finalStoreProduct,
                            isIntroSub: isIntroSub
                        ) {
                            dismiss()
                        }
                        showLoading = false
                    }
                }
                if let selectedProduct = selectedProduct,
                   selectedProduct.storeProduct.type == .autoRenewable
                {
                    Text("Plan automatically renews for \(selectedProduct.storeProduct.displayPrice) until cancelled")
                        .themed(style: theme.textThemeT1.small.copyWith(
                            color: .black.opacity(0.5)
                        ))
                }
            }
        }
        .onAppear {
            selectedProduct = PurchaseService.shared.introPackages.first
        }
    }

    private func buildItemRow(item: SubscriptionPackage) -> some View {
        func buildYearlyRow(item: SubscriptionPackage) -> some View {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.storeProduct.displayName)
                        .themed(style: theme.textThemeT1.title
                            .copyWith(color: .black)
                        )
                    Text(item.storeProduct.displayPrice)
                        .font(Font.system(size: 12, design: .rounded).weight(.light))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.storeProduct.priceFormatStyle.format(item.storeProduct.price / 12))
                        .font(Font.system(size: 15, design: .rounded).weight(.bold))
                        .foregroundColor(.black)
                    Text("per month")
                        .font(Font.system(size: 12, design: .rounded).weight(.light))
                        .foregroundColor(.gray)
                }
            }
        }

        func buildNormalRow(item: SubscriptionPackage) -> some View {
            HStack {
                Text(item.storeProduct.displayName)
                    .themed(style: theme.textThemeT1.title
                        .copyWith(color: .black)
                    )
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.storeProduct.displayPrice)
                        .font(Font.system(size: 15, design: .rounded).weight(.bold))
                        .foregroundColor(.black)
                    if let desc = item.remoteProduct.priceDesc {
                        Text(desc)
                            .font(Font.system(size: 12, design: .rounded).weight(.light))
                            .foregroundColor(.gray)
                    }
                }
            }
        }

        func buildFreeTrialRow(item: SubscriptionPackage) -> some View {
            HStack {
                Text("\(item.remoteProduct.trialDays ?? 3) days free")
                    .themed(style: theme.textThemeT1.title
                        .copyWith(color: .black)
                    )
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack {
                        Text("then")
                            .font(Font.system(size: 12, design: .rounded).weight(.light))
                            .foregroundColor(.gray)
                        Text(item.storeProduct.displayPrice)
                            .font(Font.system(size: 15, design: .rounded).weight(.bold))
                            .foregroundColor(.black)
                    }
                    if let desc = item.remoteProduct.priceDesc {
                        Text(desc)
                            .font(Font.system(size: 12, design: .rounded).weight(.light))
                            .foregroundColor(.gray)
                    }
                }
            }
        }

        return HStack {
            HStack {
                VStack {
                    if item.remoteProduct.isYearly {
                        buildYearlyRow(item: item)
                    } else {
                        if item.remoteProduct.hasTrial && isTrialEnable {
                            buildFreeTrialRow(item: item)
                        } else {
                            buildNormalRow(item: item)
                        }
                    }
                }
                .widthExpanded()
                .padding(.horizontal, 15)
                .padding(.vertical, 18)
            }
            .background(.white)
            .cornerRadiusWithBorder(
                radius: 12,
                borderLineWidth: item == selectedProduct ? 2.5 : 0,
                borderColor: theme.btnColor,
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 0)
            .onTapGesture {
                selectedProduct = item
            }
        }
        .padding(.horizontal, 4)
    }
}
