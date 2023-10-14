//
//  TipsCashOutView.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import SwiftUI

struct TipsCashOutView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var tipsTotal: Double = 0.0
    @State private var employees: [Employee] = []
    @State private var isEmployeeSelected: [Bool] = []
    @State private var employeesCountSelected: Int = 0
    @State private var tipsForReview: TipsReview = TipsReview()
    @State private var fromDatePickerShowed: Bool = false
    @State private var toDatePickerShowed: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            if employees.isNotEmpty {
                dateTimesPickers2
                quantityArea
                employeesSelection
                notesArea
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
        .overlay {
            if employees.isEmpty, !isLoading {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin empleados") },
                        icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.red) }
                    )
                }, description: {
                    Text("Los nuevos empleados se mostrarán aquí.")
                })
            }
        }
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
    
    private var dateTimesPickers2: some View {
        WhiteArea {
            OpenSectionButton(pressed: $fromDatePickerShowed, text: "\(tipsForReview.from.shortDateTime) - \(tipsForReview.to.time)")
            if fromDatePickerShowed {
                Divider()
                HStack {
                    DatePicker("", selection: $tipsForReview.from, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .onTapGesture (perform: hideKeyboard)
                    DatePicker("", selection: $tipsForReview.from, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                        .onTapGesture (perform: hideKeyboard)
                        .onChange(of: tipsForReview.from, validateCustomFrom)
                    DatePicker("", selection: $tipsForReview.to, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                        .onTapGesture (perform: hideKeyboard)
                        .onChange(of: tipsForReview.to, validateCustomTo)
                }
            }
        }
    }
    
    private var quantityArea: some View {
        WhiteArea {
            HStack {
                Text("Cantidad: ").onTapGesture (perform: hideKeyboard)
                DecimalField("Tips", decimal: $tipsTotal)
            }.padding(.vertical, 8)
        }
    }
    
    private var employeesSelection: some View {
        WhiteArea {
            ForEach(employees.indices, id: \.self) { index in
                HStack {
                    Text(employees[index].fullName)
                    Spacer()
                    if employeesCountSelected != 0,
                    isEmployeeSelected[index],
                    tipsTotal != 0.0 {
                        let tipAmount: Double = tipsTotal / Double(employeesCountSelected)
                        Text(String(format: "%.2f", tipAmount))
                            .foregroundStyle(.secondary)
                    }
                    if $isEmployeeSelected.isNotEmpty {
                        Toggle("", isOn: $isEmployeeSelected[index])
                            .frame(width: 50)
                            .onChange(of: isEmployeeSelected, getNumberOfEmployeesSelected)
                    }
                }.padding(.vertical, 8)
                if employees.last != employees[index] {
                    Divider()
                }
            }
        }
        .onTapGesture (perform: hideKeyboard)
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
        for index in employees.indices {
            if isEmployeeSelected[index] {
                tipsForReview.employeesIds.append(employees[index].id)
                tipsForReview.quantityForEach = tipsTotal / Double(employeesCountSelected)
            }
        }
        tipsForReview.restaurantId = restaurantM.currentId
        TipsReviewViewModel().save(tipsForReview) { saved in
            if saved {
                tipsForReview = TipsReview()
                tipsTotal = 0.0
                isEmployeeSelected = isEmployeeSelected.map({_ in false})
            } else {
                alertVM.show(.crearingError)
            }
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
            employeesCountSelected = isEmployeeSelected.filter { $0 }.count
        }
    }
    
    private func getEmployees() {
        isLoading = true
        if let restaurantId = restaurantM.restaurant?.id {
            EmployeeViewModel().fetch(restaurantId: restaurantId) { employees in
                if let employees = employees {
                    self.employees = employees.filter { $0.isActive }
                    isEmployeeSelected = Array(repeating: false, count: employees.count)
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
