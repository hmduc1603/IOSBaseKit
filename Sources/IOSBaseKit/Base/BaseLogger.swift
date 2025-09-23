//
//  BaseLogger.swift
//  lgremote
//
//  Created by Dennis Hoang on 16/09/2024.
//

import Foundation

class BaseLogger {
    func printLog(_ value: String?) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value ?? "Empty Log!")")
    }
}

class BaseLoggerNSObject: NSObject {
    func printLog(_ value: String?) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value ?? "Empty Log!")")
    }
}
