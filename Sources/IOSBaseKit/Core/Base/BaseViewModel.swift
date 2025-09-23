//
//  BaseViewModel.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Combine
import Foundation

@MainActor
class BaseViewModel<S>: NSObject, ObservableObject {
    @Published var state: S
    @Published var status: AppStatus = .idle

    init(initialState: S) {
        state = initialState
        super.init()
    }

    func showLoading(message: String? = nil) {
        Task { @MainActor in
            status = .loading(message: message)
        }
    }

    func hideLoading() {
        Task { @MainActor in
            status = .idle
        }
    }

    func handleError(error: String) {
        EvenBusManager.shared.fire(event: AppErrorEvent(error: error))
    }

    func showMessage(message: String) {
        EvenBusManager.shared.fire(event: AppMessageEvent(message: message))
    }

    func emit(state: S) {
        printLog("Emit new state: \(S.self)")
        self.state = state
    }

    func printLog(_ value: String) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value)")
    }

    var isPremium: Bool {
        UserDefaults.standard.isPremium
    }
}
