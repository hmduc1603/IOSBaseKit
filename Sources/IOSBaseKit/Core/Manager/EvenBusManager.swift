//
//  EvenBusManager.swift
//  renoteai
//
//  Created by Dennis Hoang on 10/09/2024.
//

import Combine
import Foundation

public struct EvenBusManager: @unchecked Sendable {
    public static let shared = Self()

    private let eventSubject = PassthroughSubject<BaseEvent, Never>()

    public func subscribe<T: BaseEvent>(for _: T.Type) -> AnyPublisher<T, Never> {
        eventSubject
            .compactMap { $0 as? T } // Cast the BaseEvent to the specific event type
            .eraseToAnyPublisher() // Convert to AnyPublisher with `Never` as Failure type
    }

    public func subscribeWithThrottle<T: BaseEvent>(for _: T.Type, seconds: Int) -> AnyPublisher<T, Never> {
        eventSubject
            .compactMap { $0 as? T } // Cast the BaseEvent to the specific event type
            .throttle(for: .seconds(seconds), scheduler: RunLoop.main, latest: true)
            .eraseToAnyPublisher() // Convert to AnyPublisher with `Never` as Failure type
    }

    public func fire(event: BaseEvent) {
        print("EvenBusManager: Firing event: \(event)")
        Task { @MainActor in
            eventSubject.send(event)
        }
    }
}
