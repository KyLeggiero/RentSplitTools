//
//  File.swift
//  
//
//  Created by The Northstar✨ System on 2023-12-08.
//

import Foundation


import AppUniqueIdentifier
import CrossKitTypes
import SerializationTools
import SimpleLogging



/// A color for a person in a rent split, to help visually distinguish them. Use the ``.nativeColor`` API to turn this into something you can use in UI.
public enum PersonColor: Codable, Hashable, Sendable {
    
    /// One of the predefined colors that a person can be automatically assigned. These might subtly change between versions, but will appear largely similar.
    ///
    /// - Attention: These indices start at `1`
    case predefined(index: Index)
    
    /// A custom color specified by the user
    case custom(CustomColor)
    
    
    
    public typealias Index = UInt8
}



// MARK: - API

public extension PersonColor {
    
    /// All valid indices of all predefined `PersonColor`s
    static let predefinedIndices = Index(1) ... 12
    
    /// All valid indices of all predefined `PersonColor`s
    private static let _predefinedIndices = Int(predefinedIndices.lowerBound) ..< Int(predefinedIndices.upperBound)+1
    
    
    static func auto(numberOfExistingPeople: Int) -> Self {
        .predefined(index: .init(
            (numberOfExistingPeople + 1)
                .wrapped(within: _predefinedIndices)
        ))
    }
    
    
    static func auto(for moneySplitter: MoneySplitter) -> Self {
        .auto(numberOfExistingPeople: moneySplitter.people.count)
    }
    
    
    /// The native representation of this person color
    var nativeColor: NativeColor {
        switch self {
        case .predefined(let index):
            return Self.nativeColor(at: index)
            
        case .custom(let customColor):
            return NativeColor { traits in
                switch traits.userInterfaceStyle {
                case .light, .unspecified:
                    return customColor.lightMode.value
                    
                case .dark:
                    return customColor.darkMode?.value ?? customColor.lightMode.value
                    
                @unknown default:
                    log(warning: "Note to devs: Allow users to specify a color for this new interface style: \(traits.userInterfaceStyle)")
                    return customColor.lightMode.value
                }
            }
        }
    }
    
    
    
    struct CustomColor: Codable, Hashable, Sendable {
        var lightMode: NativeColor.CodableBridge
        var darkMode: NativeColor.CodableBridge?
    }
}



// MARK: - Error Handling

public extension PersonColor {
    static var error: Self { .custom(.init(lightMode: NativeColor.magenta.codable)) }
}



// MARK: - Inner workings

private extension PersonColor {
    
    /// Finds the person color at the given person color index.
    ///
    /// If the given index is outside the range of ``predefinedIndices``, then the index is wrapped to be within that range according to [the `.wrapped(within:)` function of `BasicMathTools`](https://github.com/RougeWare/Swift-Basic-Math-Tools#wrapping)
    ///
    /// - Note: It should be impossible to give this function an invalid index.
    ///         It's up to the developers of RentSplitTools to make sure these colors are available in the asset catalog, and that the ``predefinedIndices`` constant reflects the true indicies of real colors.
    ///         If those developers make a mistake and these mismatch, and that mismatch results in you passing an invalid index to this function, then an error will be logged and this function will return a backup color
    ///
    /// - Parameter index: The index to turn into a color
    /// - Returns: The native color for a person with the given index
    static func nativeColor(at index: Index) -> NativeColor {
        let index = index.wrapped(within: .init(predefinedIndices))
        
        return log(errorIfThrows: try colorForIndex[index].unwrappedOrThrow(error: NoPersonColorError(index: index)),
                   backup: .black)
    }
    
    
    
    static let colorForIndex: [Index : NativeColor] = {
        log(info: Bundle.module.description)
        
        return .init(uniqueKeysWithValues: predefinedIndices.map { index in
            @inline(__always)
            func x() -> (Index, NativeColor) {
                (
                    index,
                    log(errorIfThrows: try NativeColor(named: "Rent Split • Person Color #\(index)", in: .module, compatibleWith: nil)
                        .unwrappedOrThrow(error: NoPersonColorError(index: index)),
                        backup: .black)
                )
            }
            
            return x() // Bug in Swift 5.9 compiler where it thinks that log statement throws, but it actually catches
        })
    }()
    
    
    
    struct NoPersonColorError: Error {
        let index: Index
    }
}
