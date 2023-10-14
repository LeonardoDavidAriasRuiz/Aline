//
//  NewBeneficiaryView.swift
//  Aline
//
//  Created by Leonardo on 28/09/23.
//

import SwiftUI

struct NewBeneficiaryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var newBeneficiary: Beneficiary = Beneficiary()
    @State private var employees: [Employee] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .newBeneficiary, isLoading: $isLoading) {
            WhiteArea {
                TextField("Nombre", text: $newBeneficiary.name).foregroundStyle(.secondary).padding(.vertical, 10)
                Divider()
                TextField("Apellido", text: $newBeneficiary.lastName).foregroundStyle(.secondary).padding(.vertical, 10)
                Divider()
                HStack {
                    Text("\((newBeneficiary.percentage * 100).comasText)%").frame(width: 60)
                    Slider(value: $newBeneficiary.percentage, in: 0...1, step: 0.01)
                }.padding(.vertical, 10)
            }
            
            WhiteArea {
                ForEach(employees, id: \.self) { employee in
                    Button(action: {selectEmployee(employee)}) {
                        HStack {
                            Text(employee.fullName)
                                .foregroundStyle(newBeneficiary.employeesIds.contains(employee.id) ? .primary : .secondary)
                            Spacer()
                            Image(systemName: newBeneficiary.employeesIds.contains(employee.id) ? "person.fill" : "person")
                                .foregroundStyle(newBeneficiary.employeesIds.contains(employee.id) ? Color.green : Color.secondary)
                        }.padding(.vertical, 10)
                    }
                    if employees.last != employee {
                        Divider()
                    }
                }
            }
            WhiteArea {
                DatePicker("Inicio", selection: $newBeneficiary.startDate, displayedComponents: .date).padding(.vertical, 10)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: discard) {
                    Text("Descartar").foregroundStyle(Color.red)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: save) {
                    Text("Guardar").foregroundStyle(Color.green)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: getEmployees)
    }
    
    private func selectEmployee(_ employee: Employee) {
        if newBeneficiary.employeesIds.contains(employee.id),
           let index = newBeneficiary.employeesIds.firstIndex(of: employee.id){
            newBeneficiary.employeesIds.remove(at: index)
        } else {
            newBeneficiary.employeesIds.append(employee.id)
        }
    }
    
    private func save() {
        withAnimation {
            isLoading = true
            newBeneficiary.restaurantId = restaurantM.currentId
            BeneficiaryViewModel().save(newBeneficiary.record) {
                discard()
            } ifNot: {
                alertVM.show(.crearingError)
            } alwaysDo: {
                isLoading = false
            }
        }
    }
    
    private func discard() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func getEmployees() {
        withAnimation {
            isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                EmployeeViewModel().fetch(restaurantId: restaurantId) { employees in
                    if let employees = employees {
                        self.employees = employees
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    isLoading = false
                }
            }
        }
    }
}
