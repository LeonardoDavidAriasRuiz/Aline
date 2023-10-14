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
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
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
    
    @State private var data: String?
    @State private var importedSales: [Sale]?
    @State private var errorsInImportedSales: Int?
    @State private var fileSelector: Bool = false
    
    @State private var showedQuantities: Bool = false
    @State private var showedDaysByWeekDay: Bool = false
    
    let invalidDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    let invalidQuantity: Double = -10.0
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            SalesChart(
                title: "\(customFrom.shortDate) - \(customTo.shortDate)",
                data: $sales,
                totalBy: $totalBy,
                showedQuantities: $showedQuantities,
                showedDaysByWeekDay: $showedDaysByWeekDay
            )
            SalesTable(sales: $sales.animation(), totalBy: totalBy)
            importDataArea
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: SalesCashOutView())
                UpdateRecordsToolbarButton(action: getSales)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if customRangeSelected {
                    DatePicker("", selection: $customFrom, displayedComponents: .date)
                        .onChange(of: customFrom, validateCustomFrom)
                    DatePicker("", selection: $customTo, displayedComponents: .date)
                        .onChange(of: customTo, validateCustomTo)
                }
                ExportToolbarButton(data: createCSV()).disabled(sales.isEmpty)
                ImportToolbarButton { self.data = $0 }.onChange(of: data, getSalesFromData)
                FiltersToolBarMenu(fill: rangeIn != .currentMonth || totalBy != .day || showedQuantities != false || showedDaysByWeekDay != false) {
                    Picker(selection: $totalBy) {
                        Text("Día").tag(TotalBy.day)
                        Text("Semana").tag(TotalBy.week)
                        Text("Mes").tag(TotalBy.month)
                    } label: {
                        Label("Total por", systemImage: "calendar.day.timeline.left")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: totalBy, validationTotalBy)
                    Picker(selection: $rangeIn) {
                        rangeInCurrentWeekAviable ? Text("Semana actual").tag(RangeIn.currentWeek) : nil
                        rangeInCurrentMonthAviable ? Text("Mes actual").tag(RangeIn.currentMonth) : nil
                        rangeInCurrentYearAviable ? Text("Año actual").tag(RangeIn.currentYear) : nil
                        Text("Personalizado").tag(RangeIn.customRange)
                    } label: {
                        Label("En", systemImage: rangeIn == .currentMonth ? "calendar.circle" : "calendar.circle.fill")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: rangeIn, validateRangeIn)
                    Divider()
                    Toggle(isOn: $showedQuantities.animation()) {
                        Label("Mostrar cantidades", systemImage: showedQuantities ?  "dollarsign.circle.fill" : "dollarsign.circle")
                    }
                    if totalBy == .day {
                        Toggle(isOn: $showedDaysByWeekDay.animation()) {
                            Label("Ver por día de semana", systemImage: showedDaysByWeekDay ?  "calendar.circle.fill" : "calendar.circle")
                        }
                    }
                    if !(rangeIn == .currentMonth &&
                        totalBy == .day &&
                        showedQuantities == false &&
                        showedDaysByWeekDay == false) {
                        Divider()
                        Button(role: .destructive, action: clearFilters) {
                            Label("Quitar filtros", systemImage: "xmark")
                        }
                    }
                }
            }
        }
        .overlay {
            if sales.isEmpty, !isLoading, importedSales == nil {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin ventas") },
                        icon: { Image(systemName: "chart.bar.xaxis").foregroundStyle(Color.green) }
                    )
                }, description: {
                    Text("Las nuevas ventas se mostrarán aquí.")
                })
            }
        }
        .onAppear(perform: onApper)
    }
    
    private var importDataArea: some View {
        WhiteArea {
            if let importedSales = importedSales,
               importedSales.isNotEmpty {
                HStack {
                    Text("Datos importados").bold().font(.title).padding(.vertical, 10)
                    Spacer()
                }
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
                                        Text(sale.date.shortDate).foregroundStyle(!validateDate(sale.date) ? .red : .primary).bold()
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
                    .padding(.top, 8)
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
            SaleViewModel().save(sale.record) {
                self.importedSales?.removeAll(where: {$0.date == sale.date})
            } ifNot: {
                alertVM.show(.crearingError)
            } alwaysDo: {
                if let empty = self.importedSales?.isEmpty, empty {
                    self.importedSales = nil
                    self.data = nil
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
    
    private func clearFilters() {
        withAnimation {
            rangeIn = .currentMonth
            totalBy = .day
            showedQuantities = false
            showedDaysByWeekDay = false
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
            getSales()
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
            getSales()
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
            getSales()
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
                getSales()
            }
        }
    }
    
    private func getSales() {
        withAnimation {
            isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                SaleViewModel().fetchSales(for: restaurantId, from: customFrom, to: customTo) { sales in
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
                    isLoading = false
                }
            }
        }
    }
    
    private func onApper() {
        selectTotalByDay()
        selectRange(.currentMonth)
    }
    
    private func validateQuantity(_ quantity: Double) -> Bool {
        !(quantity < 0)
    }
    
    private func validateDate(_ date: Date) -> Bool {
        !(date <= invalidDate)
    }
    
    func createCSV() -> Data? {
        var csvString = "Fecha,CarmenTRJTA,Depo,DScan,DoorDash,Online,GrubHub,TacoBar,VEquipo,RTonos\n"
        for sale in sales {
            let saleString = """
            \(sale.date.shortDate),\(sale.carmenTRJTA),\(sale.depo),\
            \(sale.dscan),\(sale.doordash),\(sale.online),\(sale.grubhub),\(sale.tacobar),\(sale.vequipo),\(sale.rtonos)\n
            """
            csvString.append(saleString)
        }
        return csvString.data(using: .utf8)
    }
}
