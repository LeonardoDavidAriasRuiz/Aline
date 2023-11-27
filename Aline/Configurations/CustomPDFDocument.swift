//
//  CustomPDFDocument.swift
//  Aline
//
//  Created by Leonardo on 17/10/23.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit


struct CustomPDFDocument: FileDocument {
    var pdfData: Data

    init(_ initialData: Data) {
        self.pdfData = initialData
    }

    static var readableContentTypes: [UTType] { [.pdf] }
    static var writableContentTypes: [UTType] { [.pdf] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.pdfData = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: pdfData)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable{
    let document: PDFDocument
    
    func makeUIView(context: Context) -> some UIView {
        let pdfView: PDFView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayDirection = .horizontal
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 2.0
        pdfView.backgroundColor = UIColor(Color.background)
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context : Context) -> Void { }
}
