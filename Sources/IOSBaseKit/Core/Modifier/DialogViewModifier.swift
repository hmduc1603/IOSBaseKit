//
//  DialogViewModifier.swift
//  magiclight
//
//  Created by Dennis Hoang on 16/8/25.
//

import SwiftUI

public struct DialogViewModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertDesc: String? = nil

    public func body(content: Content) -> some View {
        content
            .onAppear {
                #if os(iOS)
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(hexString: AppColor.shared.getColorHex(key: "buttonColor"))
                #endif
            }
            .onReceive(EvenBusManager.shared.subscribe(for: AppMessageEvent.self), perform: { event in
                alertTitle = event.message
                alertDesc = nil
                showAlert = true
            })
            .onReceive(EvenBusManager.shared.subscribe(for: AppErrorEvent.self), perform: { event in
                alertTitle = event.error
                alertDesc = "Oops!"
                showAlert = true
            })
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Close", role: .cancel) {}
                    .foregroundColor(theme.btnColor)
            } message: {
                if let desc = alertDesc {
                    Text(desc)
                        .themed(style: theme.textThemeT1.light)
                }
            }
    }
}

public extension View {
    func observeDialogView() -> some View {
        modifier(DialogViewModifier())
    }
}
