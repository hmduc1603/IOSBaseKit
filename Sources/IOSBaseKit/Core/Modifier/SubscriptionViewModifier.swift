//
//  SubscriptionViewModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 16/8/25.
//

import Factory
import StoreKit
import SwiftUI

struct SubscriptionViewModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Injected(\.purchaseService) private var purchaseService

    @State private var shouldShowSubScreen: Bool = false
    @State private var shouldIntroShowSubScreen: Bool = false

    func body(content: Content) -> some View {
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
                        products: purchaseService.products,
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
                        products: purchaseService.introProducts,
                        showLoading: showLoading
                    )
                }
            }
    }
}

extension View {
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
    @Injected(\.remoteConfigService) private var remoteConfigService
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var showLoading: Bool = false
    @ViewBuilder var content: (_ showLoading: Binding<Bool>) -> Content

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    LinearGradient(
                        colors: [
                            AppColor.gradient1.color,
                            AppColor.gradient2.color,
                            AppColor.gradient3.color,
                            AppColor.gradient3.color.opacity(0.85),
                            AppColor.gradient3.color.opacity(0.65),
                            AppColor.gradient3.color.opacity(0.45),
                            AppColor.gradient3.color.opacity(0.25),
                            AppColor.gradient3.color.opacity(0.1),
                            Color.clear,
                        ],
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
                                .foregroundColor(theme.textColor)
                        }
                    }
                    VStack {
                        VStack {
                            Image("ic_app")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 80, height: 80)
                        }
                        .padding(.all, 15)
                    }
                    .background(theme.textColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .rotationEffect(.degrees(25))
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
            ForEach(remoteConfigService.iosProducts.features, id: \.self) { item in
                Text(item)
                    .themed(style: theme.textThemeT1.title)
            }
        }
    }
}

struct SubscriptionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected(\.purchaseService) private var purchaseService
    @Environment(\.theme) private var theme

    @State private var selectedProduct: Product?

    var isIntroSub: Bool
    var products: [Product]
    @Binding var showLoading: Bool

    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            ForEach(products, id: \.id) { item in
                buildItemRow(item: item)
            }
            VStack {
                if let selectedProduct = selectedProduct,
                   selectedProduct.type == .autoRenewable
                {
                    Text("Plan automatically renews for \(selectedProduct.displayPrice) until cancelled")
                        .themed(style: theme.textThemeT1.small.copyWith(
                            color: .black.opacity(0.5)
                        ))
                }
                AppPrimaryButton(
                    buttonTitle: "Continue")
                {
                    Task { @MainActor in
                        guard let product = selectedProduct else {
                            return
                        }
                        showLoading = true
                        if await purchaseService.purchase(product: product, isIntroSub: isIntroSub) {
                            dismiss()
                        }
                        showLoading = false
                    }
                }
            }
        }
        .onAppear {
            selectedProduct = purchaseService.introProducts.first
        }
    }

    private func buildItemRow(item: Product) -> some View {
        HStack {
            VStack {
                HStack {
                    VStack(spacing: 4) {
                        Text(item.displayName)
                            .themed(style: theme.textThemeT1.title
                                .copyWith(color: .black)
                            )
                            .leadingFullWidth()
                        Text(item.displayPrice)
                            .themed(style: theme.textThemeT1.body
                                .copyWith(color: .black)
                            )
                            .leadingFullWidth()
                    }
                    Image(
                        systemName: item == selectedProduct ? "checkmark.circle.fill" : "circle"
                    )
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(theme.btnColor)
                    .frame(width: 20, height: 20)
                }
                Divider()
                    .foregroundColor(.black.opacity(1))
                Text(item.description)
                    .themed(style: theme.textThemeT1.body
                        .copyWith(color: .black)
                    )
                    .leadingFullWidth()
            }
            .widthExpanded()
            .padding(.all, 15)
        }
        .background(.white)
        .cornerRadiusWithBorder(
            radius: 12,
            borderLineWidth: item == selectedProduct ? 2 : 0,
            borderColor: theme.btnColor,
        )
        .shadow(color: theme.primary.opacity(0.15), radius: 8, x: 0, y: 0)
        .onTapGesture {
            selectedProduct = item
        }
    }
}
