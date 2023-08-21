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
    
    private let title: String = "Empleados"
    private let newEmployeeButtonText: String = "Nuevo empleado"
    private let saveButtonText: String = "Guardar"
    private let updateButtonText: String = "Guardar"
    private let cancelButtonText: String = "Cancelar"
    private let deleteButtonText: String = "Eliminar"
    private let nameFieldText: String = "Nombre"
    private let lastNameFieldText: String = "Apellido"
    private let editableEmployeeAreaTitleText: String = "Información de empleado"
    private let deleteAlertTitleText: String = "Eliminar empleado"
    private let deleteAlertMessageText: String = "Estas seguro de que quieres eliminar a"
    private let employeeButtonSymbolName: String = "chevron.right"
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(title: title) {
                WhiteArea {
                    employees.isNotEmpty ? employeesListArea : nil
                    newEmployeeButton
                }
            }
            .onChange(of: editableEmployee, validateEmployee)
            .onChange(of: employees, sortEmployees)
            .sheet(isPresented: $editableEmployeeAreaOpened, onDismiss: unselectEmployee) {
                editableEmployeeArea
                    .alert(errorAlert.rawValue, isPresented: $errorOn, actions: {})
            }
        }
        .tint(Color.orange)
        .onAppear(perform: onAppear)
    }
    
    private var employeesListArea: some View {
        VStack {
            ForEach(employees, id: \.self) { employee in
                Button(action: {selectEmployee(employee)}) {
                    HStack {
                        Text(employee.lastName).foregroundStyle(Color.black)
                        Text(employee.name).foregroundStyle(Color.black)
                        Spacer()
                        Image(systemName: employeeButtonSymbolName)
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                }
                Divider()
            }
        }
    }
    
    private var editableEmployeeArea: some View {
        Sheet(title: title) {
            VStack(alignment: .leading) {
                editableEmployeeAreaTitle
                employeeInformationFields
                
                if employeeSelected {
                    updateButton
                    cancelButton
                    deleteButton
                } else {
                    saveButton
                }
            }
        }
    }
    
    private var newEmployeeButton: some View {
        Button(action: openEdtableEmployeeArea) {
            Text(newEmployeeButtonText).frame(maxWidth: .infinity)
        }
    }
    
    private var editableEmployeeAreaTitle: some View {
        Text(editableEmployeeAreaTitleText)
            .bold()
            .font(.largeTitle)
            .padding(.bottom, 20)
    }
    
    private var employeeInformationFields: some View {
        WhiteArea {
            TextField(nameFieldText, text: $editableEmployee.name)
            Divider()
            TextField(lastNameFieldText, text: $editableEmployee.lastName)
        }
    }
    
    private var saveButton: some View {
        WhiteArea {
            Button(action: create) {
                Text(saveButtonText).frame(maxWidth: .infinity)
            }
            .disabled(!isNewEmployeeReadyToSave)
        }
    }
    
    private var updateButton: some View {
        WhiteArea {
            Button(action: update) {
                Text(updateButtonText).frame(maxWidth: .infinity)
            }
        }
    }
    
    private var cancelButton: some View {
        WhiteArea {
            Button(action: unselectEmployee) {
                Text(cancelButtonText).frame(maxWidth: .infinity)
            }
        }
    }
    
    private var deleteButton: some View {
        WhiteArea {
            Button(action: deleteEmployeeButtonPressed) {
                Text(deleteButtonText).frame(maxWidth: .infinity)
            }
            .alert(isPresented: $deleteEmployeeAlert) {
                Alert(
                    title: Text(deleteAlertTitleText),
                    message: Text("\(deleteAlertMessageText) \(editableEmployee.lastName) \(editableEmployee.name)"),
                    primaryButton: .destructive(Text(deleteButtonText), action: deleteEmployee),
                    secondaryButton: .cancel(Text(cancelButtonText))
                )
            }
        }
    }
    
    private func openEdtableEmployeeArea() {
        withAnimation {
            editableEmployeeAreaOpened = true
        }
    }
    
    private func closeEditableEmployeeArea() {
        withAnimation {
            editableEmployeeAreaOpened = false
            editableEmployee = Employee()
        }
    }
    
    private func create() {
        withAnimation {
            done = false
            editableEmployee.restaurantId = restaurantVM.currentRestaurantId
            employeeVM.save(editableEmployee, isNew: true) { result in
                switch result {
                    case .success(let employee):
                        employees.append(employee)
                        done = true
                    default:
                        errorOn = true
                        errorAlert = .notSaved
                }
            }
            editableEmployee = Employee()
        }
        closeEditableEmployeeArea()
    }
    
    private func sortEmployees() {
        withAnimation {
            employees.sort { $0.lastName < $1.lastName }
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
    
    private func selectEmployee(_ employee: Employee) {
        withAnimation {
            self.editableEmployee = employee
            employeeSelected = true
            openEdtableEmployeeArea()
            
        }
    }
    
    private func unselectEmployee() {
        withAnimation {
            employeeSelected = false
            closeEditableEmployeeArea()
        }
    }
    
    private func update() {
        done = false
        employeeVM.save(editableEmployee, isNew: false) { result in
            switch result {
                case .success(let employee):
                    guard let index = employees.firstIndex(of: editableEmployee) else { return }
                    employees[index] = employee
                    editableEmployee = Employee()
                    unselectEmployee()
                    done = true
                case .failure:
                    errorOn = true
                    errorAlert = .notSaved
                    done = true
            }
        }
    }
    
    private func deleteEmployeeButtonPressed() {
        deleteEmployeeAlert = true
    }
    
    private func deleteEmployee() {
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
    
    private func onAppear() {
        isLoading = true
        accentColor.orange()
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

