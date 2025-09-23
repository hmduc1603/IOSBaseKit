//
//  BaseEvent.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation
import StoreKit

public protocol BaseEvent: Sendable {
    var eventName: String { get }
}

public struct AppErrorEvent: BaseEvent {
    public var eventName: String {
        "AppErrorEvent"
    }

    public var error: String

    public init(error: String) {
        self.error = error
    }
}

public struct AppLoadingEvent: BaseEvent {
    public var eventName: String {
        "AppLoadingEvent"
    }

    public var isLoading: Bool
    public var message: String?

    public init(isLoading: Bool, message: String? = nil) {
        self.isLoading = isLoading
        self.message = message
    }
}

public struct AppMessageEvent: BaseEvent {
    public var eventName: String {
        "AppMessageEvent"
    }

    public var message: String

    public init(message: String) {
        self.message = message
    }
}

public struct ShowSubscriptionViewEvent: BaseEvent {
    public var eventName: String {
        "ShowSubscriptionViewEvent"
    }

    public init() {}
}

public struct ShowIntroSubscriptionViewEvent: BaseEvent {
    public var eventName: String {
        "ShowIntroSubscriptionViewEvent"
    }

    public init() {}
}
