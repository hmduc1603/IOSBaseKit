//
//  TaskExtension.swift
//  renoteai
//
//  Created by Dennis Hoang on 11/09/2024.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(for seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
