import ArgumentParser
import CodableCSV
import Foundation

struct CSV2JSON: ParsableCommand {
    @Option(default: ",")
    var fieldDelimiter: String

    @Option(default: "\n")
    var rowDelimiter: String

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

    @Option(default: .firstLine)
    var header: Header

    func run() throws {
        let reader = try CSVReader(input: readStdinData(), configuration: csvConfiguration)

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
            field: Delimiter.Field(stringLiteral: fieldDelimiter),
            row: Delimiter.Row(stringLiteral: rowDelimiter)
        )
        config.headerStrategy = header.strategy
        return config
    }

    func readStdinData() -> Data {
        var data = Data()
        while let line = readLine(strippingNewline: false) {
            data.append(Data(line.utf8))
        }
        return data
    }

    func escapeJSON(_ value: String) -> String {
        try! String(
            decoding: JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed),
            as: UTF8.self
        )
    }
}

CSV2JSON.main()
