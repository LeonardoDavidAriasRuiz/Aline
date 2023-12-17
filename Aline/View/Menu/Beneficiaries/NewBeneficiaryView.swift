//
//  NewBeneficiaryView.swift
//  Aline
//
//  Created by Leonardo on 28/09/23.
//

import SwiftUI

struct NewBeneficiaryView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newBeneficiary: Beneficiary = Beneficiary()
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
                ForEach(employeeVM.employees, id: \.self) { employee in
                    Button(action: {selectEmployee(employee)}) {
                        HStack {
                            Text(employee.fullName)
                                .foregroundStyle(newBeneficiary.employeesIds.contains(employee.id) ? .primary : .secondary)
                            Spacer()
                            Image(systemName: newBeneficiary.employeesIds.contains(employee.id) ? "person.fill" : "person")
                                .foregroundStyle(newBeneficiary.employeesIds.contains(employee.id) ? Color.green : Color.secondary)
                        }.padding(.vertical, 10)
                    }
                    if employeeVM.employees.last != employee {
                        Divider()
                    }
                }
            }
            
            WhiteArea {
                DatePicker("", selection: $newBeneficiary.startEndDates[0], displayedComponents: .date).datePickerStyle(.graphical)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: {dismiss()}) {
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
                dismiss()
            } ifNot: {
                isLoading = false
                alertVM.show(.crearingError)
            }
        }
    }
}
