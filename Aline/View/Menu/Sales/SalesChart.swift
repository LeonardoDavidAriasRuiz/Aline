//
//  SalesChart.swift
//  Aline
//
//  Created by Leonardo on 15/09/23.
//

import SwiftUI

struct SalesChart: View {
    private let height: CGFloat = 300;
    @State private var hoverSection: Sale?
    
    let title: String
    @Binding var sales: [Sale]
    @Binding var totalBy: TotalBy
    @Binding var showedQuantities: Bool
    @Binding var showedDaysByWeekDay: Bool
    @Binding var colorLimit: Double
    @Binding var salesType: SalesType
    
    @Binding var mondayShowed: Bool
    @Binding var tuesdayShowed: Bool
    @Binding var wednesdayShowed: Bool
    @Binding var thursdayShowed: Bool
    @Binding var fridayShowed: Bool
    @Binding var saturdayShowed: Bool
    @Binding var sundayShowed: Bool
    
    var body: some View {
        if sales.isNotEmpty {
            WhiteArea {
                HStack {
                    Text(title).font(.largeTitle).bold()
                    Spacer()
                }
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10) {
                        ForEach(sales) { item in
                            if (item.date.weekdayInt == 1 && sundayShowed) ||
                                (item.date.weekdayInt == 2 && mondayShowed) ||
                                (item.date.weekdayInt == 3 && tuesdayShowed) ||
                                (item.date.weekdayInt == 4 && wednesdayShowed) ||
                                (item.date.weekdayInt == 5 && thursdayShowed) ||
                                (item.date.weekdayInt == 6 && fridayShowed) ||
                                (item.date.weekdayInt == 7 && saturdayShowed) {
                                VStack {
                                    Spacer()
                                    Text(getQuantity(item).comasText)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundStyle(hoverSection == item ? .primary : .secondary)
                                        .font(hoverSection == item ? .largeTitle : showedQuantities ? .body : .system(size: 0.1))
                                    RoundedRectangle(cornerRadius: 35)
                                        .foregroundStyle(getItemColor(for: item))
                                        .frame(height: getItemHeight(for: item))
                                        .frame(width: getItemWidth(for: item))
                                        
                                    Text(getXAxi1(for: item))
                                        .foregroundStyle((item.date.dayInt == 1)  && totalBy == .day ? .primary : .secondary)
                                        .bold((item.date.dayInt == 1)  && totalBy == .day ? true : false)
                                    if showedDaysByWeekDay {
                                        Text(item.date.weekdayInitial)
                                            .foregroundStyle(showedDaysByWeekDay && (item.date.weekdayInt == 1)  && totalBy == .day ? .primary : .secondary)
                                            .bold(showedDaysByWeekDay && (item.date.weekdayInt == 1)  && totalBy == .day ? true : false)
                                    }
                                    Text(getXAxi2(for: item))
                                        .opacity(getXAxi2Opcaity(for: item))
                                        .frame(maxWidth: .infinity)
                                        .bold()
                                }.onTapGesture(perform: {selectSaleOnTap(item)})
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: height + 200)
            }
        }
    }
    
    private func selectSaleOnTap(_ item: Sale) {
        withAnimation(.easeOut(duration: 0.2)) {
            hoverSection = hoverSection  != item ? item : nil
        }
    }
    
    private func getItemHeight(for item: Sale) -> CGFloat {
        (getQuantity(item) / getMaxQuantity()) * (height - 20)
    }
    
    private func getItemWidth(for item: Sale) -> CGFloat {
        if hoverSection == item {
            return totalBy == .day ? 100 : 100
        } else {
            return totalBy == .day ? 25 : 50
        }
    }
    
    private func getItemColor(for item: Sale) -> Color {
        if getQuantity(item) < colorLimit {
            return Color.red.opacity(1-((getQuantity(item) - 2000)  / getMaxQuantity()))
        } else {
            return Color.green.opacity(getQuantity(item) / getMaxQuantity())
        }
    }
    
    private func getXAxi1(for item: Sale) ->  String {
        switch totalBy {
            case .day:
                return item.date.day
            case .week:
                return "\(item.date.firstDayOfWeek.day) - \(item.date.lastDayOfWeek.day)"
            case .month:
                return item.date.month
        }
    }
    
    private func getXAxi2(for item: Sale) ->  String {
        switch totalBy {
            case .day:
                return item.date.day == "1" || hoverSection == item ?
                "\(item.date.month)\n\(item.date.year)" :
                "\n"
            case .week:
                return item.date.monthAndYear
            case .month:
                return "\n\(item.date.year)"
        }
    }
    
    private func getXAxi2Opcaity(for item: Sale) -> CGFloat {
        switch totalBy {
        case .day:
            return item.date.day == "1" || hoverSection == item ? 1 : 0
        case .week:
            return "1234567".contains(item.date.day) || hoverSection == item ? 1 : 0
//                return 1
        case .month:
            return item.date.monthNumber == "01" || hoverSection == item ? 1 : 0
        }
    }
    
    private func getMaxQuantity() -> Double {
        let salesFiltered = sales.compactMap { sale in
            if (sale.date.weekdayInt == 1 && sundayShowed) ||
                (sale.date.weekdayInt == 2 && mondayShowed) ||
                (sale.date.weekdayInt == 3 && tuesdayShowed) ||
                (sale.date.weekdayInt == 4 && wednesdayShowed) ||
                (sale.date.weekdayInt == 5 && thursdayShowed) ||
                (sale.date.weekdayInt == 6 && fridayShowed) ||
                (sale.date.weekdayInt == 7 && saturdayShowed) {
                return sale
            } else {
                return nil
            }
        }
        return getQuantity(salesFiltered.max { sale1, sale2 in
            getQuantity(sale1) < getQuantity(sale2)
        } ?? Sale())
    }
    
    private func getQuantity(_ item: Sale) -> Double {
        var quantity: Double = 0
        switch salesType {
            case .rtonos: quantity = item.rtonos
            case .vequipo: quantity = item.vequipo
            case .carmenTRJTA: quantity = item.carmenTRJTA
            case .depo: quantity = item.depo
            case .dscan: quantity = item.dscan
            case .doordash: quantity = item.doordash
            case .online: quantity = item.online
            case .grubhub: quantity = item.grubhub
            case .tacobar: quantity = item.tacobar
        }
        
        return quantity
    }
}
