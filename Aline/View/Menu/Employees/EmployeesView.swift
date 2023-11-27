//
//  EmployeesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct EmployeesView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var showInactiveEmployees: Bool = false
    @State private var editableEmployeeSheetOpen: Bool = false
    @State private var isLoading: Bool = false
    @State private var employeeSelected: Employee = Employee()
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty {
                employeesListArea
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewEmployeeView())
                UpdateRecordsToolbarButton(action: updateRecords)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ExportCSVToolbarButton(data: createCSV()).disabled(employeeVM.employees.isEmpty)
                FiltersToolbarMenu(fill: showInactiveEmployees) {
                    Toggle("Mostrar inactivos", isOn: $showInactiveEmployees.animation())
                }
            }
        }
        .overlay { if employeeVM.employees.isEmpty, !isLoading { EmptyEmployeesView() } }
        .sheet(isPresented: $editableEmployeeSheetOpen){
            NavigationStack {
                EditableEmployeeView(employee: $employeeSelected)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HideKeyboardToolbarButton()
                        }
                    }
            }
        }
    }
    
    private var employeesListArea: some View {
        WhiteArea {
            ForEach(employeeVM.employees, id: \.self) { employee in
                if employee.isActive || (showInactiveEmployees && !employee.isActive)  {
                    if employee != employeeVM.employees.first {
//                        if !showInactiveEmployees,  {
                            Divider()
//                        }
                    }
                    Button(action: {selectEmployee(employee)}) {
                        HStack {
                            Text(employee.fullName).foregroundStyle(Color.text)
                            Spacer()
                            Text(employee.isActive ? "" : "Inactivo").foregroundStyle(Color.text.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.text.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    private func dismiss() {
        employeeSelected = Employee()
    }
    
    private func selectEmployee(_ employee: Employee) {
        editableEmployeeSheetOpen = true
        employeeSelected = employee
    }
    
    private func updateRecords() {
        withAnimation {
            isLoading = true
            employeeVM.fetch(restaurantId: restaurantM.currentId) { fetched in
                if !fetched {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    func createCSV() -> Data? {
        var csvString = "Id,Nombre,Apellido,Activo\n"
        for employee in employeeVM.employees {
            let depositString = "\(employee.id),\(employee.name),\(employee.lastName),\(employee.isActive)\n"
            csvString.append(depositString)
        }
        return csvString.data(using: .utf8)
    }
}

