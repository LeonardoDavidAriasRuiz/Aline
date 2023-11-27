//
//  CSVDocument.swift
//  Aline
//
//  Created by Leonardo on 13/10/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    var csvData: Data

    init(_ initialData: Data) {
        self.csvData = initialData
    }

    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    static var writableContentTypes: [UTType] { [.commaSeparatedText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.csvData = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: csvData)
    }
}
