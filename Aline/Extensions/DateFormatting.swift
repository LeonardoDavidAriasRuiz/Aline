//
//  DateFormatting.swift
//  Aline
//
//  Created by Leonardo on 21/08/23.
//

import Foundation

extension Date {
    
    var firstDayOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    var lastDayOfWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: self.firstDayOfWeek)!
    }
    
    var firstDayOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    var lastDayOfMonth: Date {
        let dateComponents = DateComponents(year: self.yearInt, month: self.monthInt == 12 ? 1 : self.monthInt + 1, day: 1)
        let firstDayNextMonth = Calendar.current.date(from: dateComponents)!
        return Calendar.current.date(byAdding: .day, value: -1, to: firstDayNextMonth)!
    }
    
    var firstDayOfYear: Date {
        let dateComponents = DateComponents(year: self.yearInt, month: 1, day: 1)
        return Calendar.current.date(from: dateComponents)!
    }
    
    var lastDayOfYear: Date {
        let dateComponents = DateComponents(year: self.yearInt, month: 12, day: 31)
        return Calendar.current.date(from: dateComponents)!
    }
    
    var shortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    var shortDateEn: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
    var shortDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy h:mm a"
        return formatter.string(from: self)
    }
    
    var hour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    var dayInt: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    var weekdayInitial: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return String(dateFormatter.string(from: self).prefix(1))
    }
    
    var weekdayInt: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var monthInt: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var monthNumber: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    var monthAndYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    var monthAbbreviation: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    var yearInt: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var seconds: Int {
        return Calendar.current.component(.second, from: self)
    }
}


