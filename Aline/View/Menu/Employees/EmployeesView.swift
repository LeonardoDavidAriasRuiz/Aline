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
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var employees: [Employee] = []
    @State private var editableEmployee = Employee()
    
    @State private var employeeSelected: Bool = false
    @State private var editableEmployeeAreaOpened: Bool = false
    @State private var isNewEmployeeReadyToSave: Bool = false
    
    private let newEmployeeButtonText: String = "Nuevo empleado"
    private let nameFieldText: String = "Nombre"
    private let lastNameFieldText: String = "Apellido"
    private let employeeButtonSymbolName: String = "chevron.right"
    
    var body: some View {
        Sheet(section: .employees) {
            editableEmployeeArea
            employees.isNotEmpty ? employeesListArea : nil
        }
        .onChange(of: editableEmployee, validateEmployee)
        .onChange(of: employees, sortEmployees)
        .onAppear(perform: getEmployees)
    }
    
    private var employeesListArea: some View {
        WhiteArea {
            ForEach(employees, id: \.self) { employee in
                Button(action: {select(employee)}) {
                    HStack {
                        Text(employee.lastName).foregroundStyle(Color.black)
                        Text(employee.name).foregroundStyle(Color.black)
                        Spacer()
                        Text(employee.isActive ? "" : "Inactivo").foregroundStyle(.black.secondary)
                        Image(systemName: employeeButtonSymbolName)
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                }
                if employees.last != employee {
                    Divider()
                }
            }
        }
    }
    
    private var editableEmployeeArea: some View {
        WhiteArea {
            NewButton(pressed: $editableEmployeeAreaOpened, newText: newEmployeeButtonText, action: toggleEditableDepositArea)
            if editableEmployeeAreaOpened {
                Divider()
                TextField(nameFieldText, text: $editableEmployee.name).foregroundStyle(.secondary)
                Divider()
                TextField(lastNameFieldText, text: $editableEmployee.lastName).foregroundStyle(.secondary)
                Divider()
                Toggle("Activo", isOn: $editableEmployee.isActive)
                Divider()
                if employeeSelected {
                    UpdateButton(action: update).disabled(!isNewEmployeeReadyToSave)
                    Divider()
                    DeleteButton(action: delete)
                } else {
                    SaveButton(action: create).disabled(!isNewEmployeeReadyToSave)
                }
            }
        }
        
    }
    
    private func toggleEditableDepositArea() {
        withAnimation {
            editableEmployeeAreaOpened.toggle()
            employeeSelected = false
            editableEmployee = Employee()
        }
    }
    
    private func sortEmployees() {
        withAnimation {
            employees.sort { $0 < $1 }
        }
    }
    
    private func validateEmployee() {
        withAnimation {
            if editableEmployee.name.isNotEmpty, editableEmployee.lastName.isNotEmpty {
                isNewEmployeeReadyToSave = true
            } else {
                isNewEmployeeReadyToSave = false
            }
        }
    }
    
    private func select(_ employee: Employee) {
        withAnimation {
            if editableEmployee == employee {
                toggleEditableDepositArea()
            } else {
                employeeSelected = true
                editableEmployee = employee
                editableEmployeeAreaOpened = true
            }
        }
    }
    
    private func create() {
        withAnimation {
            loading.isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                editableEmployee.restaurantId = restaurantId
                employeeVM.save(editableEmployee, isNew: true) { saved in
                    if saved {
                        employees.append(editableEmployee)
                        toggleEditableDepositArea()
                    } else {
                        alertVM.show(.crearingError)
                    }
                    loading.isLoading = false
                }
            }
        }
    }
    
    private func update() {
        withAnimation {
            loading.isLoading = true
            employeeVM.save(editableEmployee, isNew: false) { saved in
                if saved {
                    guard let index = employees.firstIndex(where: { $0.id == editableEmployee.id }) else { return }
                    employees[index] = editableEmployee
                    toggleEditableDepositArea()
                } else {
                    alertVM.show(.updatingError)
                }
                loading.isLoading = false
            }
        }
    }
    
    private func delete() {
        withAnimation {
            loading.isLoading = true
            employeeVM.delete(editableEmployee) { deleted in
                if deleted {
                    employees.removeAll { $0 == editableEmployee }
                    toggleEditableDepositArea()
                } else {
                    alertVM.show(.deletingError)
                }
                loading.isLoading = false
            }
        }
    }
    
    private func getEmployees() {
        withAnimation {
            loading.isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                employeeVM.fetchEmployees(for: restaurantId) { employees in
                    if let employees = employees {
                        self.employees = employees
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    loading.isLoading = false
                }
            }
        }
    }
}

