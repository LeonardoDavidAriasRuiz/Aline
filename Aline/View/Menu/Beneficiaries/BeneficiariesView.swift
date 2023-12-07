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
    
    @State private var beneficiaries: [Beneficiary] = []
    @State private var beneficiariesSpendingsOpened: [String : Bool] = [:]
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
                    Text(beneficiary.fullName).bold().font(.title)
                    Spacer()
                }
                HStack {
                    Gauge(value: 0.3) {}.tint(Color.red)
                    Text("100")
                }
                HStack{
                    beneficiariesTitles
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(resumes, id: \.self) { resume in
                                beneficiaryQuantities(beneficiary: beneficiary, resume: resume)
                            }
                        }.padding(.bottom, 20)
                    }
                }

            }
        }
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
    
    private func beneficiaryQuantities(beneficiary: Beneficiary, resume: Resume) -> some View {
        HStack(alignment: .bottom){
            VStack(spacing: 20) {
                Text(resume.date.monthInt == 1 ? resume.date.year : " ").bold().font(.title2).foregroundStyle(Color.green)
                Text(resume.date.month).bold().font(.title3)
                Divider()
                Text(((resume.sale - resume.spending - resume.tip) * beneficiary.percentage).comasTextWithDecimals)
                Text(0.0.comasTextWithDecimals)
                Text(0.0.comasTextWithDecimals)
                Divider()
                Text(0.0.comasTextWithDecimals)
            }.frame(width: 150, alignment: .top)
        }
    }
}

extension BeneficiariesView {
    private func checkFistDate() -> Date {
        var firstDate = Date()
        for sale in self.sales {
            firstDate = firstDate < sale.date ? firstDate : sale.date
        }
        for tip in self.tips {
            firstDate = firstDate < tip.date ? firstDate : tip.date
        }
        for check in self.checks {
            firstDate = firstDate < check.date ? firstDate : check.date
        }
        for spending in self.spendings {
            firstDate = firstDate < spending.date ? firstDate : spending.date
        }
        
        return firstDate
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
                    for beneficiary in self.beneficiaries {
                        self.beneficiariesSpendingsOpened[beneficiary.id] = false
                    }
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
        print("Entro a obtener gastos")
        spendingVM.fetchSpendings(for: restaurantM.currentId) { spendings in
            if let spendings = spendings {
                print(spendings)
                self.spendings = spendings
                getChecks()
            } else {
                isLoading = false
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getChecks() {
        print("Entro a obtener cheques")
        isLoading = true
        checkVM.fetch(restaurantId: restaurantM.currentId) { checks in
            if let checks = checks {
                self.checks = checks
                getResumesForDates()
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
    
    private func getResumesForDates() {
        var currentDate = checkFistDate()
        var firstDaysOfMonth = [Date]()
        
        while currentDate <= Date() {
            firstDaysOfMonth.append(currentDate.firstDayOfMonth)
            let components = DateComponents(year: currentDate.yearInt, month: currentDate.monthInt + 1, day: 1, hour: 0, minute: 0, second: 0)
            if let newtMonth = Calendar.current.date(from: components) {
                currentDate = newtMonth
            } else {
                break
            }
        }
        resumes = firstDaysOfMonth.map {Resume(date: $0, sale: 0, tip: 0, spending: 0, check: 0)}
        groupSales()
    }
    
    private func groupSales() {
        for index in resumes.indices {
            for sale in sales {
                if sale.date >= resumes[index].date.firstDayOfMonth,
                   sale.date <= resumes[index].date.lastDayOfMonth {
                    resumes[index].sale += sale.rtonos
                    sales.removeAll(where: {$0 == sale})
                }
            }
        }
        groupSpendings()
    }
    
    private func groupSpendings() {
        for index in resumes.indices {
            for spending in spendings {
                if spending.date >= resumes[index].date.firstDayOfMonth,
                   spending.date <= resumes[index].date.lastDayOfMonth {
                    resumes[index].spending += spending.quantity
                    spendings.removeAll(where: {$0 == spending})
                }
            }
        }
        groupTips()
    }
    
    private func groupTips() {
        for index in resumes.indices {
            for tip in tips {
                if tip.date >= resumes[index].date.firstDayOfMonth,
                   tip.date <= resumes[index].date.lastDayOfMonth {
                    resumes[index].tip += tip.quantity
                    tips.removeAll(where: {$0 == tip})
                }
            }
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
}

extension BeneficiariesView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewBeneficiaryView())
                UpdateRecordsToolbarButton(action: fillArrays)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu("Beneficiarios") {
                    ForEach(beneficiaries, id: \.self) { beneficiary in
                        Menu(beneficiary.fullName) {
                            Button("Editar", action: {})
                            Button("Termino", action: {})
                        }
                    }
                }
            }
        }
    }
    
    func createCSVBeneficiaries() -> Data? {
        var csvString = "Nombre,Descripción\n"
        for beneficiary in beneficiaries {
            csvString.append("\(beneficiary.id),\(beneficiary.name),\(beneficiary.lastName),\(beneficiary.percentage),\(beneficiary.startDate.shortDate),\(beneficiary.endDate?.shortDate ?? "Nil")\n")
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
    var check: Double
//    var beneficiaries
}

struct BeneficiarySpending: Hashable {
    var id = UUID().uuidString
    let beneficiaryId: String
    var quantity: Double
    var note: String
}
