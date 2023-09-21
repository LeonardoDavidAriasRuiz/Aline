//
//  SalesChart.swift
//  Aline
//
//  Created by Leonardo on 15/09/23.
//

import SwiftUI

struct SalesChart: View {
    @State private var height: CGFloat = 300;
    @State private var colorLimit: Double = 4000
    @State private var hoverSection: Sale?
    @State private var showedQuantities: Bool = false
    @State private var showedDaysByWeekDay: Bool = false
    
    let title: String
    @Binding var data: [Sale]
    @Binding var totalBy: TotalBy

    var body: some View {
        WhiteArea {
            if data.isNotEmpty {
                HStack {
                    Text(title).font(.largeTitle).bold()
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(data) { item in
                            VStack {
                                Spacer()
                                Text(item.rtonos.comasText)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(hoverSection == item ? .black : .secondary)
                                    .font(hoverSection == item ? .largeTitle : showedQuantities ? .body : .system(size: 0.1))
                                RoundedRectangle(cornerRadius: 35)
                                    .foregroundStyle(getItemColor(for: item))
                                    .frame(height: getItemHeight(for: item))
                                    .frame(width: getItemWidth(for: item))
                                    .onTapGesture(perform: {selectSaleOnTap(item)})
                                Text(getXAxi1(for: item))
                                    .foregroundStyle(showedDaysByWeekDay && (item.date.weekdayInitial == "d")  && totalBy == .day ? .black : .secondary)
                                    .bold(showedDaysByWeekDay && (item.date.weekdayInitial == "d")  && totalBy == .day ? true : false)
                                Text(getXAxi2(for: item))
                                    .opacity(getXAxi2Opcaity(for: item))
                                    .frame(maxWidth: .infinity)
                                    .bold()
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: height + 200)
            } else {
                Text("No hay datos para estas fechas")
                    .font(.largeTitle)
                    .padding(.vertical, 100)
            }
            Divider()
            Toggle("Mostrar cantidades", isOn: $showedQuantities.animation())
            if totalBy == .day {
                Divider()
                Toggle("Ver por día de semana", isOn: $showedDaysByWeekDay.animation())
            }
        }
    }
    
    private func selectSaleOnTap(_ item: Sale) {
        withAnimation(.easeOut(duration: 0.2)) {
            hoverSection = hoverSection  != item ? item : nil
        }
    }
    
    private func getItemHeight(for item: Sale) -> CGFloat {
        item.rtonos / (data.max(by: {$0.rtonos < $1.rtonos})?.rtonos ?? 0.0) * (height - 20)
    }
    
    private func getItemWidth(for item: Sale) -> CGFloat {
        if hoverSection == item {
            return totalBy == .day ? 100 : 100
        } else {
            return totalBy == .day ? 25 : 50
        }
    }
    
    private func getItemColor(for item: Sale) -> Color {
        if item.rtonos < colorLimit {
            return Color.red.opacity(1-((item.rtonos - 2000)  / (data.max(by: {$0.rtonos < $1.rtonos})?.rtonos ?? 1.0)))
        } else {
            return Color.green.opacity(item.rtonos / (data.max(by: {$0.rtonos < $1.rtonos})?.rtonos ?? 1.0))
        }
    }
    
    private func getXAxi1(for item: Sale) ->  String {
        switch totalBy {
            case .day:
                return showedDaysByWeekDay ? item.date.weekdayInitial : item.date.day
            case .week:
                if let sixDaysBefore = Calendar.current.date(byAdding: DateComponents(month: 0, day: -6), to: item.date)?.day {
                    return "\(sixDaysBefore) - \(item.date.day)"
                } else {
                    return item.date.day
                }
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
//            return "1234567".contains(item.date.day) || hoverSection == item ? 1 : 0
                return 1
        case .month:
            return item.date.monthNumber == "01" || hoverSection == item ? 1 : 0
        }
    }
}
