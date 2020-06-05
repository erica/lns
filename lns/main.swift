//  Copyright © 2020 Erica Sadun. All rights reserved.

import Foundation
import ArgumentParser

/// A command-line linker that creates a symbolic link between two paths regardless of their order
struct Lns: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create a symbolic link between two paths, regardless of order",
        shouldDisplay: true)
    
    @Argument(help: "A file path.")
    var firstPath: String
    
    @Argument(help: "Another file path.")
    var secondPath: String

    func run() throws {
        try Linker.link(firstPath, secondPath)
    }
}

Lns.main()
