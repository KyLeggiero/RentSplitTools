//
//  AppUniqueIdentifier.swift
//  
//
//  Created by S🌟System on 2022-07-08.
//

import Foundation



/// An identifier which is unique to this app's runtime.
///
/// This is only guaranteed to be unique in this app's runtime. Any further uniqueness is not guaranteed.
public struct AppUniqueIdentifier {
    private let rawValue: ID
}



// MARK: - Private APIs

// MARK: Initialization

fileprivate extension AppUniqueIdentifier {
    
    /// Creates a new app-unique ID with the given value. This also registers it immediately, to ensure all app-unique IDs are unique across all others
    ///
    /// - Parameters:
    ///   - id:            The value of the new app-unique ID
//    ///   - doNotRegister: _optional_ - **Discouraged!** Iff `true`, indicates that this new identifier should _not_ be registered as one that's currently in use. Useful for testing. Defaults to `false`
    init(id: ID, doNotRegister: Bool = false) {
        self.rawValue = id
        
//        if !doNotRegister {
//            Self.register(id: self)
//        }
    }
}


// MARK: Static registry

fileprivate extension AppUniqueIdentifier {
    
    /// The IDs which are currently in use in this runtime
    private static var idRegistry = Set<ID>()
    
    /// Keeps track of the mimimum ID which is not yet used
    static var minimumAvailableIdValue = ID.min
    
    
    /// Determines whether an ID has been registered which has the given value
    ///
    ///
    /// - Parameter value: The raw value of some ID
    /// - Returns: `true` iff the given value has been registered
    static func isRegistered(idWithValue value: ID) -> Bool {
        idRegistry.contains(value)
    }
}



// MARK: - API

public extension AppUniqueIdentifier {
    
    /// Finds, registers, and returns the next available ID which is not the same as any currently-existing IDs
    static func next() -> Self {
        Self(id: minimumAvailableIdValue)
    }
    
    
    /// Registers the given ID as one which currently exists. This is useful for loading existing data
    /// - Parameter id: The ID which already exists but was not created by ``next()`` in this runtime
    static func register(id: Self) {
        #if DEBUG
        assert(!isRegistered(idWithValue: minimumAvailableIdValue))
        assert(!isRegistered(idWithValue: id.rawValue))
        #endif
        
        idRegistry.insert(id.rawValue)
        
        if id.rawValue == minimumAvailableIdValue {
            minimumAvailableIdValue = (minimumAvailableIdValue ... ID.max).first { !isRegistered(idWithValue: $0) } ?? .max
        }
    }
    
    
    /// Notes that the given ID can be put back into the pool of available IDs to be used for something else
    /// - Parameter id: The ID which already exists, which can now be used for some other purpose
    static func recycle(id: Self) {
        #if DEBUG
        assert(!isRegistered(idWithValue: minimumAvailableIdValue))
        assert(isRegistered(idWithValue: id.rawValue))
        #endif
        
        idRegistry.remove(id.rawValue)
        
        if id.rawValue < minimumAvailableIdValue {
            minimumAvailableIdValue = id.rawValue
        }
    }
}



// MARK: - Conformance

extension AppUniqueIdentifier: LosslessStringConvertible {
    
    public init?(_ description: String) {
        guard let id = ID(description) else {
            return nil
        }
        
        self.init(id: id)
    }
    
    public var description: String {
        rawValue.description
    }
}



extension AppUniqueIdentifier: Identifiable {
    
    @inline(__always)
    public var id: UInt16 { rawValue }
}



extension AppUniqueIdentifier: Hashable {}
