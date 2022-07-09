//
//  Person.swift
//  
//
//  Created by S🌟System on 2022-07-08.
//

import Foundation



/// A person in a Rent Split style application
public struct Person: Identifiable {
    
    /// The runtime-unique ID which
    public let id: AppUniqueIdentifier
    
    /// The person's name, like `"Luz Noceda"`
    public var name: String
    
    
    /// Creates a new person
    ///
    /// - Parameters:
    ///   - id:   _optional_ - The ID uniquely identifying this person across this runtime. Defaults to the next available ID
    ///   - name: _optional_ - The name of this person, like `"Eda Clawthorne"`. Defaults to an auto-generated name like `"Person #1"`
    init(id: AppUniqueIdentifier = .next(), name: String? = nil) {
        self.id = id
        self.name = name ?? "Person #\(id)"
    }
}
