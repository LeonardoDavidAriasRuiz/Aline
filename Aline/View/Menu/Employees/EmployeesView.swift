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
    
    @State private var employees: [Employee] = []
    @State private var editableEmployee = Employee()
    @State private var employeeSelected: Bool = false
    @State private var fieldsEmptyAlert: Bool = false
    @State private var deleteEmployeeAlert: Bool = false
    @State private var dataNotObtained: Bool = false
    @State private var employeeNotSaved: Bool = false
    @State private var done: Bool = true
    @State private var newEmployeeAreaOpened: Bool = false
    @State private var editEmployeeAreaOpened: Bool = false
    @State private var isNewEmployeeReadyToSave: Bool = false
    @State private var errorOn: Bool = false
    @State private var errorAlert: ErrorAlerts = .dataNotObtained
    
    var body: some View {
        LoadingIfNotReady(done: $done) {
            Sheet(title: "Empleados") {
                employees.isNotEmpty ? employeesListArea : nil
                WhiteArea {
                    Button(action: openNewEmployeeArea) {
                        Text("Nuevo empleado").frame(maxWidth: .infinity)
                    }
                    .sheet(isPresented: $newEmployeeAreaOpened, onDismiss: unselectEmployee) {
                        newEmployeeArea
                    }
                    .sheet(isPresented: $employeeSelected, onDismiss: unselectEmployee) {
                        editEmployeeArea
                    }
                }
            }
            .onChange(of: editableEmployee, validateEmployee)
            .onChange(of: employees, sortEmployees)
        }
        .onAppear(perform: onAppear)
        .alert("Completa el nombre y apellido", isPresented: $fieldsEmptyAlert, actions: {})
        .alert(errorAlert.rawValue, isPresented: $errorOn, actions: {})
        .alert(isPresented: $deleteEmployeeAlert) {
            Alert(
                title: Text("Eliminar empleado"),
                message: Text("Estas seguro de que quieres eliminar a \(editableEmployee.lastName) \(editableEmployee.name)"),
                primaryButton: .destructive(Text("Eliminar"), action: deleteEmployee),
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
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
    
    private var newEmployeeArea: some View {
        Sheet(title: "Nuevo empleado") {
            VStack(alignment: .leading) {
                Text("Nuevo empleado")
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
            }
        }
    }
    
    private var editEmployeeArea: some View {
        Sheet(title: "Editar empleado") {
            VStack(alignment: .leading) {
                Text("Editar empleado")
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
                
                WhiteArea {
                    Button(action: unselectEmployee) {
                        Text("Cancelar").frame(maxWidth: .infinity)
                    }
                }
                
                WhiteArea {
                    Button(action: deleteEmployeeButtonPressed) {
                        Text("Eliminar").frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    func sortEmployees() {
        employees.sort { lhs, rhs in
            if lhs.lastName == rhs.lastName {
                lhs.name < rhs.name
            } else {
                lhs.lastName < rhs.lastName
            }
        }
    }
    
    func deleteEmployee() {
        employeeVM.delete(editableEmployee) { result in
            switch result {
                case .success:
                    employees.removeAll { employee in
                        employee == editableEmployee
                    }
                    unselectEmployee()
                case .failure:
                    errorOn = true
                    errorAlert = .notDeleted
            }
        }
    }
    
    func deleteEmployeeButtonPressed() {
        deleteEmployeeAlert = true
    }
    
    func unselectEmployee() {
        withAnimation {
            editableEmployee = Employee()
            employeeSelected = false
        }
    }
    
    func selectEmployee(_ employee: Employee) {
        withAnimation {
            if editableEmployee == employee {
                employeeSelected = false
                editableEmployee = Employee()
            } else {
                self.editableEmployee = employee
                employeeSelected = true
            }
        }
    }
    
    private func update() {
        employeeVM.save(editableEmployee, isNew: false) { result in
            switch result {
                case .success(let employee):
                    guard let index = employees.firstIndex(of: editableEmployee) else { return }
                    employees[index] = employee
                    editableEmployee = Employee()
                    unselectEmployee()
                default:
                    employeeNotSaved = true
            }
        }
    }
    
    func create() {
        withAnimation {
            done = false
            if isNewEmployeeReadyToSave {
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
            } else {
                fieldsEmptyAlert = true
            }
            closeNewEmployeeArea()
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
    
    private func openNewEmployeeArea() {
        withAnimation {
            newEmployeeAreaOpened = true
        }
    }
    
    private func closeNewEmployeeArea() {
        withAnimation {
            newEmployeeAreaOpened = false
            editableEmployee = Employee()
        }
    }
    
    func onAppear() {
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

