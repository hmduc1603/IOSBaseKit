//
//  EvenBusManager.swift
//  renoteai
//
//  Created by Dennis Hoang on 10/09/2024.
//

import Combine
import Foundation

struct EvenBusManager {
    static let shared = Self()

    private let eventSubject = PassthroughSubject<BaseEvent, Never>()

    func subscribe<T: BaseEvent>(for _: T.Type) -> AnyPublisher<T, Never> {
        eventSubject
            .compactMap { $0 as? T } // Cast the BaseEvent to the specific event type
            .eraseToAnyPublisher() // Convert to AnyPublisher with `Never` as Failure type
    }
    
    func subscribeWithThrottle<T: BaseEvent>(for _: T.Type, seconds: Int) -> AnyPublisher<T, Never> {
        eventSubject
            .compactMap { $0 as? T } // Cast the BaseEvent to the specific event type
            .throttle(for: .seconds(seconds), scheduler: RunLoop.main, latest: true)
            .eraseToAnyPublisher() // Convert to AnyPublisher with `Never` as Failure type
    }

    func fire(event: BaseEvent) {
        print("EvenBusManager: Firing event: \(event)")
        DispatchQueue.main.async {
            eventSubject.send(event)
        }
    }
}
