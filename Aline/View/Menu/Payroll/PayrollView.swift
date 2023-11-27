//
//  PayrollView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import PDFKit

struct PayrollView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var isLoading: Bool = false
    @State private var worksheets: [Worksheet] = []
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            WhiteArea {
                ForEach(worksheets, id: \.self) { worksheet in
                    NavigationLink {
                        PDFCustomeView(worksheet: worksheet)
                    } label: {
                        HStack {
                            Text(worksheet.payDate.shortDate)
                            Spacer()
                            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.secondary)
                        }.padding(.vertical, 8)
                    }

                    
                    
                    if worksheet != worksheets.last {
                        Divider()
                    }
                }
            }
        }
        .onAppear(perform: getWorksheets)
        .onChange(of: restaurantM.currentId, getWorksheets)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NavigationLink {
                    FullSheet(section: .newWorksheet) {
                        PDFPayrollView()
                    }
                } label: {
                    Label("Nuevo", systemImage: "square.and.pencil")
                }

                UpdateRecordsToolbarButton(action: getWorksheets)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ExportCSVToolbarButton(data: Data()).disabled(true)
                NavigationLink(destination: WorksheetSettingsView()) {
                    Label("Configuración", image: "payroll.settings").font(.title3)
                }
            }
        }
        .overlay { if worksheets.isEmpty, !isLoading { EmptyPayrollView() } }
    }
    
    private func getWorksheets() {
        isLoading = true
        WorksheetViewModel().fetch(for: restaurantM.currentId) { worksheets in
            if let worksheets = worksheets {
                self.worksheets = worksheets.sorted(by: >)
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
}
