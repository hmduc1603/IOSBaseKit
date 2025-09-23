//
//  BaseLogger.swift
//  lgremote
//
//  Created by Dennis Hoang on 16/09/2024.
//

import Foundation

public class BaseLogger {
    public func printLog(_ value: String?) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value ?? "Empty Log!")")
    }
}

public class BaseLoggerNSObject: NSObject {
    public func printLog(_ value: String?) {
        print("[DEBUG] \(String(describing: type(of: self))): \(value ?? "Empty Log!")")
    }
}
