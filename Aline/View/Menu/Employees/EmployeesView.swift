//
//  EmployeesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct EmployeesView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var userC: UserViewModel
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var isLoading: Bool = true
    
    @State private var employees: [Employee] = []
    @State private var editableEmployee = Employee()
    
    @State private var employeeSelected: Bool = false
    @State private var editableEmployeeAreaOpened: Bool = false
    @State private var isNewEmployeeReadyToSave: Bool = false
    
    @State private var alertDeletingEmployee: Bool = false
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .dataObtainingError
    
    private let newEmployeeButtonText: String = "Nuevo empleado"
    private let nameFieldText: String = "Nombre"
    private let lastNameFieldText: String = "Apellido"
    private let employeeButtonSymbolName: String = "chevron.right"
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(section: .employees) {
                editableEmployeeArea
                WhiteArea {
                    employees.isNotEmpty ? employeesListArea : nil
                }
            }
            .onChange(of: editableEmployee, validateEmployee)
            .onChange(of: employees, sortEmployees)
        }
        .onAppear(perform: getEmployees)
    }
    
    private var employeesListArea: some View {
        VStack {
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
        .alertInfo(alertType, showed: $alertShowed)
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
            isLoading = true
            editableEmployee.restaurantId = restaurantVM.currentRestaurantId
            employeeVM.save(editableEmployee, isNew: true) { result in
                switch result {
                    case .success(let employee):
                        employees.append(employee)
                    default:
                        alertShowed = true
                        alertType = .crearingError
                }
                isLoading = false
                toggleEditableDepositArea()
            }
        }
    }
    
    private func update() {
        withAnimation {
            isLoading = true
            employeeVM.save(editableEmployee, isNew: false) { result in
                switch result {
                    case .success(let employee):
                        guard let index = employees.firstIndex(where: { $0.id == employee.id }) else { return }
                        employees[index] = employee
                    case .failure:
                        alertShowed = true
                        alertType = .updatingError
                }
                isLoading = false
                toggleEditableDepositArea()
            }
        }
    }
    
    private func delete() {
        withAnimation {
            isLoading = true
            employeeVM.delete(editableEmployee) { result in
                switch result {
                    case .success:
                        employees.removeAll { $0 == editableEmployee }
                    case .failure:
                        alertShowed = true
                        alertType = .deletingError
                }
                isLoading = false
                toggleEditableDepositArea()
            }
        }
    }
    
    private func getEmployees() {
        withAnimation {
            isLoading = true
            employeeVM.fetchEmployees(for: restaurantVM.restaurant.id) { result in
                switch result {
                    case .success(let employees):
                        self.employees = employees
                    case .failure:
                        alertShowed = true
                        alertType = .dataObtainingError
                }
                isLoading = false
            }
        }
    }
}

