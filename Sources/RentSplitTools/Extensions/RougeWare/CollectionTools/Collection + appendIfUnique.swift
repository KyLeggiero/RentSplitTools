//
//  Collection + appendIfUnique.swift
//  Rent Split (iOS)
//
//  Created by Ky Leggiero on 2023-10-08.
//

import Foundation



public extension RangeReplaceableCollection where Self: MutableCollection {
    
    /// Appends the given new element, iff it'd be unique in this collection. The mechanism by which that uniqueness is determined is also a given parameter
    ///
    /// - Parameters:
    ///   - newElement:        The element which would be added iff it would be unique in the resulting collection
    ///   - uniquingMechanism: The mechanism by which uniqueness is decided
    ///
    /// - Returns: `true` iff the given element was added
    @discardableResult
    mutating func appendIfUnique<Field:Equatable>(_ newElement: Element, by field: KeyPath<Element, Field>) -> Bool {
        let newElementField = newElement[keyPath: field]
        
        guard !contains(where: { existingElement in
            newElementField == existingElement[keyPath: field]
        })
        else {
            return false
        }
        
        append(newElement)
        return true
    }
    
    
    /// Appends the given new element, iff it'd be unique in this collection. Uniqueness is determined by equality using the `==` function
    ///
    /// - Parameters:
    ///   - newElement:        The element which would be added iff it would be unique in the resulting collection
    ///
    /// - Returns: `true` iff the given element was added
    @discardableResult
    mutating func appendIfUnique(_ newElement: Element) -> Bool
    where Element: Equatable 
    {
        guard !contains(where: { existingElement in
            newElement == existingElement
        })
        else {
            return false
        }
        
        append(newElement)
        return true
    }
    
    
    /// Appends the given new element, iff it'd be unique in this collection. Uniqueness is determined by the `id` of each element
    ///
    /// - Parameters:
    ///   - newElement:        The element which would be added iff it would be unique in the resulting collection
    ///
    /// - Returns: `true` iff the given element was added
    @discardableResult
    mutating func appendIfUnique(_ newElement: Element) -> Bool
    where Element: Identifiable
    {
        appendIfUnique(newElement, by: \.id)
    }
}
