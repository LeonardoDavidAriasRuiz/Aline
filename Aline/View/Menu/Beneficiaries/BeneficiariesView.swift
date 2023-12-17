//
//  BeneficiariesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import WebKit
import UIKit

struct BeneficiariesView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var resumes: [Resume] = []
    @State private var sales: [Sale] = []
    @State private var tips: [Tip] = []
    @State private var spendings: [Spending] = []
    @State private var checks: [Check] = []
    @State private var beneficiariesSpendings: [BeneficiarySpending] = []
    
    @State private var beneficiaries: [Beneficiary] = []
    @State private var isLoading: Bool = false
    
    let beneficiaryVM = BeneficiaryViewModel()
    let salesVM = SaleViewModel()
    let tipVM = TipViewModel()
    let checkVM = CheckViewModel()
    let spendingVM = SpendingViewModel()
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            VStack(spacing: 30) {
                WhiteArea(spacing: 10) {
                    VStack {
                        HStack{
                            VStack(spacing: 20) {
                                Text(" ").bold().font(.title2)
                                Text("Fechas").bold().font(.title3)
                                Divider().frame(width: 100)
                                Text("Ventas")
                                Text("Gastos")
                                Text("Tips")
                                Divider().frame(width: 100)
                                Text("Libres")
                            }.padding(.bottom, 20)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(resumes, id: \.self) { resume in
                                        HStack(alignment: .bottom){
                                            VStack(spacing: 20) {
                                                Text(resume.date.monthInt == 1 ? resume.date.year : " ").bold().font(.title2).foregroundStyle(Color.green)
                                                Text(resume.date.month).bold().font(.title3)
                                                Divider()
                                                Text(resume.sale.comasTextWithDecimals)
                                                Text(resume.spending.comasTextWithDecimals)
                                                Text(resume.tip.comasTextWithDecimals)
                                                Divider()
                                                Text((resume.sale - resume.spending - resume.tip).comasTextWithDecimals)
                                            }.frame(width: 150, alignment: .top)
                                        }
                                    }
                                }.padding(.bottom, 20)
                            }
                        }
                    }
                }
                beneficiariesArea
            }
        }
        .navigationTitle(restaurantM.restaurant?.name ?? "Error en el nombre")
        .toolbar(content: toolbarItems)
        .overlay { if beneficiaries.isEmpty, !isLoading { EmptyBeneficiariesView() } }
        .onAppear(perform: fillArrays)
        .onChange(of: restaurantM.currentId, fillArrays)
    }
    
    private var beneficiariesArea: some View {
        ForEach(beneficiaries, id: \.self) { beneficiary in
            WhiteArea(spacing: 10) {
                HStack {
                    NavigationLink(beneficiary.fullName, destination: BeneficiaryView(beneficiary: beneficiary)).bold().font(.title)
                    Spacer()
                }
                HStack {
                    let obteined = getTotalObteinedForBeneficiary(beneficiary) + (beneficiary.status > 0 ? beneficiary.status : 0)
                    let earned = getTotalEarnedItForBeneficiary(beneficiary) + (beneficiary.status < 0 ? (beneficiary.status * -1) : 0)
                    let gaugePercentege = obteined / earned
                    let missing = obteined - earned
                    let tint = gaugePercentege >= 1 ? Color.green : Color.red
                    Gauge(value: gaugePercentege) {}.tint(tint)
                    Text(missing.comasTextWithDecimals)
                }
                HStack{
                    beneficiariesTitles
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(beneficiary.resumes, id: \.self) { resume in
                                HStack(alignment: .bottom){
                                    VStack(spacing: 20) {
                                        Text(resume.date.monthInt == 1 ? resume.date.year : " ").bold().font(.title2).foregroundStyle(Color.green)
                                        Text(resume.date.month).bold().font(.title3)
                                        Divider()
                                        Text(resume.earnings.comasTextWithDecimals)
                                        Text(resume.spendings.comasTextWithDecimals)
                                        Text(resume.free.comasTextWithDecimals)
                                        Divider()
                                        Text(resume.check.comasTextWithDecimals)
                                    }.frame(width: 150, alignment: .top)
                                }
                            }
                        }.padding(.bottom, 20)
                    }
                }

            }
        }
    }
    
    private func getEarningsForBeneficiaryInMonth(beneficiarySpendings: BeneficiarySpendings) -> Double {
        for resume in resumes {
            if beneficiarySpendings.date == resume.date {
                return (resume.sale - resume.spending - resume.tip) * beneficiarySpendings.beneficiary.percentage
            }
        }
        return 0
    }
    
    private var beneficiariesTitles: some View {
        VStack(spacing: 20) {
            Text(" ").bold().font(.title2)
            Text("Fechas").bold().font(.title3)
            Divider().frame(width: 100)
            Text("Ganancias")
            Text("Gastos")
            Text("Limpio")
            Divider().frame(width: 100)
            Text("Cheques")
        }.padding(.bottom, 20)
    }
    
    private func getBeneficiarySpendingTotal(beneficiary: Beneficiary, resume: Resume) -> Double {
        return beneficiary.spendings.first(where: {$0.date == resume.date})?.totalSpendings ?? 0
    }
}

extension BeneficiariesView {
    private func checkFistDate() -> Date {
        let dates = sales.map { $0.date } + tips.map { $0.date } + checks.map { $0.date } + spendings.map { $0.date }
        return dates.min(by: <) ?? Date()
    }
    
    private func fillArrays() {
        getBeneficiaries()
    }
    
    private func getBeneficiaries() {
        withAnimation {
            isLoading = true
            beneficiaryVM.fetch(for: restaurantM.currentId) { beneficiaries in
                if let beneficiaries = beneficiaries {
                    self.beneficiaries = beneficiaries
                    getSales()
                } else {
                    isLoading = false
                    alertVM.show(.dataObtainingError)
                }
            }
        }
    }
    
    private func getSales() {
        withAnimation {
            isLoading = true
            salesVM.fetchSales(for: restaurantM.currentId) { sales in
                if let sales = sales {
                    self.sales = sales
                    getTips()
                } else {
                    isLoading = false
                    alertVM.show(.dataObtainingError)
                }
            }
        }
    }
    
    private func getTips() {
        withAnimation {
            tipVM.fetchTips(employees: employeeVM.employees) { tips in
                if let tips = tips {
                    self.tips = tips
                    getSpendings()
                } else {
                    isLoading = false
                    alertVM.show(.dataObtainingError)
                }
            }
        }
    }
    
    private func getSpendings() {
        spendingVM.fetchSpendings(for: restaurantM.currentId) { spendings in
            if let spendings = spendings {
                self.spendings = spendings
                getChecks()
            } else {
                isLoading = false
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getChecks() {
        isLoading = true
        checkVM.fetch(restaurantId: restaurantM.currentId) { checks in
            if let checks = checks {
                self.checks = checks
                getResumesForDates()
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getResumesForDates() {
        var date = checkFistDate().firstDayOfMonth
        resumes = []
        while date <= Date() {
            var sales = 0.0
            var spendings = 0.0
            var tips = 0.0
            
            for sale in self.sales where sale.date >= date.firstDayOfMonth && sale.date <= date.lastDayOfMonth {
                sales += sale.rtonos
            }
            
            for spending in self.spendings where spending.date >= date.firstDayOfMonth && spending.date <= date.lastDayOfMonth {
                spendings += spending.quantity
            }
            
            for tip in self.tips where tip.date >= date.firstDayOfMonth && tip.date <= date.lastDayOfMonth {
                tips += tip.quantity
            }
            
            let resume = Resume(date: date, sale: sales, tip: tips, spending: spendings)
            resumes.append(resume)
            date = date.firstDayOfNextMonth
        }
        
        getBeneficiariesSpendings()
    }
    
    private func getBeneficiariesSpendings() {
        withAnimation {
            BeneficiarySpendingViewModel().fetch(for: restaurantM.currentId) { spendings in
                if let spendings = spendings {
                    self.beneficiariesSpendings = spendings
                    for index in self.beneficiaries.indices {
                        setBeneficiarySpendingsDates(beneficiaryIndex: index)
                    }
                } else {
                    alertVM.show(.dataObtainingError)
                }
            }
        }
    }
    
    private func setBeneficiarySpendingsDates(beneficiaryIndex index: Int) {
        withAnimation {
            let beneficiary = beneficiaries[index]
            var date = beneficiary.startEndDates[0].firstDayOfMonth
            let endDate: Date = beneficiary.startEndDates.count <= 1 ? Date() : beneficiary.startEndDates[1]
            beneficiaries[index].resumes = []
            
            while date <= endDate {
                let employeesIds = beneficiary.employeesIds
                var sumEarnings = 0.0
                var sumSpendings = 0.0
                var sumChecks = 0.0
                
                for resume in resumes where resume.date == date {
                    sumEarnings = (resume.sale - resume.spending - resume.tip) * beneficiary.percentage
                }
                
                for spending in self.beneficiariesSpendings where beneficiary.id == spending.beneficiaryId && spending.date >= date.firstDayOfMonth && spending.date <= date.lastDayOfMonth {
                    sumSpendings += spending.quantity
                }
                
                for check in self.checks where employeesIds.contains(check.employeeId) && check.date >= date.firstDayOfMonth && check.date <= date.lastDayOfMonth {
                    sumChecks += check.cash + check.direct
                }
                
                let resume = BeneficiaryResume(date: date, earnings: sumEarnings, spendings: sumSpendings, check: sumChecks)
                beneficiaries[index].resumes.append(resume)
                date = date.firstDayOfNextMonth
            }
            
            isLoading = false
        }
    }
    
    func updateSalesInResumes(resumes: inout [Resume], sales: [Sale]) {
        let calendar = Calendar.current

        for i in 0..<resumes.count {
            let resumeMonth = calendar.component(.month, from: resumes[i].date)
            let resumeYear = calendar.component(.year, from: resumes[i].date)

            let monthlySales = sales.filter { sale in
                let saleMonth = calendar.component(.month, from: sale.date)
                let saleYear = calendar.component(.year, from: sale.date)
                return saleMonth == resumeMonth && saleYear == resumeYear
            }

            let totalSales = monthlySales.reduce(0) { $0 + $1.rtonos }
            resumes[i].sale = totalSales
        }
    }
    
    private func getTotalObteinedForBeneficiary(_ beneficiary: Beneficiary) -> Double {
        
        var total = 0.0
        
        for resume in beneficiary.resumes {
            total += resume.check + resume.spendings
        }
        
        return total
    }
    
    private func getTotalEarnedItForBeneficiary(_ beneficiary: Beneficiary) -> Double {
        
        var total = 0.0
        
        for resume in beneficiary.resumes {
            total += resume.earnings
        }
        
        return total
    }
}

extension BeneficiariesView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewBeneficiaryView())
                UpdateRecordsToolbarButton(action: fillArrays)
            }
        }
    }
    
    func createCSVBeneficiaries() -> Data? {
        var csvString = "Nombre,Descripción\n"
        
        for beneficiary in beneficiaries {
            
            var endDateToCSV: String
            
            if beneficiary.startEndDates.count == 1 {
                endDateToCSV = "nil"
            } else {
                endDateToCSV = beneficiary.startEndDates[0].shortDate
            }
            
            csvString.append("\(beneficiary.id),\(beneficiary.name),\(beneficiary.lastName),\(beneficiary.percentage),\(beneficiary.startEndDates[0].shortDate),\(endDateToCSV)\n")
        }
        
        return csvString.data(using: .utf8)
    }
}

struct Resume: Hashable {
    var id = UUID().uuidString
    let date: Date
    var sale: Double
    var tip: Double
    var spending: Double
}

struct BeneficiaryResume: Hashable {
    var id = UUID().uuidString
    let date: Date
    var earnings: Double
    var spendings: Double
    var free: Double { earnings - spendings }
    var check: Double
}
