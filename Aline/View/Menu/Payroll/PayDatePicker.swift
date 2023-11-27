//
//  PayDatePicker.swift
//  Aline
//
//  Created by Leonardo on 21/10/23.
//

import SwiftUI

struct PayDatePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var payDate: Date
    
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
        NavigationStack {
            DatePicker("PayDate", selection: $payDate, in: startDate...endDate , displayedComponents: .date).datePickerStyle(.graphical)
                .onChange(of: payDate) { old, newValue in
                    validate(date: newValue)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Ok", action: {dismiss()})
                    }
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
                    payDate = newDate
                }
            }
        }
    }
}
