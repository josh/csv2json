import ArgumentParser
import CodableCSV
import Foundation

struct CSV2JSON: ParsableCommand {
    @Option(default: ",")
    var fieldDelimiter: String

    @Option(default: "\n")
    var rowDelimiter: String

    func run() throws {
        let reader = try CSVReader(input: readStdinData(), configuration: csvConfiguration)

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
        config.headerStrategy = .firstLine
        return config
    }

    func readStdinData() -> Data {
        // TODO: Read stdin as stream
        var data = Data()
        while let line = readLine(strippingNewline: false) {
            data.append(Data(line.utf8))
        }
        return data
    }

    func escapeJSON(_ value: String) -> String {
        // TODO: Implement JSON string escaping without JSONSerialization
        try! String(
            decoding: JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed),
            as: UTF8.self
        )
    }
}

CSV2JSON.main()
