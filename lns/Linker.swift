//  Copyright © 2020 Erica Sadun. All rights reserved.

import Foundation

/// A utility type to create symbolic links between two paths
struct Linker {
    /// Inaccessible initializer
    private init() {}
    
    /// The default file manager
    static let manager = FileManager.default
    
    /// Establishes a symbolic link between an existing source URL and a new target URL
    ///
    /// The target path may be constructed via a path component so this method must check to see
    /// if it already exists before creating the link.
    ///
    /// - Throws: `RuntimeError` if the destination file URL exists
    /// - Parameters:
    ///   - target: A new file url that should not yet exist
    ///   - source: An existing file url
    static func makeLink(_ target: URL, to source: URL) throws {
        guard !manager.fileExists(atPath: target.path)
            else { throw RuntimeError("File already exists at destination '\(target.path)'") }
        try manager.createSymbolicLink(at: target, withDestinationURL: source)
        print("Created symbolic link at \(target.path)")
    }
    
    
    /// Called to create a symbolic link between two paths.
    ///
    /// Either first or second may exist and may or may not be directories. Each permutation
    /// is examined, allowing the symbolic link to be created in either order.
    ///
    /// - Throws: `RuntimeError` for all configurations that cannot be successfully linked
    /// - Parameters:
    ///   - first: a file path
    ///   - second: another file path
    static func link(_ first: String, _ second: String) throws {
        
        guard first != second
            else { throw RuntimeError("Cannot link path to itself") }
        
        // Fetch urls, directory status, and existence checks
        let (url1, url2) = (URL(fileURLWithPath: first), URL(fileURLWithPath: second))
        var (isDir1, isDir2): (ObjCBool, ObjCBool) = (false, false)
        let exists1 = manager.fileExists(atPath: url1.path, isDirectory: &isDir1)
        let exists2 = manager.fileExists(atPath: url2.path, isDirectory: &isDir2)

        // When linking to a directory, the last path component for the existing file
        // becomes the new name within that directory.
        let url1withComponent2 = url1.appendingPathComponent(url2.lastPathComponent)
        let url2withComponent1 = url2.appendingPathComponent(url1.lastPathComponent)

        switch (isDir1.boolValue, isDir2.boolValue) {
        case (false, true): // file1, dir2
            switch(exists1, exists2) {
            case (false, true):   try makeLink(url1, to: url2)
            case (true,  true):   try makeLink(url2withComponent1, to: url1)
            case (true,  false):  throw RuntimeError.nonexistentFolder
            case (false, false):  throw RuntimeError.neitherFileExists
            }
        case (true, false): // file2, dir1
            switch(exists2, exists1) {
            case (false, true):   try makeLink(url2, to: url1)
            case (true,  true):   try makeLink(url1withComponent2, to: url2)
            case (true,  false):  throw RuntimeError.nonexistentFolder
            case (false, false):  throw RuntimeError.neitherFileExists
            }
        case (false, false): // file1, file2
            switch (exists1, exists2) {
            case (true, true):   throw RuntimeError.bothExist
            case (false, false): throw RuntimeError.neitherFileExists
            case (true, false): try makeLink(url2, to: url1)
            case (false, true): try makeLink(url1, to: url2)
            }
        case (true, true): // dir1, dir2
            // Handle normal directories and `.`
            switch (first == ".", second == ".") {
            case (false, false): throw RuntimeError.cannotDecideFolder
            case (true, _):      try makeLink(url1withComponent2, to: url2)
            case (_, true):      try makeLink(url2withComponent1, to: url1)
            default: break
            }
        }
    }
}
