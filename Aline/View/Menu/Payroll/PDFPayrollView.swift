//
//  PDFPayrollView.swift
//  Aline
//
//  Created by Leonardo on 14/10/23.
//

import SwiftUI

struct PDFPayrollView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @Binding var worksheet: Worksheet
    @Binding var worksheetRecords: [WorksheetRecord]
    @Binding var employees: [Employee]
    @State private var pdfData: Data = Data()
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("MUNAY ACCOUNTING & TAX").bold().font(.largeTitle).foregroundStyle(Color(red: 0.69, green: 0.811, blue: 0.461))
                Text("PAYROLL WORKSHEET").bold().font(.title).foregroundStyle(Color(red: 0.521, green: 0.759, blue: 0.67))
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                isLoading = true
                                
                                exportPDF {
                                    self
                                } completion: { status, url in
                                    if let url, status {
                                        if let data = try? Data(contentsOf: url) {
                                            print("Data \(data)")
                                            let name = userVM.user.name
                                            let email = userVM.user.email
                                            let exportSalesEmail = ExportSalesEmail()
                                            let subject = exportSalesEmail.subject
                                            let body = exportSalesEmail.body()
                                            let fileName: String = "Gastos.pdf"
                                            MailSMTP().send(name: name, email: email, subject: subject, body: body, data: data, fileName: fileName) {
                                            } ifNot: { } alwaysDo: {
                                                isLoading = false
                                            }
                                            pdfData = data
                                        }
                                    } else {
                                        print("Failed to produce PDF")
                                    }
                                }
                            }) {
                                Label("Enviar", systemImage: "paperplane.fill")
                            }
                        }
                    }
                HStack {
                    Image("JaliscoLogo").resizable().scaledToFit().frame(height: 150)
                    Spacer()
                    VStack {
                        Text("Pay date:").bold().foregroundStyle(Color(red: 0.945, green: 0.671, blue: 0.273))
                        Text(Date().shortDate)
                        Text("")
                        Text("Starting Check # Direct Deposit").bold().foregroundStyle(.gray)
                        HStack {
                            Text("From:").bold().foregroundStyle(Color(red: 0.521, green: 0.759, blue: 0.67))
                            Text(Date().shortDate)
                        }
                        HStack {
                            Text("To:").bold().foregroundStyle(Color(red: 0.521, green: 0.759, blue: 0.67))
                            Text(Date().shortDate)
                        }
                    }
                }
                
                HStack {
                    Text("FGA ENTERPRISES  INC").bold().font(.title2).foregroundStyle(Color(red: 0.931, green: 0.55, blue: 0.485))
                    Spacer()
                }
                HStack {
                    Text("9050 Fairway Dr. Ste 155").foregroundStyle(Color(red: 0.945, green: 0.671, blue: 0.273))
                    Spacer()
                }
                HStack {
                    Text("Roseville, CA 95678").foregroundStyle(Color(red: 0.945, green: 0.671, blue: 0.273))
                    Spacer()
                }.padding(.bottom, 70)
                
                HStack {
                    Text("NAME").frame(maxWidth: .infinity)
                    Text("SALARY").frame(maxWidth: .infinity)
                    Text("RATE").frame(maxWidth: .infinity)
                    Text("HOURS").frame(maxWidth: .infinity)
                    Text("OVER TIME").frame(maxWidth: .infinity)
                    Text("SICK TIME").frame(maxWidth: .infinity)
                    Text("CASH TIPS").frame(maxWidth: .infinity)
                    Text("CARGED TIPS").frame(maxWidth: .infinity)
                    Text("GARNIHSMENT").frame(maxWidth: .infinity)
                }.bold().foregroundStyle(Color.red)
                
                ForEach(worksheetRecords, id: \.self) { record in
                    Divider()
                    HStack {
                        Text(employees.first(where: {$0.id == record.employeeId})?.fullName ?? "Error").frame(maxWidth: .infinity)
                        Text("\(record.salary ? "\(record.quantity.comasTextWithDecimals)" : "0.00")").foregroundStyle(record.salary ? Color.text : Color.text.opacity(0.2)).frame(maxWidth: .infinity)
                        Text("\(record.salary ? "00:00" : "\(record.quantity.comasTextWithDecimals)")").foregroundStyle(record.salary ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.hours.fullHour)").foregroundStyle(record.hours.double == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.overTime.fullHour)").foregroundStyle(record.overTime.double == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.sickTime.fullHour)").foregroundStyle(record.sickTime.double == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.cashTips.comasTextWithDecimals)").foregroundStyle(record.cashTips == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.cargedTips.comasTextWithDecimals)").foregroundStyle(record.cargedTips == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                        Text("\(record.garnishment.comasTextWithDecimals)").foregroundStyle(record.garnishment == 0 ? Color.text.opacity(0.2) : Color.text).frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .padding(30)
            .frame(width: 1275, height: 1650)
            .border(.black, width: 1)
        }
    }
}
