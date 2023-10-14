//
//  EmployeesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct EmployeesView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var employees: [Employee] = []
    @State private var showInactiveEmployees: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            if employees.isNotEmpty { employeesListArea }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: EditableEmployeeView())
                UpdateRecordsToolbarButton(action: getEmployees)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ExportToolbarButton(data: createCSV()).disabled(employees.isEmpty)
            }
        }
        .overlay {
            if employees.isEmpty, !isLoading {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin empleados") },
                        icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.orange) }
                    )
                }, description: {
                    Text("Los nuevos empleados se mostrarán aquí.")
                })
            }
        }
        .onAppear(perform: getEmployees)
    }
    
    private var employeesListArea: some View {
        WhiteArea {
            Toggle("Mostrar inactivos", isOn: $showInactiveEmployees.animation()).padding(.vertical, 8)
            Divider()
            ForEach(employees, id: \.self) { employee in
                if employee.isActive || (showInactiveEmployees && !employee.isActive)  {
                    NavigationLink(destination: EditableEmployeeView(employee: employee)) {
                        HStack {
                            Text(employee.fullName).foregroundStyle(Color.text)
                            Spacer()
                            Text(employee.isActive ? "" : "Inactivo").foregroundStyle(Color.text.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.text.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    if employees.last != employee {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func getEmployees() {
        withAnimation {
            isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                EmployeeViewModel().fetch(restaurantId: restaurantId) { employees in
                    if let employees = employees {
                        self.employees = employees.sorted(by: {$0 > $1})
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    isLoading = false
                }
            }
        }
    }
    
    func createCSV() -> Data? {
        var csvString = "Id,Nombre,Apellido,Activo\n"
        for employee in employees {
            let depositString = "\(employee.id),\(employee.name),\(employee.lastName),\(employee.isActive)\n"
            csvString.append(depositString)
        }
        return csvString.data(using: .utf8)
    }
}

