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
    
    
    @State private var done: Bool = true
    
    @State private var employees: [Employee] = []
    @State private var editableEmployee = Employee()
    
    @State private var employeeSelected: Bool = false
    @State private var editableEmployeeAreaOpened: Bool = false
    @State private var isNewEmployeeReadyToSave: Bool = false
    
    @State private var deleteEmployeeAlert: Bool = false
    @State private var errorOn: Bool = false
    @State private var errorAlert: ErrorAlerts = .dataNotObtained
    
    var body: some View {
        LoadingIfNotReady(done: $done) {
            Sheet(title: "Empleados") {
                employees.isNotEmpty ? employeesListArea : nil
                WhiteArea {
                    Button(action: openEdtableEmployeeArea) {
                        Text("Nuevo empleado").frame(maxWidth: .infinity)
                    }
                    .sheet(isPresented: $editableEmployeeAreaOpened, onDismiss: unselectEmployee) {
                        editableEmployeeArea
                    }
                }
            }
            .onChange(of: editableEmployee, validateEmployee)
            .onChange(of: employees, sortEmployees)
        }
        .tint(Color.orange)
        .onAppear(perform: onAppear)
        .alert(errorAlert.rawValue, isPresented: $errorOn, actions: {})
        
    }
    
    private var employeesListArea: some View {
        WhiteArea {
            ForEach(employees, id: \.self) { employee in
                Button(action: {selectEmployee(employee)}) {
                    HStack {
                        Text(employee.lastName).foregroundStyle(Color.black)
                        Text(employee.name).foregroundStyle(Color.black)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(Color.black.opacity(0.5))
                    }
                }
                
                if employees.last != employee {
                    Divider()
                }
            }
        }
    }
    
    private var editableEmployeeArea: some View {
        Sheet(title: "Empleado") {
            VStack(alignment: .leading) {
                Text("Información de empleado")
                    .bold()
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                WhiteArea {
                    TextField("Nombre", text: $editableEmployee.name)
                    Divider()
                    TextField("Apellido", text: $editableEmployee.lastName)
                }
                WhiteArea {
                    Button(action: create) {
                        Text("Guardar").frame(maxWidth: .infinity)
                    }
                    .disabled(!isNewEmployeeReadyToSave)
                }
                
                if employeeSelected {
                    
                    WhiteArea {
                        Button(action: unselectEmployee) {
                            Text("Cancelar").frame(maxWidth: .infinity)
                        }
                    }
                    
                    WhiteArea {
                        Button(action: deleteEmployeeButtonPressed) {
                            Text("Eliminar").frame(maxWidth: .infinity)
                        }
                        .alert(isPresented: $deleteEmployeeAlert) {
                            Alert(
                                title: Text("Eliminar empleado"),
                                message: Text("Estas seguro de que quieres eliminar a \(editableEmployee.lastName) \(editableEmployee.name)"),
                                primaryButton: .destructive(Text("Eliminar"), action: deleteEmployee),
                                secondaryButton: .cancel(Text("Cancelar"))
                            )
                        }
                    }
                }
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
            done = false
            employeeVM.delete(editableEmployee) { result in
                switch result {
                    case .success:
                        employees.removeAll { $0 == editableEmployee }
                        done = true
                        unselectEmployee()
                    case .failure:
                        errorOn = true
                        errorAlert = .notDeleted
                        done = true
                }
            }
        }
    }
    
    private func onAppear() {
        done = false
        accentColor.orange()
        employeeVM.fetchEmployees(for: restaurantVM.restaurant.id) { result in
            switch result {
                case .success(let employees):
                    self.employees = employees
                    done = true
                case .failure:
                    errorOn = true
                    errorAlert = .dataNotObtained
            }
        }
    }
}

