//
//  SalesTable.swift
//  Aline
//
//  Created by Leonardo on 13/09/23.
//

import SwiftUI

struct SalesTable: View {
    @EnvironmentObject private var alertVM: AlertViewModel
    @Binding var sales: [Sale]
    let totalBy: TotalBy
    @State var showed: Bool = false
    @State var tappedSale: Sale?
    @State private var deletedButtonPressed: Bool = false
    
    private let invalidDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    
    var body: some View {
        if sales.isNotEmpty {
            WhiteArea {
                OpenSectionButton(pressed: $showed, text: "Ventas")
                if showed {
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
                                Text("Depo:")
                                Divider()
                                Text("DSCAN:")
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
                            LazyHStack {
                                ForEach(sales.sorted(by: {$0.date < $1.date})) { sale in
                                    Divider()
                                    HStack {
                                        VStack(alignment: .leading) {
                                            VStack {
                                                validateDate(sale.date)
                                                Divider()
                                                validateRtonos(sale.rtonos)
                                                Divider()
                                                validateQuantity(sale.vequipo)
                                                Divider()
                                                validateQuantity(sale.carmenTRJTA)
                                                Divider()
                                                validateQuantity(sale.depo)
                                                Divider()
                                                validateQuantity(sale.dscan)
                                                Divider()
                                            }
                                            VStack {
                                                validateQuantity(sale.doordash)
                                                Divider()
                                                validateQuantity(sale.online)
                                                Divider()
                                                validateQuantity(sale.grubhub)
                                                Divider()
                                                validateQuantity(sale.tacobar)
                                            }
                                        }
                                        if tappedSale == sale {
                                            Button(action: showDeleteAlert) {
                                                VStack {
                                                    Image(systemName: "trash.fill")
                                                        .foregroundStyle(.white)
                                                        .padding(5)
                                                        .font(.title)
                                                }
                                                .padding(10)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .onTapGesture(perform: {selectSaleOnTap(sale)})
                                }
                            }
                        }
                    }.padding(.vertical, 8)
                    .alertDelete(showed: $deletedButtonPressed, action: {deleteSale(tappedSale ?? Sale())})
                }
            }
        } else {
            Text("")
        }
    }
    
    private func showDeleteAlert() {
        deletedButtonPressed = true
    }
    
    private func deleteSale(_ sale: Sale) {
        withAnimation {
            SaleViewModel().delete(sale.record) {
                sales.removeAll { $0.date == sale.date }
            } ifNot: {
                alertVM.show(.deletingError)
            }
        }
    }
    
    private func selectSaleOnTap(_ sale: Sale) {
        withAnimation {
            tappedSale = tappedSale  != sale ? sale : nil
        }
    }
    
    private func validateRtonos(_ quantity: Double) -> some View {
        let isQuantityValid: Bool = quantity >= 0
        var color: Color
        
        if isQuantityValid {
            if quantity > 4_000 {
                if totalBy == .day{
                    color = getCustomColor(value: quantity)
                } else {
                    color = .secondary
                }
            } else {
                color = Color.red
            }
        } else {
            color = .red
        }
        return Text(quantity.comasText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.8))
        //            .foregroundStyle(.white)
    }
    
    private func validateQuantity(_ quantity: Double) -> some View {
        let isQuantityValid: Bool = quantity >= 0
        let textColor: Color = isQuantityValid ? .secondary : .red
        
        return Text(quantity.comasText).foregroundStyle(textColor)
    }
    
    private func validateDate(_ date: Date) -> Text {
        let isDateValid: Bool = date > invalidDate
        let textColor: Color = isDateValid ? .primary : .red
        var dateText: String = ""
        switch totalBy {
            case .day: dateText = date.shortDate
            case .week: dateText = "\(date.firstDayOfWeek.day) - \(date.lastDayOfWeek.shortDate)"
            case .month: dateText = date.month
        }
        return Text(dateText).foregroundStyle(textColor).bold()
    }
    
    func getCustomColor(value: Double) -> Color {
        let customGreen = Color(red: 0.682, green: 0.820, blue: 0.373)
        let customRed = Color(red: 0.825, green: 0.894, blue: 0.825)
        
        let maxVal = sales.max(by: {$0.rtonos > $1.rtonos})?.rtonos ?? 1.0
        let minVal = sales.min(by: {$0.rtonos > $1.rtonos})?.rtonos ?? 0.0
        let range = maxVal - minVal
        
        let normalizedValue = (value - minVal) / range
        
        let red1 = getRGBA(color: customGreen).red * (1 - normalizedValue)
        let green1 = getRGBA(color: customGreen).green * (1 - normalizedValue)
        let blue1 = getRGBA(color: customGreen).blue * (1 - normalizedValue)
        
        let red2 = getRGBA(color: customRed).red * normalizedValue
        let green2 = getRGBA(color: customRed).green * normalizedValue
        let blue2 = getRGBA(color: customRed).blue * normalizedValue
        
        return Color(red: red1 + red2, green: green1 + green2, blue: blue1 + blue2)
    }
    
    func getRGBA(color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
