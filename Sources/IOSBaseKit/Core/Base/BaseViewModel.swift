//
//  BaseViewModel.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Combine
import Foundation

@MainActor
open class BaseViewModel<S>: NSObject, ObservableObject {
    @Published public var state: S
    @Published public var status: AppStatus = .idle

    public init(initialState: S) {
        state = initialState
        super.init()
    }

    public func showLoading(message: String? = nil) {
        Task { @MainActor in
            status = .loading(message: message)
        }
    }

    public func hideLoading() {
        Task { @MainActor in
            status = .idle
        }
    }

    public func handleError(error: String) {
        EvenBusManager.shared.fire(event: AppErrorEvent(error: error))
    }

    public func showMessage(message: String) {
        EvenBusManager.shared.fire(event: AppMessageEvent(message: message))
    }

    public func emit(state: S) {
        printLog("Emit new state: \(S.self)")
        self.state = state
    }

    public func printLog(_ value: String) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value)")
    }

    public var isPremium: Bool {
        UserDefaults.standard.isPremium
    }
}
