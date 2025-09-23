//
//  BaseEvent.swift
//  renoteai
//
//  Created by Dennis Hoang on 28/08/2024.
//

import Foundation
import StoreKit

protocol BaseEvent {
    var eventName: String { get }
}

struct AppErrorEvent: BaseEvent {
    var eventName: String {
        "AppErrorEvent"
    }

    var error: String
}

struct AppLoadingEvent: BaseEvent {
    var eventName: String {
        "AppLoadingEvent"
    }

    var isLoading: Bool
    var message: String?
}

struct AppMessageEvent: BaseEvent {
    var eventName: String {
        "AppMessageEvent"
    }

    var message: String
}

struct ShowSubscriptionViewEvent: BaseEvent {
    var eventName: String {
        "ShowSubscriptionViewEvent"
    }
}

struct ShowIntroSubscriptionViewEvent: BaseEvent {
    var eventName: String {
        "ShowIntroSubscriptionViewEvent"
    }
}
