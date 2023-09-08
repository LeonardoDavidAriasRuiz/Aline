//
//  SalesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import Charts

struct SalesView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .crearingError
    
    @State private var filtersShowed: Bool = false
    
    @State private var totalBy: TotalBy = .day
    @State private var rangeIn: RangeIn = .currentMonth
    @State private var totalByChart: Calendar.Component = .day
    @State private var componentBy: Date.FormatStyle = .dateTime.day()
    
    @State private var rangeInCurrentWeekAviable: Bool = true
    @State private var rangeInCurrentMonthAviable: Bool = true
    @State private var rangeInCurrentYearAviable: Bool = true
    @State private var customRangeSelected: Bool = false
    
    @State private var customFrom: Date = Date()
    @State private var customTo: Date = Date()
    
    @State private var sales: [Sale] = []
    
    @State private var showedQuantities: Bool = true
    
    var body: some View {
            FullSheet(section: .sales) {
                filters
                WhiteArea {
                    HStack {
                        Text(formatDateRange()).font(.largeTitle).bold()
                        Spacer()
                    }
                    Chart(sales) { sale in
                        if totalByChart == .day {
                            RuleMark(y: .value("", 4000))
                                .foregroundStyle(Color.orange)
                                .annotation(alignment: .leading) {
                                    Text("$4,000")
                                        .font(.caption)
                                        .foregroundColor(Color.orange)
                                }
                        }
                        
                        BarMark(
                            x: .value("Día", sale.date, unit: totalByChart),
                            y: .value("Venta", sale.rtonos)
                        )
                        .foregroundStyle(Color.green.opacity(Double(sale.rtonos) / (sales.max(by: {$0.rtonos < $1.rtonos})?.rtonos ?? 1.0)))
                        .cornerRadius(20)
                        .annotation(position: .top) {
                            if showedQuantities {
                                Text(sale.rtonos.comasText).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(height: 400)
                    .chartYAxis(showedQuantities ? .hidden : .visible)
                    .chartXAxis {
                        AxisMarks(values: sales.map{$0.date}) { date in
                            let day = Calendar.current.component(.day, from: date.as(Date.self) ?? Date())
                            let monthAbbreviation = getMonthAbbreviation(from: date.as(Date.self) ?? Date())
                            AxisValueLabel("\(day)\n\(monthAbbreviation)")
                        }
                    }
                }
            }
        .onAppear(perform: onApper)
    }
    
    private var filters: some View {
        WhiteArea {
            OpenSectionButton(pressed: $filtersShowed, text: "Filtros")
            if filtersShowed {
                Divider()
                HStack {
                    Text("Total por")
                    Picker("Total por", selection: $totalBy) {
                        Text("Día").tag(TotalBy.day)
                        Text("Semana").tag(TotalBy.week)
                        Text("Mes").tag(TotalBy.month)
                    }
                    .pickerStyle(.palette)
                    .onChange(of: totalBy, validationTotalBy)
                }
                HStack {
                    Text("En")
                    Picker("En", selection: $rangeIn) {
                        rangeInCurrentWeekAviable ? Text("Semana actual").tag(RangeIn.currentWeek) : nil
                        rangeInCurrentMonthAviable ? Text("Mes actual").tag(RangeIn.currentMonth) : nil
                        rangeInCurrentYearAviable ? Text("Año actual").tag(RangeIn.currentYear) : nil
                        Text("Personalizado").tag(RangeIn.customRange)
                    }
                    .pickerStyle(.palette)
                    .onChange(of: rangeIn, validateRangeIn)
                }
                if customRangeSelected {
                    HStack {
                        Spacer()
                        DatePicker("Del", selection: $customFrom, displayedComponents: .date)
                            .frame(maxWidth: 200)
                            .onChange(of: customFrom, validateCustomRangeIn)
                        Spacer()
                        DatePicker("A", selection: $customTo, displayedComponents: .date)
                            .frame(maxWidth: 200)
                            .onChange(of: customTo, validateCustomRangeIn)
                        Spacer()
                    }
                }
                Divider()
                Toggle("Mostrar cantidades", isOn: $showedQuantities.animation())
            }
        }
    }
    
    private func validationTotalBy() {
        switch totalBy {
            case .day: selectTotalByDay()
            case .week: selectTotalByWeek()
            case .month: selectTotalByMonth()
        }
    }
    
    private func validateRangeIn() {
        switch rangeIn {
            case .currentWeek: selectRange(.currentWeek)
            case .currentMonth: selectRange(.currentMonth)
            case .currentYear: selectRange(.currentYear)
            case .customRange: selectRange(.customRange)
        }
    }
    
    private func validateCustomRangeIn(_ oldValue: Date, _ newValue: Date) {
        if let days = Calendar.current.dateComponents([.day], from: customFrom, to: customTo).day{
            switch days {
                case 1...31: totalBy = .day
                case 32...70: totalBy = .week
                case 71...: totalBy = .month
                default: totalBy = .day
            }
            validateRangeIn()
        }
        if newValue < customFrom {
            customFrom = customTo
        }
    }
    
    private func selectTotalByDay() {
        withAnimation {
            totalBy = .day
            totalByChart = .day
            rangeInCurrentWeekAviable = true
            rangeInCurrentMonthAviable = true
            rangeInCurrentYearAviable = true
            componentBy = .dateTime.day()
        }
    }
    
    private func selectTotalByWeek() {
        withAnimation {
            if rangeIn == .currentWeek {
                rangeIn = .currentMonth
            }
            totalBy = .week
            totalByChart = .weekOfYear
            groupByWeek()
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = true
            rangeInCurrentYearAviable = true
            componentBy = .dateTime.day(.twoDigits)
        }
    }
    
    private func selectTotalByMonth() {
        withAnimation {
            if rangeIn == .currentWeek ||
                rangeIn == .currentMonth {
                rangeIn = .currentYear
            }
            totalBy = .month
            totalByChart = .month
            groupByMonth()
            totalByChart = .month
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = false
            rangeInCurrentYearAviable = true
            componentBy = .dateTime.month(.wide)
        }
    }
    
    private func selectRange(_ rangeIn: RangeIn) {
        withAnimation {
            customRangeSelected = false
            let calendar = Calendar.current
            var firstDay: Date?
            var lastDay: Date?
            
            switch rangeIn {
                case .currentWeek:
                    firstDay = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
                    lastDay = calendar.date(byAdding: .day, value: 6, to: firstDay!)
                case .currentMonth:
                    firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))
                    lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay!)
                case .currentYear:
                    firstDay = calendar.date(from: calendar.dateComponents([.year], from: Date()))
                    lastDay = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: firstDay!)
                case .customRange:
                    customRangeSelected = true
                    getSales(from: customFrom, to: customTo)
            }
            
            if let startDate = firstDay, let endDate = lastDay {
                customFrom = startDate
                customTo = endDate
                getSales(from: startDate, to: endDate)
            }
        }
        validationTotalBy()
    }
    
    private func getSales(from: Date, to: Date) {
        withAnimation {
            loading.isLoading = true
            SaleViewModel().fetchSales(for: restaurantVM.currentRestaurantId, from: from, to: to) { sales in
                if let sales = sales {
                    self.sales = sales
                } else {
                    alertType = .dataObtainingError
                    alertShowed = true
                }
                loading.isLoading = false
            }
        }
    }
    
    private func onApper() {
        accentColor.green()
        selectTotalByDay()
        selectRange(.currentMonth)
    }
    
    func groupByWeek() {
        sales = groupBy { sale in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sale.date)
            return "\(components.yearForWeekOfYear!)-\(components.weekOfYear!)"
        }.sorted(by: {$0.date > $1.date})
    }
    
    func groupByMonth() {
        sales = groupBy { sale in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: sale.date)
            return "\(components.year!)-\(components.month!)"
        }.sorted(by: {$0.date > $1.date})
    }
    
    private func groupBy(keySelector: (Sale) -> String) -> [Sale] {
        var grouped: [String: Sale] = [:]
        
        for sale in sales {
            let key = keySelector(sale)
            
            if var existingSale = grouped[key] {
                existingSale.carmenTRJTA += sale.carmenTRJTA
                existingSale.depo += sale.depo
                existingSale.dscan += sale.dscan
                existingSale.doordash += sale.doordash
                existingSale.online += sale.online
                existingSale.grubhub += sale.grubhub
                existingSale.tacobar += sale.tacobar
                grouped[key] = existingSale
            } else {
                grouped[key] = sale
            }
        }
        
        return Array(grouped.values)
    }
    
    private func getMonthAbbreviation(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        return dateFormatter.string(from: date)
    }
    
    private func formatDateRange() -> String {
        switch rangeIn {
            case .currentWeek: return "\(customFrom.short) - \(customTo.short)"
            case .currentMonth: return customFrom.monthYear
            case .currentYear: return customFrom.year
            case .customRange: return "\(customFrom.short) - \(customTo.short)"
        }
    }
}

enum TotalBy: String {
    case day = "Día"
    case week = "Semana"
    case month = "Mes"
}

enum RangeIn: String {
    case currentWeek = "Semana actual"
    case currentMonth = "Mes actual"
    case currentYear = "Año actual"
    case customRange = "Personalizado"
}
