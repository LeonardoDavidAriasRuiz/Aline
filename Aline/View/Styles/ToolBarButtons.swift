//
//  ToolBarButtons.swift
//  Aline
//
//  Created by Leonardo on 06/10/23.
//

import SwiftUI

struct ExportToolbarButton: View {
    @State private var isExporting: Bool = false
    @State private var showAlert: Bool = false
    
    let data: Data?
    
    var body: some View {
        Button {
            data != nil ? (isExporting = true) : (showAlert = true)
        } label: {
            Label("Extportar información", systemImage: "square.and.arrow.up.on.square")
        }
        .fileExporter(isPresented: $isExporting, document: CSVDocument(data ?? Data()), contentType: .commaSeparatedText, defaultFilename: "data") { result in
            if case .success = result {} else {
                showAlert = true
            }
        }
        .alertInfo(.exportationError, showed: $showAlert)
    }
}

struct ImportToolbarButton: View {
    @State private var pressed: Bool = false
    let action: (String?) -> Void
    
    var body: some View {
        Button(action: { pressed.toggle() }) {
            Label("Importar información", systemImage: "square.and.arrow.down.on.square")
        }
        .fileImporter(isPresented: $pressed, allowedContentTypes: [.commaSeparatedText]) { result in
            if case .success(let url) = result,
               let data = try? String(contentsOf: url) {
                action(data)
            } else {
                action(nil)
            }
        }
    }
}

struct UpdateRecordsToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Actializar información", systemImage: "arrow.triangle.2.circlepath")
        }
    }
}

struct NewRecordToolbarButton: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sheetOpened: Bool = false
    let destination: any View
    
    var body: some View {
        Button(action: openSheet) {
            Label("Nuevo Registro", systemImage: "square.and.pencil")
        }
        .sheet(isPresented: $sheetOpened) {
            NavigationStack {
                AnyView(destination)
            }
        }
    }
    
    private func openSheet() {
        withAnimation {
            sheetOpened = true
        }
    }
    
    private func closeSheet() {
        dismiss()
    }
}

struct FiltersToolBarMenu<Content: View>: View {
    let fill: Bool
    let content: () -> Content
    
    init(fill: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.fill = fill
    }
    
    var body: some View {
        Menu(content: content) {
            Label { Text("Filtros")
            } icon: { Image(systemName: "line.3.horizontal.decrease.circle\(fill ? ".fill" : "")") }
        }
    }
}
