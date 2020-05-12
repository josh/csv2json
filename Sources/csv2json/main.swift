import ArgumentParser
import CodableCSV
import Foundation

struct CSV2JSON: ParsableCommand {
    @Argument(help: "The CSV input file.")
    var filename: String?

    struct Delimiter: RawRepresentable, ExpressibleByArgument {
        var rawValue: String

        var defaultValueDescription: String {
            let escaped = rawValue.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
            return "'\(escaped)'"
        }
    }

    @Option(default: Delimiter(rawValue: ","), help: "The character that seperates columns.")
    var fieldDelimiter: Delimiter

    @Option(default: Delimiter(rawValue: "\n"), help: "The character that seperates rows.")
    var rowDelimiter: Delimiter

    enum Escaping: String, ExpressibleByArgument {
        case none
        case doubleQuote = "\""

        var strategy: CodableCSV.Strategy.Escaping {
            switch self {
            case .none:
                return .none
            case .doubleQuote:
                return .doubleQuote
            }
        }

        var defaultValueDescription: String {
            let escaped = rawValue.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
            return "'\(escaped)'"
        }
    }

    @Option(default: .doubleQuote, help: "Enable field escaping character.")
    var escaping: Escaping

    enum Header: String, ExpressibleByArgument {
        case none
        case firstLine = "first-line"

        var strategy: CodableCSV.Strategy.Header {
            switch self {
            case .none:
                return .none
            case .firstLine:
                return .firstLine
            }
        }

        var defaultValueDescription: String {
            "\(rawValue)"
        }
    }

    @Option(default: .firstLine, help: "Use first line as header row.")
    var header: Header

    func run() throws {
        let reader: CSVReader
        if let filename = filename {
            let url = URL(fileURLWithPath: filename)
            reader = try CSVReader(input: url, configuration: csvConfiguration)
        } else {
            reader = try CSVReader(input: .standardInput, configuration: csvConfiguration)
        }

        switch reader.configuration.headerStrategy {
        case .none:
            try readRows(reader)
        case .firstLine:
            try readRecords(reader)
        }
    }

    func readRows(_ reader: CSVReader) throws {
        assert(reader.headers.isEmpty, "headers found")

        while let row = try reader.readRow() {
            var didOpen = false

            for field in row {
                if didOpen == false {
                    print("[", terminator: "")
                    didOpen = true
                } else {
                    print(",", terminator: "")
                }
                print(escapeJSON(field), terminator: "")
            }

            if didOpen == true {
                print("]")
            }
        }
    }

    func readRecords(_ reader: CSVReader) throws {
        assert(!reader.headers.isEmpty, "no headers found")

        while let record = try reader.readRecord() {
            var didOpen = false

            for header in reader.headers {
                if didOpen == false {
                    print("{", terminator: "")
                    didOpen = true
                } else {
                    print(",", terminator: "")
                }
                print(escapeJSON(header), terminator: "")
                print(":", terminator: "")
                print(escapeJSON(record[header]!), terminator: "")
            }

            if didOpen == true {
                print("}")
            }
        }
    }

    var csvConfiguration: CSVReader.Configuration {
        var config = CSVReader.Configuration()
        config.encoding = .utf8
        config.delimiters = (
            field: CodableCSV.Delimiter.Field(stringLiteral: fieldDelimiter.rawValue),
            row: CodableCSV.Delimiter.Row(stringLiteral: rowDelimiter.rawValue)
        )
        config.escapingStrategy = escaping.strategy
        config.headerStrategy = header.strategy
        return config
    }

    func escapeJSON(_ value: String) -> String {
        let escaped = value.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
        return "\"\(escaped)\""
    }
}

CSV2JSON.main()
