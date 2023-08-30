//
//  SalesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct SalesView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var totalBy: TotalBy = .day
    @State private var rangeIn: RangeIn = .currentMonth
    
    @State private var rangeInCurrentWeekAviable: Bool = true
    @State private var rangeInCurrentForthnightAviable: Bool = true
    @State private var rangeInCurrentMonthAviable: Bool = true
    @State private var rangeInCurrentYearAviable: Bool = true
    @State private var customRangeSelected: Bool = false
    
    @State private var customFrom: Date = Date()
    @State private var customTo: Date = Date()
    
    @State private var selectedDates: Set<DateComponents> = []
    
    var body: some View {
        FullSheet(section: .sales) {
            filters
            WhiteArea {
                
            }
        }
        .onAppear(perform: accentColor.green)
    }
    
    private var filters: some View {
        WhiteArea {
            HStack {
                Text("Total por")
                Picker("Total por", selection: $totalBy) {
                    Text("Día").tag(TotalBy.day)
                    Text("Semana").tag(TotalBy.week)
                    Text("Quincena").tag(TotalBy.forthnight)
                    Text("Mes").tag(TotalBy.month)
                    Text("Año").tag(TotalBy.year)
                }.pickerStyle(.palette)
                    .onChange(of: totalBy, validationTotalIn)
            }
            HStack {
                Text("En")
                Picker("En", selection: $rangeIn) {
                    if rangeInCurrentWeekAviable {
                        Text("Semana actual").tag(RangeIn.currentWeek)
                    }
                    if rangeInCurrentForthnightAviable {
                        Text("Quincena actual").tag(RangeIn.currentForthnight)
                    }
                    if rangeInCurrentMonthAviable {
                        Text("Mes actual").tag(RangeIn.currentMonth)
                    }
                    if rangeInCurrentYearAviable {
                        Text("Año actual").tag(RangeIn.currentYear)
                    }
                    Text("Años totales").tag(RangeIn.totalYears)
                    Text("Personalizado").tag(RangeIn.customRange)
                }.pickerStyle(.palette)
                    .onChange(of: rangeIn, validateRangeIn)
            }
            if customRangeSelected {
                HStack {
                    Spacer()
                    
                    DatePicker("Del", selection: $customFrom, displayedComponents: .date)
                        .frame(maxWidth: 200)
                        .onChange(of: customFrom) { oldValue, newValue in
                            if let days = Calendar.current.dateComponents([.day], from: customFrom, to: customTo).day{
                                switch days {
                                    case 1...31:
                                        totalBy = .day
                                    case 32...60:
                                        totalBy = .week
                                    case 61...100:
                                        totalBy = .forthnight
                                    case 101...366:
                                        totalBy = .month
                                    case 367...:
                                        totalBy = .year
                                    default:
                                        totalBy = .day
                                }
                            }
                            if newValue > customTo {
                                customTo = customFrom
                            }
                        }
                    
                    Spacer()
                    DatePicker("A", selection: $customTo, displayedComponents: .date)
                        .frame(maxWidth: 200)
                        .onChange(of: customTo) { oldValue, newValue in
                            if let days = Calendar.current.dateComponents([.day], from: customFrom, to: customTo).day{
                                switch days {
                                    case 1...31:
                                        totalBy = .day
                                    case 32...60:
                                        totalBy = .week
                                    case 61...100:
                                        totalBy = .forthnight
                                    case 101...366:
                                        totalBy = .month
                                    case 367...:
                                        totalBy = .year
                                    default:
                                        totalBy = .day
                                }
                            }
                            if newValue < customFrom {
                                customFrom = customTo
                            }
                        }
                    Spacer()
                }
            }
        }
    }
    
    private func validationTotalIn() {
        withAnimation {
            switch totalBy {
                case .day:
                    rangeInCurrentWeekAviable = true
                    rangeInCurrentForthnightAviable = true
                    rangeInCurrentMonthAviable = true
                    rangeInCurrentYearAviable = true
                case .week:
                    if rangeIn == .currentWeek {
                        rangeIn = .currentForthnight
                    }
                    rangeInCurrentWeekAviable = false
                    rangeInCurrentForthnightAviable = true
                    rangeInCurrentMonthAviable = true
                    rangeInCurrentYearAviable = true
                case .forthnight:
                    if rangeIn == .currentWeek ||
                        rangeIn == .currentForthnight {
                        rangeIn = .currentMonth
                    }
                    rangeInCurrentWeekAviable = false
                    rangeInCurrentForthnightAviable = false
                    rangeInCurrentMonthAviable = true
                    rangeInCurrentYearAviable = true
                case .month:
                    if rangeIn == .currentWeek ||
                        rangeIn == .currentForthnight ||
                        rangeIn == .currentMonth {
                        rangeIn = .currentYear
                    }
                    rangeInCurrentWeekAviable = false
                    rangeInCurrentForthnightAviable = false
                    rangeInCurrentMonthAviable = false
                    rangeInCurrentYearAviable = true
                case .year:
                    if rangeIn != .customRange {
                        rangeIn = .totalYears
                    }
                    rangeInCurrentWeekAviable = false
                    rangeInCurrentForthnightAviable = false
                    rangeInCurrentMonthAviable = false
                    rangeInCurrentYearAviable = false
            }
        }
    }
    
    private func validateRangeIn() {
        withAnimation {
            switch rangeIn {
                case .currentWeek:
                    customRangeSelected = false
                case .currentForthnight:
                    customRangeSelected = false
                case .currentMonth:
                    customRangeSelected = false
                case .currentYear:
                    customRangeSelected = false
                case .totalYears:
                    customRangeSelected = false
                case .customRange:
                    customRangeSelected = true
            }
        }
    }
}

enum TotalBy: String {
    case day = "Día"
    case week = "Semana"
    case forthnight = "Quincena"
    case month = "Mes"
    case year = "Año"
}

enum RangeIn: String {
    case currentWeek = "Semana actual"
    case currentForthnight = "Quincena actual"
    case currentMonth = "Mes actual"
    case currentYear = "Año actual"
    case totalYears = "Años totales"
    case customRange = "Personalizado"
}
