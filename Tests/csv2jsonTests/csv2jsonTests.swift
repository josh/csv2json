import XCTest

import class Foundation.Bundle

final class csv2jsonTests: XCTestCase {
    func testDefault() throws {
        let csv = """
        a,b,c
        aaa,bbb,ccc
        zzz,yyy,xxx
        """

        let json = """
        {"a":"aaa","b":"bbb","c":"ccc"}
        {"a":"zzz","b":"yyy","c":"xxx"}

        """

        XCTAssertEqual(try csv2json(csv), json)
    }

    func testTabDelimiter() throws {
        let csv = """
        a\tb\tc
        aaa\tbbb\tccc
        zzz\tyyy\txxx
        """

        let json = """
        {"a":"aaa","b":"bbb","c":"ccc"}
        {"a":"zzz","b":"yyy","c":"xxx"}

        """

        XCTAssertEqual(try csv2json(csv, ["--field-delimiter", "\t"]), json)
    }

    func testNoHeader() throws {
        let csv = """
        aaa,bbb,ccc
        zzz,yyy,xxx
        """

        let json = """
        ["aaa","bbb","ccc"]
        ["zzz","yyy","xxx"]

        """

        XCTAssertEqual(try csv2json(csv, ["--header", "none"]), json)
    }

    func csv2json(_ input: String, _ arguments: [String] = []) throws -> String? {
        let binary = productsDirectory.appendingPathComponent("csv2json")

        let pipe = (in: Pipe(), out: Pipe())

        let process = Process()
        process.executableURL = binary
        process.arguments = arguments
        process.standardInput = pipe.in
        process.standardOutput = pipe.out

        try process.run()

        pipe.in.fileHandleForWriting.write(Data(input.utf8))
        pipe.in.fileHandleForWriting.closeFile()

        let data = pipe.out.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        process.waitUntilExit()

        return output
    }

    var productsDirectory: URL {
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
    }
}
