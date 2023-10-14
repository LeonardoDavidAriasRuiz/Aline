//
//  NewPayrollView.swift
//  Aline
//
//  Created by Leonardo on 07/10/23.
//

import SwiftUI

struct NewPayrollView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var worksheet: Worksheet = Worksheet()
    @State private var worksheetRecords: [WorksheetRecord] = []
    @State private var index: Int?
    @State private var employees: [Employee] = []
    @State private var pdfData: Data = Data()
    @State private var isLoading: Bool = false
    
    private var startDate: Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 1
        dateComponents.day = 1
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    private var endDate: Date {
        var dateComponents = DateComponents()
        dateComponents.year = Date().yearInt + 1
        dateComponents.month = Date().monthInt + 1
        dateComponents.day = Date().dayInt + 20
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            settings
            employeesList
            notesArea
            NavigationLink("PDF") {
                PDFPayrollView(worksheet: $worksheet, worksheetRecords: $worksheetRecords, employees: $employees)
            }
            
            
            Button {
                
                isLoading = true
                
                exportPDF {
                    PDFPayrollView(worksheet: $worksheet, worksheetRecords: $worksheetRecords, employees: $employees)
                } completion: { status, url in
                    if let url, status {
                        if let data = try? Data(contentsOf: url) {
                            
                            let name = userVM.user.name
                            let email = userVM.user.email
                            let exportSalesEmail = ExportSalesEmail()
                            let subject = exportSalesEmail.subject
                            let body = exportSalesEmail.body()
                            let fileName: String = "Gastos.pdf"
//                                convertHTMLStringToPDFData(htmlString: htmlString) { data in
                                MailSMTP().send(name: name, email: email, subject: subject, body: body, data: data, fileName: fileName) {
                                } ifNot: { } alwaysDo: {
                                    isLoading = false
//                                    }
                            }
                            pdfData = data
                        }
                    } else {
                        print("Failed to produce PDF")
                    }
                }
                
                
            } label: {
                Text("enviar").padding(.vertical, 8)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: discard) {
                    Text("Descartar").foregroundStyle(Color.red)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: save) {
                    Text("Guardar").foregroundStyle(Color.green)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: getEmployees)
    }
    
    private var employeesList: some View {
        WhiteArea {
            ForEach(worksheetRecords, id: \.self) { worksheetRecord in
                Button(action: {selectWorksheetRecord(worksheetRecord)}) {
                    HStack {
                        Text(getEmployee(worksheetRecord)?.fullName ?? "Not found")
                        Spacer()
                        Text((worksheetRecord.hours + worksheetRecord.overTime).fullHour).foregroundStyle(.secondary)
                        Image(systemName: "chevron.down").foregroundStyle(.secondary).font(.footnote)
                    }
                    .padding(.vertical, 8)
                    .foregroundStyle(Color.text)
                }
                if let index = index, self.worksheetRecords[index] == worksheetRecord {
                    VStack(spacing: 0) {
                        HStack {
                            Text(worksheetRecord.salary ? "Salary" : "Rate")
                            Spacer()
                            Text("$\(worksheetRecord.quantity.comasTextWithDecimals)").foregroundStyle(.secondary)
                        }.padding(.vertical, 8)
                        if !worksheetRecord.salary {
                            Divider()
                            hoursPicker
                            Divider()
                            overTimePicker
                            Divider()
                            sickTimePicker
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.background)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.bottom, 8)
                }
                
                if worksheetRecord != worksheetRecords.last {
                    Divider()
                }
            }
        }
    }
    
    private var settings: some View {
        WhiteArea {
            typePicker
            Divider()
            DatePicker("PayDate", selection: $worksheet.payDate, in: startDate...endDate , displayedComponents: .date).datePickerStyle(.graphical)
                .onChange(of: worksheet.payDate) { old, newValue in
                    validate(date: newValue)
                }
        }
    }
    
    private func validate(date: Date) {
        withAnimation {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            
            if day != 5 && day != 20 {
                var newDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                newDateComponents.day = day < 5 ? 5 : 20
                
                if let newDate = calendar.date(from: newDateComponents) {
                    worksheet.payDate = newDate
                }
            }
        }
    }
    
    private var typePicker: some View {
        Menu {
            Picker("Tipo", selection: $worksheet.bonus) {
                Text("Reular").tag(false)
                Text("Bonus").tag(true)
            }.pickerStyle(.inline)
        } label: {
            HStack {
                Text("Tipo")
                Spacer()
                Text(worksheet.bonus ? "Bonus" : "Regular").foregroundStyle(.secondary)
                Image(systemName: "chevron.down").foregroundStyle(.secondary).font(.footnote)
            }
            .foregroundStyle(Color.text)
            .padding(.vertical, 8)
        }

    }
    
    private var hoursPicker: some View {
        Menu {
            if let index = index {
                Picker("Horas", selection: $worksheetRecords[index].hours.hours) {
                    ForEach(0..<121) {hour in
                        Text("\(hour)").tag(hour)
                    }
                }.pickerStyle(.menu)
                Picker("Minutos", selection: $worksheetRecords[index].hours.minutes) {
                    Text("00").tag(0)
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("45").tag(45)
                }.pickerStyle(.menu)
            }
        } label: {
            HStack {
                Text("Hours")
                Spacer()
                if let index = index {
                    Text(worksheetRecords[index].hours.fullHour).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.down").foregroundStyle(.secondary).font(.footnote)
            }
            .foregroundStyle(Color.text)
            .padding(.vertical, 8)
        }
    }
    
    private var overTimePicker: some View {
        Menu {
            if let index = index {
                Picker("Horas", selection: $worksheetRecords[index].overTime.hours) {
                    ForEach(0..<121) {hour in
                        Text("\(hour)").tag(hour)
                    }
                }.pickerStyle(.menu)
                Picker("Minutos", selection: $worksheetRecords[index].overTime.minutes) {
                    Text("00").tag(0)
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("45").tag(45)
                }.pickerStyle(.menu)
            }
        } label: {
            HStack {
                Text("Over Time")
                Spacer()
                if let index = index {
                    Text(worksheetRecords[index].overTime.fullHour).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.down").foregroundStyle(.secondary).font(.footnote)
            }
            .foregroundStyle(Color.text)
            .padding(.vertical, 8)
        }
    }
    
    private var sickTimePicker: some View {
        Menu {
            if let index = index {
                Picker("Horas", selection: $worksheetRecords[index].sickTime.hours) {
                    ForEach(0..<121) {hour in
                        Text("\(hour)").tag(hour)
                    }
                }.pickerStyle(.menu)
                Picker("Minutos", selection: $worksheetRecords[index].sickTime.minutes) {
                    Text("00").tag(0)
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("45").tag(45)
                }.pickerStyle(.menu)
            }
        } label: {
            HStack {
                Text("Sick Time")
                Spacer()
                if let index = index {
                    Text(worksheetRecords[index].sickTime.fullHour).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.down").foregroundStyle(.secondary).font(.footnote)
            }
            .foregroundStyle(Color.text)
            .padding(.vertical, 8)
        }
    }
    
    private var notesArea: some View {
        WhiteArea {
            TextField("Notes", text: $worksheet.notes)
                .padding(.vertical, 8)
        }
    }
    
    private func getEmployee(_ worksheetRecord: WorksheetRecord) -> Employee? {
        employees.first { $0.id == worksheetRecord.employeeId }
    }
    
    private func selectWorksheetRecord(_ worksheetRecord: WorksheetRecord) {
        withAnimation {
            let newIndex: Int? = worksheetRecords.firstIndex(of: worksheetRecord)
            self.index = self.index == newIndex ? nil : newIndex
        }
    }
    
    private func save() {
        withAnimation {
            
        }
    }
    
    private func discard() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func getEmployees() {
        withAnimation {
            isLoading = true
            if let restaurantId = restaurantM.restaurant?.id {
                EmployeeViewModel().fetch(restaurantId: restaurantId) { employees in
                    if let employees = employees {
                        self.employees = employees.compactMap { employee in
                            employee.isActive ? employee : nil
                        }
                        self.worksheetRecords = self.employees.map { employee in
                            WorksheetRecord(employee: employee)
                        }
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    isLoading = false
                }
            }
        }
    }
}
