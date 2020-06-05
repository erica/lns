//  Copyright © 2020 Erica Sadun. All rights reserved.

import XCTest

class lnstests: XCTestCase {
    let manager = FileManager.default
    let tmpdir = FileManager.default.temporaryDirectory
    
    // MARK: - Setup/Teardown -
    
    override func setUpWithError() throws {
        for sub in ["A", "B", "C", "D"] {
            try mkdir("\(sub)")
        }
        for sub in ["E", "F"] {
            try (mkdir("A/\(sub)"))
        }
        
        // Set working directory
        cd("")
    }
    
    override func tearDownWithError() throws {
        try rm("")
    }
    
    // MARK: - Tests -
    
    func testLinkSameFile() throws {
        touch("A/File1"); defer { try! rm("A/File1") }
        
        XCTAssertEqual(link("A/File1", "A/File1"), 1)
        XCTAssertEqual(link(".", "."), 1)
        XCTAssertEqual(execute("lns . ."), 1)
    }
    
    func testLinkFileFile() throws {
        touch("A/E/File1"); defer { try! rm("A/E/File1") }
        touch("A/File2"); defer { try! rm("A/File2") }
        
        // both exist
        XCTAssertEqual(link("A/File2", "A/E/File1"), 1)
        
        // one exists, create other file
        XCTAssertFalse(exists("File3"))
        XCTAssertEqual(link("A/File2", "File3"), 0)
        XCTAssertEqual(link("A/File2", "File3"), 1)
        XCTAssertTrue(exists("File3")); try rm("File3")
        XCTAssertFalse(exists("File3"))
        XCTAssertEqual(link("File3", "A/File2"), 0)
        XCTAssertEqual(link("File3", "A/File2"), 1)
        XCTAssertTrue(exists("File3")); try rm("File3")
        
        // neither exists
        XCTAssertEqual(link("File3", "File4"), 1)
    }
    
    func testLinkDirDir() throws {
        // File already exists
        XCTAssertEqual(link("A", "D"), 1)
        XCTAssertEqual(execute("lns . D"), 1)
        XCTAssertEqual(execute("lns A ."), 1)
        
        // Link to cwd
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(execute("lns . A/E"), 0)
        XCTAssertTrue(exists("E")); try rm("E")
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(execute("lns A/E ."), 0)
        XCTAssertTrue(exists("E")); try rm("E")
    }
    
    func testLinkDirSymbol() throws {
        XCTAssertFalse(exists("G"))
        XCTAssertEqual(link("A", "G"), 0)
        XCTAssertEqual(link("A", "G"), 1)
        try rm("G")
        
        XCTAssertFalse(exists("G"))
        XCTAssertEqual(link("G", "A"), 0)
        XCTAssertEqual(link("G", "A"), 1)
        try rm("G")
        
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(link("A/E", "E"), 0)
        XCTAssertEqual(link("A/E", "E"), 1)
        try rm("E")
        
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(link("E", "A/E"), 0)
        XCTAssertEqual(link("E", "A/E"), 1)
        try rm("E")
    }
    
    func testLinkDirCWD() throws {
        // Cannot decide which dir to link
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(execute("lns . A/E"), 0)
        XCTAssertEqual(execute("lns . A/E"), 1)
        XCTAssertTrue(exists("E"))
        try rm("E")
        
        XCTAssertFalse(exists("E"))
        XCTAssertEqual(execute("lns A/E ."), 0)
        XCTAssertEqual(execute("lns A/E ."), 1)
        XCTAssertTrue(exists("E"))
        try rm("E")
    }
    
    func testLinkFileCWD() throws {
        touch("A/File1")
        XCTAssertFalse(exists("File1"))
        XCTAssertEqual(link("A/File1", "."), 0)
        XCTAssertEqual(link("A/File1", "."), 1)
        XCTAssertTrue(exists("File1"))
        try rm("File1")
        try rm("A/File1")
        
        touch("A/File1")
        XCTAssertFalse(exists("File1"))
        XCTAssertEqual(link(".", "A/File1"), 0)
        XCTAssertEqual(link(".", "A/File1"), 1)
        XCTAssertTrue(exists("File1"))
        try rm("File1")
        try rm("A/File1")
    }
    
    func testLinkFileDir() throws {
        touch("A/File1")
        XCTAssertFalse(exists("B/File1"))
        XCTAssertEqual(link("A/File1", "B"), 0)
        XCTAssertEqual(link("A/File1", "B"), 1)
        XCTAssertTrue(exists("B/File1"))
        try rm("B/File1")
        try rm("A/File1")
        
        touch("A/File1")
        XCTAssertFalse(exists("B/File1"))
        XCTAssertEqual(link("B", "A/File1"), 0)
        XCTAssertEqual(link("B", "A/File1"), 1)
        XCTAssertTrue(exists("B/File1"))
        try rm("B/File1")
        try rm("A/File1")
    }
    
    // MARK: - Utility -
    
    func url(_ string: String) -> URL {
        return tmpdir.appendingPathComponent("test").appendingPathComponent(string)
    }
    
    func path(_ string: String) -> String {
        return url(string).path
    }
    
    func cd(_ string: String) {
        manager.changeCurrentDirectoryPath(path(string))
    }
    
    func mkdir(_ string: String) throws {
        try manager.createDirectory(at: url(string), withIntermediateDirectories: true, attributes: nil)
    }
    
    func exists(_ string: String) -> Bool {
        return manager.fileExists(atPath: path(string))
    }
    
    func touch(_ string: String) {
        manager.createFile(atPath: path(string), contents: " ".data(using: .utf8), attributes: nil)
    }
    
    func rm(_ string: String) throws {
        try manager.trashItem(at: url(string), resultingItemURL: nil)
    }
    
    func execute(_ command: String) -> Int32 {
        let bundleURL = Bundle(for: type(of: self)).bundleURL
        let debugURL = bundleURL.lastPathComponent.hasSuffix("xctest")
            ? bundleURL.deletingLastPathComponent()
            : bundleURL
        let commandComponents = command.split(separator: " ")
        let arguments = commandComponents.dropFirst().map(String.init)
        let commandName = String(commandComponents.first!)
        let commandURL = debugURL.appendingPathComponent(commandName)
        guard (try? commandURL.checkResourceIsReachable()) ?? false
            else { return -1 }
        let process = Process()
        if #available(macOS 10.13, *) {
            process.executableURL = commandURL
        } else {
            process.launchPath = commandURL.path
        }
        process.arguments = arguments
        if #available(macOS 10.13, *) {
            guard (try? process.run()) != nil
                else { return -1 }
        } else {
            process.launch()
        }
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    func link(_ string1: String, _ string2: String) -> Int32 {
        let (path1, path2) = (path(string1), path(string2))
        return execute("lns \(path1) \(path2)")
    }
}
