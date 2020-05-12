import XCTest

import class Foundation.Bundle

final class csv2jsonTests: XCTestCase {
    func testHelp() throws {
        let output = """
        USAGE: csv2-json [<filename>] [--field-delimiter <field-delimiter>] [--row-delimiter <row-delimiter>] [--escaping <escaping>] [--header <header>]

        ARGUMENTS:
          <filename>

        OPTIONS:
          --field-delimiter <field-delimiter>
                                  (default: ,)
          --row-delimiter <row-delimiter>
                                  (default: 
        )
          --escaping <escaping>   (default: ")
          --header <header>       (default: first-line)
          -h, --help              Show help information.


        """

        XCTAssertEqual(try csv2json("", ["--help"]), output)
    }

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

    func escapeJSON(_ value: String) -> String {
        let escaped = value.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
        return "\"\(escaped)\""
    }

    func testEscapeJSON() throws {
        XCTAssertEqual(escapeJSON("foo"), #""foo""#)
        XCTAssertEqual(escapeJSON("Hello \"World\"!"), #""Hello \"World\"!""#)
        XCTAssertEqual(escapeJSON("1\n2\n3\n"), #""1\n2\n3\n""#)
        XCTAssertEqual(escapeJSON("1\t2\t3\t"), #""1\t2\t3\t""#)
        XCTAssertEqual(escapeJSON("\\0"), #""\\0""#)
        XCTAssertEqual(escapeJSON("😀"), #""\u{0001F600}""#)
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
