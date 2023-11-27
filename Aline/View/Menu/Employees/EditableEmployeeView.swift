//
//  EditableEmployeeView.swift
//  Aline
//
//  Created by Leonardo on 06/10/23.
//

import SwiftUI

struct EditableEmployeeView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading: Bool = false
    
    @Binding var employee: Employee
    
    var body: some View {
        Sheet(section: .newEmployee) {
            WhiteArea {
                TextField("Nombre", text: $employee.name).foregroundStyle(.secondary).padding(.vertical, 8)
                Divider()
                TextField("Apellido", text: $employee.lastName).foregroundStyle(.secondary).padding(.vertical, 8)
                Divider()
                Toggle("Activo", isOn: $employee.isActive).padding(.vertical, 8)
                Divider()
                VStack {
                    Picker("Sueldo", selection: $employee.salary) {
                        Text("Salary").tag(true)
                        Text("Rate").tag(false)
                    }.pickerStyle(.segmented)
                    DecimalField(employee.salary ? "Salary" : "Rate", decimal: $employee.quantity, alignment: .leading)
                }.padding(.vertical, 8)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                discardToolBarButton
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                saveToolBarButton
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var discardToolBarButton: some View {
        Button(action: {dismiss()}) {
            Text("Descartar").foregroundStyle(Color.red)
        }
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfSpendingReadyToSave() {
                Button(action: save) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    if employee.name.isEmpty {
                        Text("Escribe un nombre.")
                    }
                    if employee.lastName.isEmpty {
                        Text("Escribe un apellido.")
                    }
                }
            }
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return employee.name.isNotEmpty && employee.lastName.isNotEmpty
    }
    
    private func save() {
        isLoading = true
        employee.restaurantId = restaurantM.currentId
        employeeVM.update(employee.record) { updated in
            if updated {
                dismiss()
            } else {
                alertVM.show(.crearingError)
            }
            isLoading = false
        }
    }
}
