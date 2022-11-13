//
//  reduce + implicit starting value.swift
//  
//
//  Created by S🌟System on 2022-08-04.
//

import Foundation



internal extension Sequence
where Element: AdditiveArithmetic {
    
    /// Reduces this collection to a single value, assuming the result should be of the same type as each element, and that the starting value for reduction is `.zero`
    /// - Parameters:
    ///   - reducer: Processes each element and reduces this collection to a single value
    ///    - result: The running result of reduction
    ///    - each: Each element of the sequence
    ///
    /// - Returns: The whole collection, reduced down to a single value
    func reduce(_ reducer: (_ result: inout Element, _ each: Element) -> Void) -> Element {
        reduce(into: .zero, reducer)
    }
    
    
    /// Calculates the sum of all elements in this sequence, through addition, assuming a starting point of `.zero`
    func sum() -> Element {
        reduce(+=)
    }
}
