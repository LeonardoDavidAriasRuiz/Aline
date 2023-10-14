//
//  PayrollView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct PayrollView: View {
    @State private var isLoading: Bool = false
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            NavigationLink("Nuevo", destination: NewPayrollView())
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewPayrollView())
                UpdateRecordsToolbarButton(action: {})
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ExportToolbarButton(data: Data())
            }
        }
        .overlay {
            if true, !isLoading {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin Payroll") },
                        icon: { Image(systemName: "calendar.badge.clock.rtl").foregroundStyle(Color.red) }
                    )
                }, description: {
                    Text("Los nuevos Payroll se mostrarán aquí.")
                })
            }
        }
    }
}
