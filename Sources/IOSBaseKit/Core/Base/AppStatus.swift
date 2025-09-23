//
//  AppStatus.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

enum AppStatus: Equatable {
    case idle
    case error(error: String?)
    case loading(message: String?)

    var message: String? {
        switch self {
        case .idle:
            return ""
        case .error(error: let error):
            return error?.description ?? "Something wrong is happened."
        case .loading(message: let message):
            return message
        }
    }

    var isIdle: Bool {
        return self == .idle
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
