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
    
    let tipVM = TipViewModel()
    let tipReviewVM = TipsReviewViewModel()
    
    private var firstFortnightDates: [Date] {
        return (1...15).compactMap { day in
            let dateComponents = DateComponents(year: date.yearInt, month: date.monthInt, day: day)
            return Calendar.current.date(from: dateComponents)
        }
    }
    
    private var secondFortnightDates: [Date] {
        return (16...date.lastDayOfMonth.dayInt).compactMap { day in
            let dateComponents = DateComponents(year: date.yearInt, month: date.monthInt, day: day)
            return Calendar.current.date(from: dateComponents)
        }
    }
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            if employeeVM.employees.isNotEmpty {
                tipsReviews.isNotEmpty ? tipsReviewsList : nil
                firstFortnightTips
                secondFortnightTips.padding(.top, 100)
            }
        }
        .toolbar(content: toolbarItems)
        .overlay { if employeeVM.employees.isEmpty && !isLoading { EmptyTipsView() } }
        .navigationTitle("Tips - " + date.monthAndYear)
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
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
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
