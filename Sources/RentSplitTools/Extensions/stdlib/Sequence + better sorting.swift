//
//  Sequence + better sorting.swift
//  Rent Split
//
//  Created by The Northstar✨ System on 10/16/22.
//

import Foundation



public extension Sequence {
    func sorted<Field: Comparable>(by field: KeyPath<Element, Field>) -> [Element] {
        self.sorted { left, right in
            left[keyPath: field] > right[keyPath: field]
        }
    }
}
