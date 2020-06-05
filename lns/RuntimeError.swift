//  Copyright © 2020 Erica Sadun. All rights reserved.

import Foundation

/// A stringity error type representing runtime errors encountered by this utility
struct RuntimeError: Error, CustomStringConvertible {
    
    /// Both files exist
    static let bothExist = Self("Both files already exist")
    
    /// Neither file exists
    static let neitherFileExists = Self("Neither item exists")
    
    /// Nonexistent directory/folder
    static let nonexistentFolder = Self("Cannot link file to non-existent folder")
    
    /// Indistinguishable targets
    static let cannotDecideFolder = Self("Cannot decide which folder to symbolically link to the other")
    
    /// Stringity description
    var description: String
    
    /// Create from string
    ///
    /// - Parameter description: A string description of a runtime error condition
    init(_ description: String) {
        self.description = description
    }
}
