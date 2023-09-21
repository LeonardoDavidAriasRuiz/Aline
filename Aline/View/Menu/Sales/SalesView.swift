//
//  SalesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import Charts

struct SalesView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var alertVM: AlertViewModel
    
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
    @State private var salesTableShowed: Bool = false
    
    @State private var documentPickerShowed: Bool = false
    @State private var data: String?
    @State private var importedSales: [Sale]?
    @State private var errorsInImportedSales: Int?
    
    let invalidDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    let invalidQuantity: Double = -10.0
    
    var body: some View {
        FullSheet(section: .sales) {
            filters
            SalesChart(
                title: "\(customFrom.short) - \(customTo.short)",
                data: $sales,
                totalBy: $totalBy
            )
            SalesTable(sales: $sales.animation(), totalBy: totalBy)
            NavigationLink(destination: SalesCashOutView()) {
                WhiteArea {
                    HStack {
                        Text("Corte")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            importDataArea
            
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
                            .onChange(of: customFrom, validateCustomFrom)
                        Spacer()
                        DatePicker("A", selection: $customTo, displayedComponents: .date)
                            .frame(maxWidth: 200)
                            .onChange(of: customTo, validateCustomTo)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var importDataArea: some View {
        WhiteArea {
            Button(action: {documentPickerShowed.toggle()}) {
                Spacer()
                Text("Importar ventas")
                Spacer()
            }
            .sheet(isPresented: $documentPickerShowed) {
                DocumentPicker(data: $data)
            }
            .onChange(of: data, getSalesFromData)
            if let importedSales = importedSales,
               importedSales.isNotEmpty {
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        VStack {
                            Text("Fecha:")
                            Divider()
                            Text("Rtonos:")
                            Divider()
                            Text("V.equipo:")
                            Divider()
                            Text("Tarjetas:")
                            Divider()
                        }
                        VStack {
                            Text("Depo:")
                            Divider()
                            Text("Door Dash:").foregroundStyle(Color.red)
                            Divider()
                            Text("Online:").foregroundStyle(Color.green)
                            Divider()
                            Text("GrubHub:").foregroundStyle(Color.orange)
                            Divider()
                            Text("TacoBar:").foregroundStyle(Color.blue)
                        }
                    }.bold().frame(width: 100)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(importedSales) { sale in
                                Divider()
                                VStack(alignment: .leading) {
                                    VStack {
                                        Text(sale.date.short).foregroundStyle(!validateDate(sale.date) ? .red : .black).bold()
                                        Divider()
                                        Text(sale.rtonos.comasText).foregroundStyle(!validateQuantity(sale.rtonos) ? .red : .secondary)
                                        Divider()
                                        Text(sale.vequipo.comasText).foregroundStyle(!validateQuantity(sale.vequipo) ? .red : .secondary)
                                        Divider()
                                        Text(sale.carmenTRJTA.comasText).foregroundStyle(!validateQuantity(sale.carmenTRJTA) ? .red : .secondary)
                                        Divider()
                                    }
                                    VStack {
                                        Text(sale.depo.comasText).foregroundStyle(!validateQuantity(sale.depo) ? .red : .secondary)
                                        Divider()
                                        Text(sale.doordash.comasText).foregroundStyle(!validateQuantity(sale.doordash) ? .red : .secondary)
                                        Divider()
                                        Text(sale.online.comasText).foregroundStyle(!validateQuantity(sale.online) ? .red : .secondary)
                                        Divider()
                                        Text(sale.grubhub.comasText).foregroundStyle(!validateQuantity(sale.grubhub) ? .red : .secondary)
                                        Divider()
                                        Text(sale.tacobar.comasText).foregroundStyle(!validateQuantity(sale.tacobar) ? .red : .secondary)
                                    }
                                }
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
                Divider()
                if let errorsInImportedSales = errorsInImportedSales,
                   errorsInImportedSales > 0 {
                    Text("Hay \(errorsInImportedSales) errores en los datos.").foregroundStyle(.red).bold()
                } else {
                    SaveButton(action: saveAllImportedSales)
                }
            }
        }
    }
    
    private func saveAllImportedSales() {
        guard let importedSales = importedSales else { return }
        for sale in importedSales {
            SaleViewModel().save(sale) { sale in
                if let sale = sale {
                    withAnimation {
                        sales.append(sale)
                        sales.sort(by: { $0.date < $1.date })
                    }
                    self.importedSales?.removeAll(where: {$0.date == sale.date})
                }
            }
        }
    }
    
    private func getSalesFromData() {
        errorsInImportedSales = 0
        guard let data = data else { return }
        var sales: [Sale] = []
        let lines = data.split(separator: "\r\n")
        for line in lines.dropFirst() {
            let fields = line.split(separator: ",")
            if fields.count >= 9 {
                let sale = Sale(
                    date: (Int(fields[9]) ?? 0).convertExcelDateToSwiftDate ?? invalidDate,
                    restaurantId: restaurantM.currentId,
                    rtonos: Double(fields[0]) ?? invalidQuantity,
                    vequipo: Double(fields[1]) ?? invalidQuantity,
                    carmenTRJTA: Double(fields[2]) ?? invalidQuantity,
                    depo: Double(fields[3]) ?? invalidQuantity,
                    dscan: Double(fields[4]) ?? invalidQuantity,
                    doordash: Double(fields[5]) ?? invalidQuantity,
                    online: Double(fields[6]) ?? invalidQuantity,
                    grubhub: Double(fields[7]) ?? invalidQuantity,
                    tacobar: Double(fields[8]) ?? invalidQuantity
                )
                sales.append(sale)
            }
        }
        importedSales = sales
        errorsInImportedSales = 0
        for sale in sales {
            errorsInImportedSales! += (validateDate(sale.date) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.carmenTRJTA) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.depo) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.doordash) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.online) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.grubhub) ? 0 : 1)
            errorsInImportedSales! += (validateQuantity(sale.tacobar) ? 0 : 1)
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
    
    private func validateCustomFrom(_ oldValue: Date, _ newValue: Date) {
        if newValue > customTo {
            customTo = newValue
        }
        validateRangeIn()
    }
    
    private func validateCustomTo(_ oldValue: Date, _ newValue: Date) {
        if newValue < customFrom {
            customFrom = newValue
        }
        validateRangeIn()
    }
    
    private func selectTotalByDay() {
        withAnimation {
            getSales(from: customFrom, to: customTo)
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
            getSales(from: customFrom, to: customTo)
            if rangeIn == .currentWeek {
                rangeIn = .currentMonth
            }
            totalBy = .week
            totalByChart = .weekOfYear
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = true
            rangeInCurrentYearAviable = true
            componentBy = .dateTime.day(.twoDigits)
            sales = sales.groupByWeek
        }
    }
    
    private func selectTotalByMonth() {
        withAnimation {
            getSales(from: customFrom, to: customTo)
            if rangeIn == .currentWeek ||
                rangeIn == .currentMonth {
                rangeIn = .currentYear
            }
            totalBy = .month
            totalByChart = .month
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = false
            rangeInCurrentYearAviable = true
            componentBy = .dateTime.month(.wide)
            sales = sales.groupByMonth
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
                    firstDay = customFrom
                    lastDay = customTo
                    customRangeSelected = true
            }
            
            if let startDate = firstDay, let endDate = lastDay {
                customFrom = startDate
                customTo = endDate
                getSales(from: startDate, to: endDate)
            }
        }
    }
    
    private func getSales(from: Date, to: Date) {
        withAnimation {
            loading.isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                SaleViewModel().fetchSales(for: restaurantId, from: from, to: to) { sales in
                    if let sales = sales {
                        switch totalBy {
                            case .day: self.sales = sales.sorted(by: { $0.date < $1.date })
                            case .week: self.sales = sales.groupByWeek.sorted(by: { $0.date < $1.date })
                            case .month: self.sales = sales.groupByMonth.sorted(by: { $0.date < $1.date })
                        }
//                        SaleViewModel().delete(self.sales)
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    loading.isLoading = false
                }
            }
        }
    }
    
    private func onApper() {
        accentColor.green()
        selectTotalByDay()
        selectRange(.currentYear)
    }
    
    private func validateQuantity(_ quantity: Double) -> Bool {
        !(quantity < 0)
    }
    
    private func validateDate(_ date: Date) -> Bool {
        !(date <= invalidDate)
    }
}
