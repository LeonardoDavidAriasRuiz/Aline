//
//  ToolBarButtons.swift
//  Aline
//
//  Created by Leonardo on 06/10/23.
//

import SwiftUI

struct ExportCSVToolbarButton: View {
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

struct ExportPDFDataToolbarButton: View {
    @State private var isExporting: Bool = false
    @State private var showAlert: Bool = false
    let url: URL?
    @State private var data: Data? = nil
    let fileName: String
    
    var body: some View {
        Button {
            if let url = url, let data = try? Data(contentsOf: url) {
                self.data = data
            }
            isExporting = true
        } label: {
            Label("Extportar información", systemImage: "square.and.arrow.up.on.square")
        }
        .fileExporter(isPresented: $isExporting, document: CustomPDFDocument(data ?? Data(count: 1)), contentType: .pdf, defaultFilename: fileName) { result in
            if case .success = result {} else {
                showAlert = true
            }
        }
        .alertInfo(.exportationError, showed: $showAlert)
    }
}

struct ExportPDFContentToolbarButton<Content: View>: View  {
    let viewForPDF: () -> Content
    @State private var isExporting: Bool = false
    @State private var showAlert: Bool = false
    
    @State private var pdfData: Data?
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.viewForPDF = content
    }
    
    var body: some View {
        Button {
            exportPDF {
                viewForPDF()
            } completion: { status, url in
                if let url, status, let data = try? Data(contentsOf: url) {
                    pdfData = data
                    pdfData != nil ? (isExporting = true) : (showAlert = true)
                } else {
                    showAlert = true
                }
            }
        } label: {
            Label("Extportar información", systemImage: "square.and.arrow.up.on.square")
        }
        .fileExporter(isPresented: $isExporting, document: CustomPDFDocument(pdfData ?? Data()), contentType: .pdf, defaultFilename: "data") { result in
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

struct ClearFiltersButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Divider()
            Button(role: .destructive, action: action) {
                Label("Quitar filtros", systemImage: "xmark")
            }
        }
    }
}

struct HideKeyboardToolbarButton: View {
    var body: some View {
        HStack {
            Spacer()
            Button("Listo", action: hideKeyboard)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct NewRecordToolbarButton: View {
    @State private var sheetOpened: Bool = false
    let destination: any View
    
    var body: some View {
        Button(action: openSheet) {
            Label("Nuevo Registro", systemImage: "square.and.pencil")
        }
        .sheet(isPresented: $sheetOpened) {
            NavigationStack {
                AnyView(destination)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HideKeyboardToolbarButton()
                        }
                    }
            }
        }
    }
    
    private func openSheet() {
        withAnimation {
            sheetOpened = true
        }
    }
}

struct NewRecordToolbarNaviagtion: View {
    @Environment(\.dismiss) private var dismiss
    let destination: any View
    
    var body: some View {
        NavigationLink(destination: AnyView(destination)) {
            Label("Nuevo Registro", systemImage: "square.and.pencil")
        }
    }
}

struct FiltersToolbarMenu<Content: View>: View {
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

struct DeleteToolbarButton: View {
    @State private var deleteAlertShowed: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: showDeleteAlert) {
            Label("Delete", systemImage: "trash")
        }
        .alertDelete(showed: $deleteAlertShowed, action: action)
    }
    
    private func showDeleteAlert() {
        deleteAlertShowed = true
    }
}

struct CalendarToolbarMenu<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        Menu(content: content) {
            Label { Text("Fecha")
            } icon: { Image(systemName: "calendar") }
        }
    }
}

struct YearToolbarPicker: View {
    let startYear: Int = 2020
    let currentYear: Int = Date().yearInt
    @Binding var selectedDate: Date
    
    init(date: Binding<Date>) {
        self._selectedDate = date
    }
    
    var body: some View {
        Menu {
            ForEach(Array(startYear...currentYear+1), id: \.self) { year in
                Button(action: {selectYear(year)}) {
                    Text(String(year))
                }
            }
        } label: {
            Label("Fecha", systemImage: "calendar")
        }
    }
    
    func selectYear(_ year: Int) {
        var dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        dateComponents.year = year
        if let newDate = Calendar.current.date(from: dateComponents) {
            selectedDate = newDate
        }
    }
}
