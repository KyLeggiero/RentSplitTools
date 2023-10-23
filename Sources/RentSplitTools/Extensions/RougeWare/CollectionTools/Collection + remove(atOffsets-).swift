//
//  Collection + remove(atOffsets-).swift
//  Rent Split
//
//  Created by The Northstar✨ System on 2023-10-12.
//

import Foundation
import CollectionTools



public extension RangeReplaceableCollection {
    mutating func remove(atOffsets offsets: IndexSet) { // TODO: Text
        indices
            .reversed()
            .filter { offsets.contains(distance(from: startIndex, to: $0)) }
            .forEach { remove(at: $0) }
    }
}
