//
//  ChecksView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct ChecksView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var date: Date = Date()
    @State private var isLoading: Bool = false
    @State private var checks: [Check] = []
    @State private var checkToDelete: Check? = nil
    @State private var fortnight: Fortnight = .first
    
    private let checkVM = CheckViewModel()
    
    var body: some View {
        Sheet(section: .checks, isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty && !isLoading {
                fortnightPicker
                checksList
            }
        }
        .toolbar(content: toolbarItems)
        .overlay { if employeeVM.employees.isEmpty && !isLoading { EmptyEmployeesChecksView() } }
        .navigationTitle("Cheques - " + date.monthAndYear)
        .onAppear(perform: getChecks)
        .onChange(of: date, getChecks)
    }
    
    private var fortnightPicker: some View {
        Picker("", selection: $fortnight) {
            Text("Primera quincena").tag(Fortnight.first)
            Text("Segunda quincena").tag(Fortnight.second)
        }.pickerStyle(.segmented)
    }
    
    private var checksList: some View {
        WhiteArea(spacing: 0) {
            headerChecks
            ForEach(checks.indices, id: \.self) { index in
                if checks[index].fortnight == fortnight{
                    checksLineList(index: index)
                }
            }
        }
    }
    
    private var headerChecks: some View {
        HStack {
            Text("Empleado").frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Cheques").frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Cash").frame(maxWidth: .infinity, maxHeight: .infinity)
        }.bold().font(.title2).padding(.vertical, 12).foregroundStyle(Color.blue)
    }
    
    private func checksLineList(index: Int) -> some View {
        Group {
            Divider()
            HStack {
                nameButton(index: index)
                quantitiesFields(index: index)
                if checkToDelete == checks[index] { trashButton(index: index) }
            }.padding(.vertical, 12)
        }
    }
    
    private func nameButton(index: Int) -> some View {
        Button(checks[index].employee.fullName) {
            withAnimation {
                checkToDelete = checkToDelete == checks[index] ? nil : checks[index]
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func quantitiesFields(index: Int) -> some View {
        Group {
            TextField("0.00", value: $checks[index].direct, format: .number)
                .multilineTextAlignment(.center)
                .onSubmit { save(check: checks[index]) }
            TextField("0.00", value: $checks[index].cash, format: .number)
                .multilineTextAlignment(.center)
                .onSubmit { save(check: checks[index]) }
        }
    }
    
    private func trashButton(index: Int) -> some View {
        Button(action: {delete(check: checks[index])}) {
            Image(systemName: "trash.fill")
                .foregroundStyle(.white)
                .padding(6)
                .font(.title3)
                .background(Color.red)
                .clipShape(Circle())
                .padding(3)
        }
    }
}

extension ChecksView {
    private func save(check: Check) {
        checkVM.save(check.record, ifNot: {alertVM.show(.updatingError)})
    }
    
    private func delete(check: Check) {
        withAnimation {
            checkVM.delete(check.record, ifNot: {alertVM.show(.deletingError)})
            checks.removeAll { $0 == checkToDelete }
        }
    }
    
    private func getChecks() {
        isLoading = true
        checkVM.fetch(restaurantId: restaurantM.currentId, month: date) { checks in
            if var checks = checks {
                for index in checks.indices {
                    if let employee = employeeVM.employees.first(where: { $0.id == checks[index].employeeId }) {
                        checks[index].employee = employee
                    }
                }
                self.checks = checks
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
}

extension ChecksView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarMenu {
                    ForEach(employeeVM.activeEmployees, id: \.self) { employee in
                        let check = Check(employee: employee, restaurantId: restaurantM.currentId, date: date, fortnight: fortnight)
                        Button(employee.fullName) {
                            withAnimation {
                                checks.append(check)
                                checks.sort()
                                save(check: check)
                            }
                        }
                        .disabled(checks.map({($0.employeeId, $0.fortnight)}).contains(where: {$0.0 == employee.id && $0.1 == fortnight}))
                    }
                }
                UpdateRecordsToolbarButton(action: getChecks)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                CalendarToolbarMenu {
                    MonthPicker("Mes", date: $date)
                    YearPicker("Año", date: $date)
                }
            }
        }
    }
}
