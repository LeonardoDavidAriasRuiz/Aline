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
    @State private var beneficiaries: [Beneficiary] = []
    
    private let checkVM = CheckViewModel()
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty && !isLoading {
                ScrollView(.horizontal) {
                    checksList
                }
            }
        }
        .toolbar(content: toolbarItems)
        .overlay { if employeeVM.employees.isEmpty && !isLoading { EmptyEmployeesChecksView() } }
        .navigationTitle("Cheques - " + date.monthAndYear)
        .onAppear(perform: getChecks)
        .onChange(of: date, getChecks)
    }
    
    private var checksList: some View {
        HStack {
            VStack {
                WhiteArea(spacing: 0) {
                    Text("Primera quincena").font(.title).bold().padding(.vertical, 12)
                    Divider()
                    headerChecks
                    ForEach(checks.indices, id: \.self) { index in
                        if checks[index].fortnight == .first, !checkIfIsBeneficiaryCheck(checkIndex: index) {
                            checksLineList(index: index)
                        }
                    }
                    Divider()
                    Menu("Agregar") {
                        ForEach(employeeVM.activeEmployees, id: \.self) { employee in
                            Button(employee.fullName) {
                                withAnimation {
                                    let check = Check(employee: employee, restaurantId: restaurantM.currentId, date: date, fortnight: .first)
                                    checks.append(check)
                                    checks.sort()
                                    save(check: check)
                                }
                            }
                            .disabled(checks.map({($0.employeeId, $0.fortnight)}).contains(where: {$0.0 == employee.id && $0.1 == .first}))
                        }
                    }.padding(.vertical, 12)
                    Divider()
                    HStack {
                        VStack {
                            Text("Total").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).total.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack {
                            Text("Cheques").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).direct.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack {
                            Text("Cash").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).cash.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.padding(.vertical, 12)
                }
                
                ForEach(beneficiaries, id: \.self) { beneficiary in
                    if date >= beneficiary.startEndDates[0],
                       (beneficiary.startEndDates.count > 1 ? date <= beneficiary.startEndDates[1] : true) {
                        WhiteArea(spacing: 0) {
                            Text(beneficiary.fullName).font(.title).bold().padding(.vertical, 12)
                            Divider()
                            headerChecks
                            ForEach(checks.indices, id: \.self) { index in
                                if checks[index].fortnight == .first, 
                                    beneficiary.employeesIds.contains(checks[index].employeeId) {
                                    checksLineList(index: index)
                                }
                            }
                            Divider()
                            Menu("Agregar") {
                                ForEach(employeeVM.activeEmployees, id: \.self) { employee in
                                    Button(employee.fullName) {
                                        withAnimation {
                                            let check = Check(employee: employee, restaurantId: restaurantM.currentId, date: date, fortnight: .first)
                                            checks.append(check)
                                            checks.sort()
                                            save(check: check)
                                        }
                                    }
                                    .disabled(checks.map({($0.employeeId, $0.fortnight)}).contains(where: {$0.0 == employee.id && $0.1 == .first}))
                                }
                            }.padding(.vertical, 12)
                            Divider()
                            HStack {
                                VStack {
                                    Text("Total").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .first, beneficiary: beneficiary).total.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack {
                                    Text("Cheques").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .first, beneficiary: beneficiary).direct.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack {
                                    Text("Cash").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .first, beneficiary: beneficiary).cash.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }.padding(.vertical, 12)
                        }
                    }
                }
            }
            VStack {
                WhiteArea(spacing: 0) {
                    Text("Segunda quincena").font(.title).bold().padding(.vertical, 12)
                    Divider()
                    headerChecks
                    ForEach(checks.indices, id: \.self) { index in
                        if checks[index].fortnight == .second, !checkIfIsBeneficiaryCheck(checkIndex: index) {
                            checksLineList(index: index)
                        }
                    }
                    Divider()
                    Menu("Agregar") {
                        ForEach(employeeVM.activeEmployees, id: \.self) { employee in
                            Button(employee.fullName) {
                                withAnimation {
                                    let check = Check(employee: employee, restaurantId: restaurantM.currentId, date: date, fortnight: .second)
                                    checks.append(check)
                                    checks.sort()
                                    save(check: check)
                                }
                            }
                            .disabled(checks.map({($0.employeeId, $0.fortnight)}).contains(where: {$0.0 == employee.id && $0.1 == .second}))
                        }
                    }.padding(.vertical, 12)
                    Divider()
                    HStack {
                        VStack {
                            Text("Total").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).total.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack {
                            Text("Cheques").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).direct.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack {
                            Text("Cash").bold().font(.title2)
                            Text(getFortnightTotal(fortnight: .first).cash.comasTextWithDecimals)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.padding(.vertical, 12)
                }
                
                ForEach(beneficiaries, id: \.self) { beneficiary in
                    if date >= beneficiary.startEndDates[0],
                       (beneficiary.startEndDates.count > 1 ? date <= beneficiary.startEndDates[1] : true) {
                        WhiteArea(spacing: 0) {
                            Text(beneficiary.fullName).font(.title).bold().padding(.vertical, 12)
                            Divider()
                            headerChecks
                            ForEach(checks.indices, id: \.self) { index in
                                if checks[index].fortnight == .second,
                                    beneficiary.employeesIds.contains(checks[index].employeeId) {
                                    checksLineList(index: index)
                                }
                            }
                            Divider()
                            Menu("Agregar") {
                                ForEach(employeeVM.activeEmployees, id: \.self) { employee in
                                    Button(employee.fullName) {
                                        withAnimation {
                                            let check = Check(employee: employee, restaurantId: restaurantM.currentId, date: date, fortnight: .second)
                                            checks.append(check)
                                            checks.sort()
                                            save(check: check)
                                        }
                                    }
                                    .disabled(checks.map({($0.employeeId, $0.fortnight)}).contains(where: {$0.0 == employee.id && $0.1 == .second}))
                                }
                            }.padding(.vertical, 12)
                            Divider()
                            HStack {
                                VStack {
                                    Text("Total").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .second, beneficiary: beneficiary).total.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack {
                                    Text("Cheques").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .second, beneficiary: beneficiary).direct.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack {
                                    Text("Cash").bold().font(.title2)
                                    Text(getFortnightTotalForBeneficiary(fortnight: .second, beneficiary: beneficiary).cash.comasTextWithDecimals)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }.padding(.vertical, 12)
                        }
                    }
                }
            }
        }.frame(width: 1200)
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
    
    private func getFortnightTotal(fortnight: Fortnight) -> (total: Double, direct: Double, cash: Double) {
        var direct = 0.0
        var cash = 0.0
        
        for check in self.checks where !checkIfIsBeneficiaryCheck(check: check) && check.fortnight == fortnight {
            direct += check.direct
            cash += check.cash
        }
        
        return (direct + cash, direct, cash)
    }
    
    private func getFortnightTotalForBeneficiary(fortnight: Fortnight, beneficiary: Beneficiary) -> (total: Double, direct: Double, cash: Double) {
        var direct = 0.0
        var cash = 0.0
        
        for check in self.checks where beneficiary.employeesIds.contains(check.employeeId) && check.fortnight == fortnight {
            direct += check.direct
            cash += check.cash
        }
        
        return (direct + cash, direct, cash)
    }
    
    private func checkIfIsBeneficiaryCheck(checkIndex: Int) -> Bool {
        for beneficiary in beneficiaries where beneficiary.employeesIds.contains(checks[checkIndex].employeeId) {
            return true
        }
        
        return false
    }
    
    private func checkIfIsBeneficiaryCheck(check: Check) -> Bool {
        for beneficiary in beneficiaries where beneficiary.employeesIds.contains(check.employeeId) {
            return true
        }
        
        return false
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
                print(checks)
                for index in checks.indices {
                    if let employee = employeeVM.employees.first(where: { $0.id == checks[index].employeeId }) {
                        checks[index].employee = employee
                    }
                }
                self.checks = checks
                getBeneficiaries()
            } else {
                isLoading = false
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getBeneficiaries() {
        withAnimation {
            BeneficiaryViewModel().fetch(for: restaurantM.currentId) { beneficiaries in
                if let beneficiaries = beneficiaries {
                    self.beneficiaries = beneficiaries
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
}

extension ChecksView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarTrailing) {
                CalendarToolbarMenu {
                    MonthPicker("Mes", date: $date)
                    YearPicker("Año", date: $date)
                }
            }
        }
    }
}
