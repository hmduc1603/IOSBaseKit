//
//  String+Ext.swift
//  magiclight
//
//  Created by Dennis Hoang on 4/9/25.
//

import Foundation

extension String {
    var capitalizedFirstLetter: String {
        self
            .split(separator: "_")
            .last
            .map { String($0).localizedCapitalized } ?? self
    }
}


extension String {
    func unescapedUnicode() -> String {
        let temp = "\"\(self)\"" /// wrap in quotes so JSON decoder can parse it
        if let data = temp.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(String.self, from: data) {
            return decoded
        }
        return self
    }
}
