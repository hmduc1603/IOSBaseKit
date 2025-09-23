//
//  AppStatus.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation

public enum AppStatus: Equatable {
    case idle
    case error(error: String?)
    case loading(message: String?)

    public var message: String? {
        switch self {
        case .idle:
            return ""
        case .error(error: let error):
            return error?.description ?? "Something wrong is happened."
        case .loading(message: let message):
            return message
        }
    }

    public var isIdle: Bool {
        return self == .idle
    }

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
