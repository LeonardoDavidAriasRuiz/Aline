//
//  PDFPayrollView.swift
//  Aline
//
//  Created by Leonardo on 14/10/23.
//

import SwiftUI
import PDFKit

struct PDFPayrollView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var worksheetSettings: WorksheetSettings = WorksheetSettings()
    @State private var worksheetRecords: [WorksheetRecord] = []
    @State private var worksheet: Worksheet = Worksheet()
    @State private var recordSelected: WorksheetRecord?
    @State private var payDatePickerShowing: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isLoading: Bool = false
    @State private var workSheetSettingsFetched: Bool = false
    
    var body: some View {
        VStack {
            if workSheetSettingsFetched {
                ScrollView(.horizontal) {
                    VStack {
                        Text(worksheetSettings.worksheetTitle).bold().font(.largeTitle).foregroundStyle(Color.green).multilineTextAlignment(.center)
                        Text("PAYROLL WORKSHEET").bold().font(.title).foregroundStyle(Color.blue)
                        HStack {
                            Image(uiImage: worksheetSettings.logo).resizable().scaledToFill().frame(width: 150, height: 150).clipShape(Circle())
                            Spacer()
                            VStack {
                                Text("Pay date:").bold().foregroundStyle(Color.orange)
                                Toggle(worksheet.payDate.shortDateEn, isOn: $payDatePickerShowing).toggleStyle(.button).tint(.white).foregroundStyle(Color.black)
                                    .sheet(isPresented: $payDatePickerShowing) {
                                        PayDatePicker(payDate: $worksheet.payDate)
                                    }
                                    .onChange(of: worksheet.payDate, changeDates)
                                    .onAppear(perform: changeDates)
                                Text("")
                                Text("Starting Check # Direct Deposit").bold().foregroundStyle(.gray)
                                HStack {
                                    Text("From:").bold().foregroundStyle(Color.blue)
                                    Text(startDate.shortDateEn).foregroundStyle(Color.black)
                                }
                                HStack {
                                    Text("To:").bold().foregroundStyle(Color.blue)
                                    Text(endDate.shortDateEn).foregroundStyle(Color.black)
                                }
                            }
                        }
                        HStack {
                            Text(worksheetSettings.companyName).bold().font(.title2).foregroundStyle(Color.red)
                            Spacer()
                        }
                        HStack {
                            Text(worksheetSettings.numberStreetSte).foregroundStyle(Color.orange)
                            Spacer()
                        }
                        HStack {
                            Text(worksheetSettings.cityStatePC).foregroundStyle(Color.orange).padding(.bottom, 70)
                            Spacer()
                        }
                        
                        HStack {
                            Text("NAME").frame(width: 180)
                            Text("SALARY").frame(maxWidth: .infinity)
                            Text("RATE").frame(maxWidth: .infinity)
                            Text("HOURS").frame(maxWidth: .infinity)
                            Text("OVER TIME").frame(maxWidth: .infinity)
                            Text("SICK TIME").frame(maxWidth: .infinity)
                            Text("CASH TIPS").frame(maxWidth: .infinity)
                            Text("CARGED TIPS").frame(maxWidth: .infinity)
                            Text("GARNIHSMENT").frame(maxWidth: .infinity)
                        }.bold().foregroundStyle(Color.red)
                        
                        ForEach(worksheetRecords.indices, id: \.self) { index in
                            Divider()
                            HStack {
                                Button(action: {selectRecord(worksheetRecords[index])}) {
                                    Text(employeeVM.employees.first(where: {$0.id == worksheetRecords[index].employeeId})?.fullName ?? "Error")
                                        .frame(width: 180, alignment: .leading).foregroundStyle(Color.black)
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Text("\(worksheetRecords[index].salary ? "\(worksheetRecords[index].quantity.comasTextWithDecimals)" : "0.00")")
                                    .foregroundStyle(worksheetRecords[index].salary ? Color.black : Color.black.opacity(0.2))
                                    .frame(maxWidth: .infinity)
                                Text("\(worksheetRecords[index].salary ? "0.00" : "\(worksheetRecords[index].quantity.comasTextWithDecimals)")")
                                    .foregroundStyle(worksheetRecords[index].salary ? Color.black.opacity(0.2) : Color.black)
                                    .frame(maxWidth: .infinity)
                                HourPicker(hours: $worksheetRecords[index].hours) {
                                    Text("\(worksheetRecords[index].hours.fullHour)")
                                        .foregroundStyle(worksheetRecords[index].hours.double == 0 ? Color.black.opacity(0.2) : Color.black)
                                        .frame(maxWidth: .infinity)
                                }
                                HourPicker(hours: $worksheetRecords[index].overTime) {
                                    Text("\(worksheetRecords[index].overTime.fullHour)")
                                        .foregroundStyle(worksheetRecords[index].overTime.double == 0 ? Color.black.opacity(0.2) : Color.black)
                                        .frame(maxWidth: .infinity)
                                }
                                HourPicker(hours: $worksheetRecords[index].sickTime) {
                                    Text("\(worksheetRecords[index].sickTime.fullHour)")
                                        .foregroundStyle(worksheetRecords[index].sickTime.double == 0 ? Color.black.opacity(0.2) : Color.black)
                                        .frame(maxWidth: .infinity)
                                }
                                DecimalField("0.00", decimal: $worksheetRecords[index].cashTips).foregroundStyle(Color.black)
                                DecimalField("0.00", decimal: $worksheetRecords[index].cargedTips).foregroundStyle(Color.black)
                                DecimalField("0.00", decimal: $worksheetRecords[index].garnishment).foregroundStyle(Color.black)
                                if recordSelected == worksheetRecords[index] {
                                    Button(action: {removeRecord(index)}) {
                                        Image(systemName: "trash.circle.fill").font(.title).foregroundStyle(Color.red)
                                    }
                                }
                            }.padding(.vertical, 8)
                        }
                        HStack {
                            Text("Notes:").bold().foregroundStyle(Color.red)
                            Spacer()
                        }.padding(.top, 40)
                        TextEditor(text: $worksheet.notes)
                    }
                    .padding(50)
                    .frame(width: 1275, height: 1650)
                    .background(.white)
                }
                .shadow(radius: 10)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        saveToolBarButton
                    }
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button(action: {dismiss()}) { Text("Cancelar").foregroundStyle(Color.red) }
                    }
                }
            } else {
                EmptyWorkSheetSettingsView().padding(.top, 200)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button(action: {dismiss()}) { Text("Cancelar").foregroundStyle(Color.red) }
                        }
                    }
            }
        }
        .onAppear(perform: getEmployees)
        .onAppear(perform: getSettings)
        .onChange(of: restaurantM.currentId, {dismiss()})
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.light)
    }
    
    private func save() {
        withAnimation {
            exportPDF {
                self.environmentObject(employeeVM).environmentObject(restaurantM)
            } completion: { status, url in
                if let url =  url {
                    worksheet.pdf = PDFDocument(url: url)
                    worksheet.restaurantId = restaurantM.currentId
                    WorksheetViewModel().save(worksheet.record) {
                        dismiss()
                    } ifNot: {
                        alertVM.show(.crearingError)
                    }
                }
            }
        }
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfSpendingReadyToSave() {
                Button(action: save) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    if worksheetSettings.worksheetTitle.isEmpty {
                        Text("Escribe un título.")
                    }
                    if worksheetSettings.companyName.isEmpty {
                        Text("Escribe el nombre de la empresa..")
                    }
                    if worksheetSettings.numberStreetSte.isEmpty || worksheetSettings.cityStatePC.isEmpty {
                        Text("Escribe una dirección.")
                    }
                }
            }
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return worksheetSettings.worksheetTitle.isNotEmpty &&
        worksheetSettings.companyName.isNotEmpty &&
        worksheetSettings.numberStreetSte.isNotEmpty &&
        worksheetSettings.cityStatePC.isNotEmpty
    }
    
    private func selectRecord(_ record: WorksheetRecord) {
        withAnimation {
            recordSelected = record == recordSelected ? nil : record
        }
    }
    
    private func removeRecord(_ index: Int) {
        worksheetRecords.remove(at: index)
    }
    
    private func getEmployees() {
        self.worksheetRecords = employeeVM.employees.compactMap { employee in
            employee.isActive ? employee : nil
        }.map { employee in
            WorksheetRecord(employee: employee)
        }
    }
    
    private func changeDates() {
        let calendar = Calendar.current
        if worksheet.payDate.dayInt == 5 {
            if let lastMonth = calendar.date(byAdding: .day, value: -7, to: worksheet.payDate) {
                startDate = lastMonth.firstDayOfFortnight
                endDate = lastMonth.lastDayOfFortnight
            }
        } else {
            startDate = worksheet.payDate.firstDayOfMonth
            endDate = startDate.lastDayOfFortnight
        }
    }
    
    private func getSettings() {
        isLoading = true
        WorksheetSettingsViewModel().fetch(for: restaurantM.currentId) { worksheets in
            if let worksheets = worksheets {
                if let worksheet = worksheets.first {
                    worksheetSettings = worksheet
                    workSheetSettingsFetched = true
                }
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
}

