//
//  NSError.swift
//  IOSBaseKit
//
//  Created by Dennis Hoang on 3/10/25.
//

import Foundation

public extension NSError {
    static func fromMessage(_ message: String) -> NSError {
        return NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
