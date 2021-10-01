//
//  AnyEquatable.swift
//  DiffableDataSourceExample
//
//  Created by Mikalai Zmachynski on 28/09/2021.
//

import Foundation

public struct AnyEquatable: Equatable {
    public let base: Any
    private let equals: (Any) -> Bool
    
    public init<E: Equatable>(_ value: E) {
        self.base = value
        self.equals = { ($0 as? E) == value }
    }
    
    public static func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.equals(rhs.base)
    }
}
