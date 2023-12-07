//
//  PDFCustomeView.swift
//  Aline
//
//  Created by Leonardo on 17/10/23.
//

import SwiftUI

struct PDFCustomeView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading: Bool = false
    
    let worksheet: Worksheet
    
    var body: some View {
        Loading($isLoading) {
            VStack {
                if let pdf = worksheet.pdf {
                    PDFKitRepresentedView(document: pdf).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.background(Color.background)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    DeleteToolbarButton(action: delete)
                    ExportPDFDataToolbarButton(url: worksheet.url, fileName: worksheet.payDate.shortDate).disabled(worksheet.url == nil)
                }
            }
            .overlay { if worksheet.pdf == nil { EmptyPDFView() } }
        }
        .navigationTitle(worksheet.payDate.shortDate)
        .toolbarTitleDisplayMode(.automatic)
        .onChange(of: restaurantM.currentId, {dismiss()})
        .onChange(of: menuSection.section, {dismiss()})
    }
    
    private func delete() {
        isLoading = true
        WorksheetViewModel().delete(worksheet.record) {
            dismiss()
        } ifNot: {
            alertVM.show(.deletingError)
        } alwaysDo: {
            isLoading = false
        }
    }
}
