//
//  TipsCashOutView.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import SwiftUI

struct TipsCashOutView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var tipsTotal: Double = 0.0
    @State private var tipsForEmployees: [TipForEmployee] = []
    @State private var employeesCountSelected: Int = 0
    @State private var tipsForReview: TipsReview = TipsReview()
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty {
                quantityArea
                employeesSelection
                notesArea
                dateTimesPickers
            }
        }
        .toolbar  {
            ToolbarItem(placement: .topBarLeading) {
                UpdateRecordsToolbarButton(action: getEmployees)
            }
            ToolbarItem(placement: .topBarTrailing) {
                saveToolBarButton
            }
        }
        .overlay { if employeeVM.employees.isEmpty, !isLoading { EmptyEmployeesCashOutView() } }
        .onChange(of: employeeVM.employees, getEmployees)
        .onAppear(perform: getEmployees)
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfReadyToSave() {
                Button(action: sendTipsForReview) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    if tipsTotal <= 0.0 {
                        Text("Escribe una cantidad correcta.")
                    }
                    if tipsForReview.notes.isEmpty {
                        Text("Escribe algo en notas.")
                    }
                    if employeesCountSelected <= 0 {
                        Text("Selcciona los empleados.")
                    }
                }
            }
        }
    }
    
    private var dateTimesPickers: some View {
        WhiteArea {
            Divider()
            DatePicker("", selection: $tipsForReview.from, displayedComponents: .date)
                .datePickerStyle(.graphical)
            HStack {
                DatePicker("De:", selection: $tipsForReview.from, displayedComponents: .hourAndMinute)
                    .frame(maxWidth: 200)
                    .datePickerStyle(.graphical)
                    .onChange(of: tipsForReview.from, validateCustomFrom)
                DatePicker("A:", selection: $tipsForReview.to, displayedComponents: .hourAndMinute)
                    .frame(maxWidth: 200)
                    .datePickerStyle(.graphical)
                    .onChange(of: tipsForReview.to, validateCustomTo)
            }
        }
    }
    
    private var quantityArea: some View {
        WhiteArea {
            HStack {
                Text("Cantidad: ")
                DecimalField("Tips", decimal: $tipsTotal, alignment: .leading)
            }.padding(.vertical, 8)
        }
    }
    
    private var employeesSelection: some View {
        WhiteArea {
            ForEach(tipsForEmployees.indices, id: \.self) { index in
                HStack {
                    Text(tipsForEmployees[index].employee.fullName)
                    Spacer()
                    if employeesCountSelected != 0, tipsForEmployees[index].selected, tipsTotal != 0.0 {
                        let tipAmount: Double = tipsTotal / Double(employeesCountSelected)
                        Text(tipAmount.comasTextWithDecimals).foregroundStyle(.secondary)
                    }
                    Toggle("", isOn: $tipsForEmployees[index].selected).frame(width: 50)
                        .onChange(of: tipsForEmployees, getNumberOfEmployeesSelected)
                }.padding(.vertical, 8)
                if tipsForEmployees.last != tipsForEmployees[index] {
                    Divider()
                }
            }
        }
    }
    
    private var notesArea: some View {
        WhiteArea {
            TextEditor(text: $tipsForReview.notes)
                .foregroundStyle(tipsForReview.notes == TipsReview().notes ? .secondary : .primary)
                .frame(height: 80)
        }
    }
    
    private func sendTipsForReview() {
        isLoading = true
        for tipForEmployee in tipsForEmployees {
            if tipForEmployee.selected {
                tipsForReview.employeesIds.append(tipForEmployee.employee.id)
                tipsForReview.quantityForEach = tipsTotal / Double(employeesCountSelected)
            }
        }
        tipsForReview.restaurantId = restaurantM.currentId
        TipsReviewViewModel().save(tipsForReview.record) {
            tipsForReview = TipsReview()
            tipsTotal = 0.0
            getEmployees()
        } ifNot: {
            alertVM.show(.crearingError)
        } alwaysDo: {
            isLoading = false
        }
    }
    
    private func validateCustomFrom(_ oldValue: Date, _ newValue: Date) {
        if newValue > tipsForReview.to {
            tipsForReview.to = newValue
        } else if tipsForReview.to.timeIntervalSince(newValue) > 86400 {
            tipsForReview.to = newValue
        }
    }
    
    private func validateCustomTo(_ oldValue: Date, _ newValue: Date) {
        if newValue < tipsForReview.from {
            tipsForReview.from = newValue
        } else if newValue.timeIntervalSince(tipsForReview.from) > 86400 {
            tipsForReview.from = newValue
        }
    }
    
    private func checkIfReadyToSave() -> Bool {
        tipsTotal > 0.0 &&
        tipsForReview.notes.isNotEmpty &&
        employeesCountSelected > 0
    }
    
    private func getNumberOfEmployeesSelected() {
        withAnimation {
            employeesCountSelected = tipsForEmployees.filter { $0.selected }.count
        }
    }
    
    private func getEmployees() {
        withAnimation {
            tipsForEmployees = []
            for employee in employeeVM.employees {
                if employee.isActive {
                    tipsForEmployees.append(TipForEmployee(employee: employee))
                }
            }
        }
    }
}

struct TipForEmployee: Equatable {
    let employee: Employee
    var selected: Bool = false
}
