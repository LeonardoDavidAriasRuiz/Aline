//
//  ChecksView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct ChecksView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .checks, isLoading: $isLoading) {
            WhiteArea(spacing: 0) {
                HStack {
                    Text("Empleado").frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("Cheques").frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("Cash").frame(maxWidth: .infinity, maxHeight: .infinity)
                }.bold().font(.title2).padding(.vertical, 12).foregroundStyle(Color.blue)
                ForEach(employeeVM.employees, id: \.self) { employee in
                    Divider()
                    HStack {
                        Text(employee.fullName).frame(maxWidth: .infinity, maxHeight: .infinity)
                        Text(0.0.comasTextWithDecimals).frame(maxWidth: .infinity, maxHeight: .infinity)
                        Text(0.0.comasTextWithDecimals).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.padding(.vertical, 12)
                }
            }
        }
    }
}
