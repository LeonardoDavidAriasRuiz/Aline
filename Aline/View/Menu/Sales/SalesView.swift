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
    
    @State private var totalBy: TotalBy = .day
    @State private var rangeIn: RangeIn = .currentMonth
    
    @State private var rangeInCurrentWeekAviable: Bool = true
    @State private var rangeInCurrentMonthAviable: Bool = true
    @State private var rangeInCurrentYearAviable: Bool = true
    @State private var customRangeSelected: Bool = false
    
    @State private var customFrom: Date = Date()
    @State private var customTo: Date = Date()
    
    @State private var sales: [Sale] = []
    
    @State private var data: String?
    @State private var importedSales: [Sale]?
    @State private var errorsInImportedSales: Int?
    
    @State private var showedQuantities: Bool = false
    @State private var showedDaysByWeekDay: Bool = false
    
    @State private var objective: Double = 4000
    @State private var objectiveShowed: Bool = false
    
    @State private var salesType: SalesType = .rtonos
    
    @State private var mondayShowed: Bool = true
    @State private var tuesdayShowed: Bool = true
    @State private var wednesdayShowed: Bool = true
    @State private var thursdayShowed: Bool = true
    @State private var fridayShowed: Bool = true
    @State private var saturdayShowed: Bool = true
    @State private var sundayShowed: Bool = true
    @State private var isLoading: Bool = true
    
    let invalidDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    let invalidQuantity: Double = -10.0
    
    private let saleVM = SaleViewModel()
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            SalesChart(
                title: "\(customFrom.shortDate) - \(customTo.shortDate)",
                sales: $sales,
                totalBy: $totalBy,
                showedQuantities: $showedQuantities,
                showedDaysByWeekDay: $showedDaysByWeekDay, 
                colorLimit: $objective,
                salesType: $salesType,
                mondayShowed: $mondayShowed,
                tuesdayShowed: $tuesdayShowed,
                wednesdayShowed: $wednesdayShowed,
                thursdayShowed: $thursdayShowed,
                fridayShowed: $fridayShowed,
                saturdayShowed: $saturdayShowed,
                sundayShowed: $sundayShowed
            )
            SalesTable(sales: $sales.animation(), totalBy: totalBy)
            importDataArea
            
        }
        .background(AlertWithTextField(isPresented: $objectiveShowed, text: $objective.animation(), title: "Establece el objetivo"))
        .onChange(of: restaurantM.currentId, getSales)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: SalesCashOutView())
                UpdateRecordsToolbarButton(action: getSales)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                customRangeSelected ? DatePicker("", selection: $customFrom, displayedComponents: .date).onChange(of: customFrom, validateCustomFrom) : nil
                customRangeSelected ? DatePicker("", selection: $customTo, displayedComponents: .date).onChange(of: customTo, validateCustomTo) : nil
                ExportCSVToolbarButton(data: createCSV()).disabled(sales.isEmpty)
                ImportToolbarButton { self.data = $0 }.onChange(of: data, getSalesFromData)
                FiltersToolbarMenu(fill: rangeIn != .currentMonth || totalBy != .day || showedQuantities != false || showedDaysByWeekDay != false) {
                    Toggle(isOn: $objectiveShowed, label: {
                        Label("Objetivo", systemImage: "chart.line.flattrend.xyaxis")
                    })
                    Menu {
                        Button("Ninguno") {
                            withAnimation {
                                mondayShowed = false
                                tuesdayShowed = false
                                wednesdayShowed = false
                                thursdayShowed = false
                                fridayShowed = false
                                saturdayShowed = false
                                sundayShowed = false
                            }
                        }
                        Toggle(WeekDays.monday.rawValue, isOn: $mondayShowed.animation())
                        Toggle(WeekDays.tuesday.rawValue, isOn: $tuesdayShowed.animation())
                        Toggle(WeekDays.wednesday.rawValue, isOn: $wednesdayShowed.animation())
                        Toggle(WeekDays.thursday.rawValue, isOn: $thursdayShowed.animation())
                        Toggle(WeekDays.friday.rawValue, isOn: $fridayShowed.animation())
                        Toggle(WeekDays.saturday.rawValue, isOn: $saturdayShowed.animation())
                        Toggle(WeekDays.sunday.rawValue, isOn: $sundayShowed.animation())
                        Button("Todos") {
                            withAnimation {
                                mondayShowed = true
                                tuesdayShowed = true
                                wednesdayShowed = true
                                thursdayShowed = true
                                fridayShowed = true
                                saturdayShowed = true
                                sundayShowed = true
                            }
                        }
                    } label: {
                        Label("Mostrar", systemImage: "calendar.day.timeline.left")
                    }.menuStyle(.borderlessButton)

                    Picker(selection: $salesType.animation()) {
                        Text(SalesType.rtonos.rawValue).tag(SalesType.rtonos)
                        Text(SalesType.vequipo.rawValue).tag(SalesType.vequipo)
                        Text(SalesType.carmenTRJTA.rawValue).tag(SalesType.carmenTRJTA)
                        Text(SalesType.depo.rawValue).tag(SalesType.depo)
                        Text(SalesType.dscan.rawValue).tag(SalesType.dscan)
                        Text(SalesType.doordash.rawValue).tag(SalesType.doordash)
                        Text(SalesType.online.rawValue).tag(SalesType.online)
                        Text(SalesType.grubhub.rawValue).tag(SalesType.grubhub)
                        Text(SalesType.tacobar.rawValue).tag(SalesType.tacobar)
                    } label: {
                        Label("Tipo", systemImage: "list.triangle")
                    }
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
        .overlay { if sales.isEmpty, !isLoading, importedSales == nil { EmptySalesView() } }
        .onAppear(perform: onAppear)
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
                }.frame(maxWidth: .infinity).padding(.top, 8)
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
            objective = 4000
            mondayShowed = true
            tuesdayShowed = true
            wednesdayShowed = true
            thursdayShowed = true
            fridayShowed = true
            saturdayShowed = true
            sundayShowed = true
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
            rangeInCurrentWeekAviable = true
            rangeInCurrentMonthAviable = true
            rangeInCurrentYearAviable = true
        }
    }
    
    private func selectTotalByWeek() {
        withAnimation {
            getSales()
            if rangeIn == .currentWeek {
                rangeIn = .currentMonth
            }
            totalBy = .week
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = true
            rangeInCurrentYearAviable = true
            sales = sales.groupByWeek
        }
    }
    
    private func selectTotalByMonth() {
        withAnimation {
            getSales()
            if rangeIn == .currentWeek || rangeIn == .currentMonth {
                rangeIn = .currentYear
            }
            totalBy = .month
            rangeInCurrentWeekAviable = false
            rangeInCurrentMonthAviable = false
            rangeInCurrentYearAviable = true
            sales = sales.groupByMonth
        }
    }
    
    private func selectRange(_ rangeIn: RangeIn) {
        withAnimation {
            customRangeSelected = false
            
            switch rangeIn {
                case .currentWeek:
                    customFrom = Date().firstDayOfWeek
                    customTo = Date().lastDayOfWeek
                case .currentMonth:
                    customFrom = Date().firstDayOfMonth
                    customTo = Date().lastDayOfMonth
                case .currentYear:
                    customFrom = Date().firstDayOfYear
                    customTo = Date().lastDayOfYear
                case .customRange:
                    customRangeSelected = true
            }
            getSales()
        }
    }
    
    private func getSales() {
        withAnimation {
            isLoading = true
            saleVM.fetchSales(for: restaurantM.currentId, from: customFrom, to: customTo) { sales in
                if let sales = sales {
                    switch totalBy {
                        case .day: self.sales = sales.sorted(by: { $0.date < $1.date })
                        case .week: self.sales = sales.groupByWeek.sorted(by: { $0.date < $1.date })
                        case .month: self.sales = sales.groupByMonth.sorted(by: { $0.date < $1.date })
                    }//SaleViewModel().delete(self.sales)
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    private func onAppear() {
        selectTotalByDay()
        selectRange(.currentMonth)
    }
    
    private func validateQuantity(_ quantity: Double) -> Bool {
        return quantity >= 0
    }
    
    private func validateDate(_ date: Date) -> Bool {
        return date > invalidDate
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

struct AlertWithTextField: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var text: Double
    let title: String
    @State private var message: String = "Escribe correctamente el objetivo."
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWithTextField>) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AlertWithTextField>) {
        if isPresented {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Objetivo mínimo"
                textField.text = String(Int(self.text))
            }
            
            let okAction = UIAlertAction(title: "Aplicar", style: .default) { _ in
                if let textField = alert.textFields?.first,
                   let text = textField.text,
                   let double = Double(text) {
                    self.text = double
                }
                self.isPresented = false
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                self.isPresented = false
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}

enum SalesType: String {
    case rtonos = "Rtonos"
    case vequipo = "Vequipo"
    case carmenTRJTA = "CarmenTRJTA"
    case depo = "Depo"
    case dscan = "Dscan"
    case doordash = "Doordash"
    case online = "Online"
    case grubhub = "Grubhub"
    case tacobar = "Tacobar"
}

enum WeekDays: String {
    case monday = "Lunes"
    case tuesday = "Martes"
    case wednesday = "Miércoles"
    case thursday = "Jueves"
    case friday = "Viernes"
    case saturday = "Sábado"
    case sunday = "Domingo"
}

