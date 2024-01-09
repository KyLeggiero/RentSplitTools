//
//  Person.swift
//  
//
//  Created by The Northstar✨ System on 2022-07-08.
//

import Foundation

import AppUniqueIdentifier



/// A person in a Rent Split style application
public struct Person {
    
    /// The runtime-unique ID which
    public let id: AppUniqueIdentifier
    
    /// The person's name, like `"Luz Noceda"`
    public var name: String
    
    /// The person's color
    public var color: PersonColor
    
    
    /// Creates a new person
    ///
    /// - Parameters:
    ///   - id:   _optional_ - The ID uniquely identifying this person across this runtime. Defaults to the next available ID
    ///   - name: _optional_ - The name of this person, like `"Eda Clawthorne"`. Defaults to an auto-generated name like `"Person #1"`
    public init(id: AppUniqueIdentifier = .next(),
                name: String? = nil,
                color: PersonColor) {
        self.id = id
        self.name = name ?? Self.generateName(with: id)
        self.color = color
    }
}



// MARK: - Conveniences

public extension Person {
    /// Generates a name for a person who has not been named
    ///
    /// - Parameter id: The ID of the person. This is used in order to generate a unique name
    static func generateName(with id: ID) -> String {
        "Person #\(id)"
    }
}



// MARK: - Conformances

extension Person: Codable {}
extension Person: Identifiable {}
extension Person: Hashable {}



extension Person: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(id): \(name)"
    }
}
