//
//  YearMonthPicker.swift
//  Aline
//
//  Created by Leonardo on 27/09/23.
//

import SwiftUI

struct MonthPicker<Label: View>: View {
    let label: () -> Label
    @Binding var selectedDate: Date
    private let months: [(number: Int, name: String)] = [
        (1, "Enero"),
        (2, "Febrero"),
        (3, "Marzo"),
        (4, "Abril"),
        (5, "Mayo"),
        (6, "Junio"),
        (7, "Julio"),
        (8, "Agosto"),
        (9, "Septiembre"),
        (10, "Octubre"),
        (11, "Noviembre"),
        (12, "Diciembre")
    ]
    
    init(date: Binding<Date>, @ViewBuilder label: @escaping () -> Label) {
        self._selectedDate = date
        self.label = label
    }
    
    init(_ title: String, date: Binding<Date>) where Label == Text {
        self.label = {
            Text(title)
        }
        self._selectedDate = date
    }
    
    var body: some View {
        Menu(content: {
            ForEach(months, id: \.number) { month in
                Button(action: {selectMonth(month.number)}) {
                    Text(month.name)
                }
            }
        }, label: label)
    }
    
    func selectMonth(_ month: Int) {
        var dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        dateComponents.month = month
        if let newDate = Calendar.current.date(from: dateComponents) {
            selectedDate = newDate
        }
    }
}

struct YearPicker<Label: View>: View {
    let label: () -> Label
    let startYear: Int = 2020
    let currentYear: Int = Date().yearInt
    @Binding var selectedDate: Date
    
    init(date: Binding<Date>, @ViewBuilder label: @escaping () -> Label) {
        self.label = label
        self._selectedDate = date
    }
    
    init(_ title: String, date: Binding<Date>) where Label == Text {
        self.label = {
            Text(title)
        }
        self._selectedDate = date
    }
    
    var body: some View {
        Menu(content: {
            ForEach(Array(startYear...currentYear+1), id: \.self) { year in
                Button(action: {selectYear(year)}) {
                    Text(String(year))
                }
            }
        }, label: label)
    }
    
    func selectYear(_ year: Int) {
        var dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        dateComponents.year = year
        if let newDate = Calendar.current.date(from: dateComponents) {
            selectedDate = newDate
        }
    }
}
