//
//  EmployeesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct EmployeesView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var employeeC: EmployeeViewModel
    @EnvironmentObject private var userC: UserViewModel
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var employee = Employee()
    @State private var employeeSelected: Bool = false
    @State private var fieldsEmptyAlert: Bool = false
    @State private var deleteEmployeeAlert: Bool = false
    
    private let emptyFieldAlertTitle: String = "Completa el nombre y apellido"
    
    var body: some View {
        Sheet(title: "Empleados") {
            newEmpleadoArea
                .alert(emptyFieldAlertTitle,
                       isPresented: $fieldsEmptyAlert,
                       actions: {}
                )
            employeesListArea
        }
        .onAppear(perform: onAppear)
    }
    
    private var employeesListArea: some View {
        List {
            ForEach(employeeC.employees, id: \.self) { employee in
                Button(action: {selectEmployee(employee)}) {
                    HStack {
                        Text(employee.lastName)
                        Text(employee.name)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.top, 10)
    }
    
    private var newEmpleadoArea: some View {
        HStack {
            TextField("Apellido", text: $employee.lastName)
                .modifier(HeaderAreas())
            TextField("Nombre", text: $employee.name)
                .modifier(HeaderAreas())
                .padding(.horizontal, 5)
            if employeeSelected {
                Button(action: {employeeC.updateEmployee(employee)}) {
                    Text("Actualizar")
                        .modifier(ButtonColor(color: Color.blue))
                }
                Button(action: unselectEmployee) {
                    Text("Cancelar")
                        .modifier(ButtonColor(color: Color.orange))
                }
                Button(action: deleteEmployeeButtonPressed) {
                    Text("Eliminar")
                        .modifier(ButtonColor(color: Color.red))
                }
                .alert(isPresented: $deleteEmployeeAlert) {
                    Alert(
                        title: Text("Eliminar empleado"),
                        message: Text("Estas seguro de que quieres eliminar a \(employee.lastName) \(employee.name)"),
                        primaryButton: .destructive(Text("Eliminar"), action: deleteEmployee),
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
            } else {
                Button("Agregar", action: newEmployee)
                    .modifier(HeaderAreas())
            }
        }
    }
    
    func deleteEmployee() {
        employeeC.deleteEmployee(employee)
        
    }
    
    func deleteEmployeeButtonPressed() {
        deleteEmployeeAlert = true
    }
    
    func unselectEmployee() {
        withAnimation {
            employee = Employee()
            employeeSelected = false
        }
    }
    
    func selectEmployee(_ employee: Employee) {
        withAnimation {
            self.employee = employee
            employeeSelected = true
        }
    }
    
    func newEmployee() {
        withAnimation {
            if !employee.name.isEmpty && !employee.lastName.isEmpty {
                employeeC.addEmployee(employee)
                employee = Employee()
            } else {
                fieldsEmptyAlert = true
            }
        }
    }
    
    func onAppear() {
        accentColor.orange()
        employeeC.currentRestaurantLink = restaurantVM.restaurant.id
        employeeC.fetchEmployees()
    }
}

