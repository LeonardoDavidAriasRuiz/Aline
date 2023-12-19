//
//  TipsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct TipsView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var tipsReviews: [TipsReview] = []
    @State private var tipSeleceted: Tip = Tip()
    @State private var tipEditableAreaShowed: Bool = false
    @State private var isLoading: Bool = false
    @State private var tips: [Tip] = []
    @State private var date: Date = Date()
    @State private var totalsFirstFortnight: [FortnightTotalTips] = []
    @State private var totalsSecondFortnight: [FortnightTotalTips] = []
    @State private var totalSelected: String? = nil
    
    let tipVM = TipViewModel()
    let tipReviewVM = TipsReviewViewModel()
    
    private var firstFortnightDates: [Date] {
        return (1...15).compactMap { day in
            let components = DateComponents(year: date.yearInt, month: date.monthInt, day: day)
            return Calendar.current.date(from: components)
        }
    }
    
    private var secondFortnightDates: [Date] {
        return (16...date.lastDayOfMonth.dayInt).compactMap { day in
            let components = DateComponents(year: date.yearInt, month: date.monthInt, day: day)
            return Calendar.current.date(from: components)
        }
    }
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty {
                tipsReviews.isNotEmpty ? tipsReviewsList : nil
                firstFortnightTips
                totalsFirstFortnightArea
                secondFortnightTips
                totalsSecondFortnightArea
            }
        }
        .toolbar(content: toolbarItems)
        .overlay { if employeeVM.employees.isEmpty && !isLoading { EmptyTipsView() } }
        .navigationTitle("Tips - " + date.monthAndYear + "    " + getTotal().comasTextWithDecimals)
        .onAppear(perform: getTipsReviews)
        .onChange(of: restaurantM.currentId, getTipsReviews)
        .onChange(of: date, getTipsReviews)
    }
    
    private var tipsReviewsList: some View {
        VStack(alignment: .leading){
            Header("Tips para revisar")
            WhiteArea {
                ForEach(tipsReviews) { tipsReview in
                    tipsReviewNavigationButton(tipsReview)
                }
            }
        }.padding(.bottom, 30)
    }
    
    private var firstFortnightTips: some View {
        WhiteArea {
            HStack(spacing: 0) {
                employeesListColumn
                ScrollView(.horizontal){
                    HStack(spacing: 0) {
                        ForEach(firstFortnightDates, id: \.self) { day in
                            dayColumn(day)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var secondFortnightTips: some View {
        WhiteArea {
            HStack(spacing: 0) {
                employeesListColumn
                ScrollView(.horizontal){
                    HStack(spacing: 0) {
                        ForEach(secondFortnightDates, id: \.self) { day in
                            dayColumn(day)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var totalsFirstFortnightArea: some View {
        WhiteArea {
            HStack(spacing: 0) {
                ScrollView(.horizontal){
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            HStack {
                                Text("Empleado")
                            }
                                .frame(width: 135)
                            Text("Ω2")
                                .frame(width: 135)
                            Text("Cheque").foregroundStyle(Color.blue)
                                .frame(width: 135)
                            Text("Cash").foregroundStyle(Color.red)
                                .frame(width: 135)
                            Text("Entregado").foregroundStyle(Color.orange)
                                .frame(width: 135)
                        }.bold().font(.title3).frame(height: 60)
                        ForEach(totalsFirstFortnight.sorted().indices, id: \.self) { index in
                            Divider()
                            HStack {
                                Text(totalsFirstFortnight[index].employee?.fullName ?? "Error")
                                    .frame(width: 135)
                                Text(totalsFirstFortnight[index].total.comasTextWithDecimals)
                                    .frame(width: 135)
                                if totalSelected == totalsFirstFortnight[index].id {
                                    DecimalField("0.0", decimal: $totalsFirstFortnight[index].direct)
                                        .frame(width: 135)
                                        .disabled(totalsFirstFortnight[index].delivered)
                                        .onSubmit {saveTotal(total: totalsFirstFortnight[index])}
                                } else {
                                    Button(totalsFirstFortnight[index].direct.comasTextWithDecimals, action: {selectTotal(index: index, fortnight: 1)})
                                        .frame(width: 135)
                                        .disabled(totalsFirstFortnight[index].delivered)
                                        .foregroundStyle(Color.text.opacity(totalsFirstFortnight[index].direct == 0 ? 0.5 : 1))
                                }
                                Text(totalsFirstFortnight[index].cahs.comasTextWithDecimals)
                                    .frame(width: 135)
                                Toggle("", isOn: $totalsFirstFortnight[index].delivered)
                                    .frame(width: 135)
                                    .onChange(of: totalsFirstFortnight[index].delivered) {saveTotal(total: totalsFirstFortnight[index])}
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var totalsSecondFortnightArea: some View {
        WhiteArea {
            HStack(spacing: 0) {
                ScrollView(.horizontal){
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            Text("Empleado")
                                .frame(width: 135)
                            Text("Ω2")
                                .frame(width: 135)
                            Text("Cheque").foregroundStyle(Color.blue)
                                .frame(width: 135)
                            Text("Cash").foregroundStyle(Color.red)
                                .frame(width: 135)
                            Text("Entregado").foregroundStyle(Color.orange)
                                .frame(width: 135)
                        }.bold().font(.title3).frame(height: 60)
                        ForEach(totalsSecondFortnight.sorted().indices, id: \.self) { index in
                            Divider()
                            HStack {
                                Text(totalsSecondFortnight[index].employee?.fullName ?? "Error")
                                    .frame(width: 135)
                                Text(totalsSecondFortnight[index].total.comasTextWithDecimals)
                                    .frame(width: 135)
                                if totalSelected == totalsSecondFortnight[index].id {
                                    DecimalField("0.0", decimal: $totalsSecondFortnight[index].direct)
                                        .frame(width: 135)
                                        .disabled(totalsSecondFortnight[index].delivered)
                                        .onSubmit {saveTotal(total: totalsSecondFortnight[index])}
                                } else {
                                    Button(totalsSecondFortnight[index].direct.comasTextWithDecimals, action: {selectTotal(index: index, fortnight: 2)})
                                        .frame(width: 135)
                                        .disabled(totalsSecondFortnight[index].delivered)
                                        .foregroundStyle(Color.text.opacity(totalsSecondFortnight[index].direct == 0 ? 0.5 : 1))
                                }
                                Text(totalsSecondFortnight[index].cahs.comasTextWithDecimals)
                                    .frame(width: 135)
                                Toggle("", isOn: $totalsSecondFortnight[index].delivered)
                                    .frame(width: 135)
                                    .onChange(of: totalsSecondFortnight[index].delivered) {saveTotal(total: totalsSecondFortnight[index])}
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var employeesListColumn: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("")
                Text("Empleado")
            }.bold().font(.title3).frame(height: 60)
            ForEach(employeeVM.employees, id: \.self) { employee in
                Divider()
                Text(employee.fullName).frame(height: 40)
            }
        }.frame(minWidth: 60, maxWidth: 200)
    }
    
    private func tipsReviewNavigationButton(_ tipsReview: TipsReview) -> some View {
        VStack(spacing: 0) {
            NavigationLink(destination: TipsReviewView(tipsReview, tipsReviews: $tipsReviews)) {
                HStack {
                    Text("\(tipsReview.from.shortDateTime) - \(tipsReview.to.hour)")
                    Spacer()
                    Image(systemName: "chevron.right")
                }.padding(.vertical, 8)
            }
            if tipsReview != tipsReviews.last {
                Divider()
            }
        }
    }
    
    private func dayColumn(_ day: Date) -> some View {
        HStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                dayHeader(day)
                ForEach(employeeVM.employees, id: \.self) { employee in
                    employeeTip(day: day, employee: employee)
                }
            }.frame(width: 135)
        }
    }
    
    private func dayHeader(_ day: Date) -> some View {
        let bold = day.weekdayInt == 1 || day.weekdayInt == 7
        let colorText = bold ?  Color.orange : Color.text
        return VStack(spacing: 0) {
            Text(day.day)
            Text(day.weekday)
                .bold(bold)
                .foregroundStyle(colorText)
        }.font(.title3).frame(height: 60)
    }
    
    private func employeeTip(day: Date, employee: Employee) -> some View {
        let tip = getTipFor(employee: employee, date: day)
        return VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                if tipSeleceted.checkNameAndDate(tip) {
                    DecimalField("0.00", decimal: $tipSeleceted.quantity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.whiteArea)
                        .padding(2)
                        .onSubmit(saveTip)
                } else {
                    Button(action: {selectTip(tip)}) {
                        Text(tip.quantity.comasTextWithDecimals)
                            .foregroundStyle(Color.text.opacity(tip.quantity == 0 ? 0.2 : 1))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(2)
                            .background(Color.whiteArea)
                    }
                }
            }
            .frame(height: 40)
            .background(tipSeleceted.checkNameAndDate(tip) ? Color.orange : Color.whiteArea)
        }
    }
}

extension TipsView {
    private func saveTotal(total: FortnightTotalTips) {
        tipVM.save(total.record) {} ifNot: {
            alertVM.show(.updatingError)
        }
    }
    private func selectTotal(index: Int, fortnight: Int) {
        if fortnight == 1 {
            totalSelected = totalSelected == totalsFirstFortnight[index].id ? nil : totalsFirstFortnight[index].id
        } else {
            totalSelected = totalSelected == totalsSecondFortnight[index].id ? nil : totalsSecondFortnight[index].id
        }
    }
    
    private func saveTip() {
        tipVM.save(tipSeleceted.record, ifNot: {
            alertVM.show(.updatingError)
        })
    }
    
    private func updateTip() {
        if let index = tips.firstIndex(where: { $0.employeeId == tipSeleceted.employeeId && $0.date == tipSeleceted.date }),
           tips[index].quantity != tipSeleceted.quantity {
            tips[index].quantity = tipSeleceted.quantity
            tipSeleceted.quantity == 0 ? deleteTip() : saveTip()
        }
    }
    
    private func getTipsReviews() {
        withAnimation {
            isLoading = true
            tipReviewVM.fetchTips(for: restaurantM.currentId) { tipsReviews in
                if let tipsReviews = tipsReviews {
                    self.tipsReviews = tipsReviews
                } else {
                    alertVM.show(.dataObtainingError)
                }
                getTips()
            }
        }
    }
    
    private func getTips() {
        withAnimation {
            tipVM.fetchTips(employees: employeeVM.employees, date: date) { tips in
                if let tips = tips {
                    self.tips = tips
                    getTotalFortnights()
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    private func getTotalFortnights() {
        print("Va a buscar")
        tipVM.fetchTotalFortnights(restaurantId: restaurantM.currentId, date: date) { totals in
            print("Entro a buscarlo")
            if let totals = totals {
                
                self.totalsFirstFortnight = []
                self.totalsSecondFortnight = []
                print(employeeVM.employees)
                for employee in employeeVM.employees {
                    var totalFirst = 0.0
                    var totalSecond = 0.0
                    
                    for tip in tips where tip.employeeId == employee.id  {
                        if tip.date.dayInt <= 15 {
                            totalFirst += tip.quantity
                        } else {
                            totalSecond += tip.quantity
                        }
                    }
                    
                    let totalTipFirstFortnight = FortnightTotalTips(
                        date: date.firstDayOfMonth,
                        employee: employee,
                        total: totalFirst,
                        direct: totalFirst,
                        restaurantId: restaurantM.currentId
                    )
                    
                    let totalTipSecondFortnight = FortnightTotalTips(
                        date: date.lastDayOfMonth.firstDayOfFortnight,
                        employee: employee,
                        total: totalSecond,
                        direct: totalSecond,
                        restaurantId: restaurantM.currentId
                    )
                    
                    totalsFirstFortnight.append(totalTipFirstFortnight)
                    totalsSecondFortnight.append(totalTipSecondFortnight)
                    
                    for total in totals where date.firstDayOfMonth == total.date  {
                        for index in totalsFirstFortnight.indices where totalsFirstFortnight[index].employeeId == total.employeeId {
                            let ayudante = totalsFirstFortnight[index]
                            totalsFirstFortnight[index] = total
                            totalsFirstFortnight[index].total = ayudante.total
                        }
                    }
                    
                    for total in totals where date.lastDayOfMonth.firstDayOfFortnight == total.date  {
                        for index in totalsSecondFortnight.indices where totalsSecondFortnight[index].employeeId == total.employeeId {
                            totalsSecondFortnight[index] = total
                        }
                    }
                }
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getTipFor(employee: Employee, date: Date) -> Tip {
        tips.first { $0.employeeId == employee.id && $0.date == date } ?? Tip(employee: employee, date: date)
    }
    
    private func selectTip(_ tip: Tip) {
        withAnimation {
            updateTip()
            tipSeleceted = tip
        }
    }
    
    private func deleteTip() {
        tipVM.delete(tipSeleceted.record, ifNot: {
            alertVM.show(.updatingError)
        })
    }
    
    private func getTotalForEmployeeFirtsFortnight(_ employee: Employee) -> Double {
        
        var total = 0.0
        
        for tip in tips where Array(1...15).contains(tip.date.dayInt) &&
        tip.employeeId == employee.id {
            total += tip.quantity
        }
        
        return total
    }
    
    private func getTotalForEmployeeSecondFortnight(_ employee: Employee) -> Double {
        
        var total = 0.0
        
        let lastDaySecondFortNight = date.lastDayOfMonth
        
        for tip in tips where Array(16...lastDaySecondFortNight.dayInt).contains(tip.date.dayInt) &&
        tip.date <= lastDaySecondFortNight && tip.employeeId == employee.id {
            total += tip.quantity
        }
        
        return total
    }
    
    private func getTotal() -> Double {
        var total = 0.0
        
        for tip in self.tips {
            total += tip.quantity
        }
        
        return total
    }
}

extension TipsView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarTrailing) {
                CalendarToolbarMenu {
                    MonthPicker(date.month, date: $date)
                    YearPicker(date.year, date: $date)
                }
            }
            
            ToolbarItemGroup(placement: .topBarLeading) {
                UpdateRecordsToolbarButton(action: getTipsReviews)
            }
        }
    }
}
