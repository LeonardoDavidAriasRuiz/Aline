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
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return calendar.date(from: components) ?? Date()
    }
    
    var lastDayOfWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: self.firstDayOfWeek) ?? Date()
    }
    
    var firstDayOfFortnight: Date {
        if 1...15 ~= self.dayInt {
            return self.firstDayOfMonth
        } else {
            let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: self.monthInt, day: 16, hour: 0, minute: 0, second: 0)
            return Calendar.current.date(from: dateComponents) ?? Date()
        }
    }
    
    var lastDayOfFortnight: Date {
        if Array(1...15).contains(self.dayInt) {
            let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: self.monthInt, day: 15, hour: 23, minute: 59, second: 59)
            return Calendar.current.date(from: dateComponents) ?? Date()
        } else {
            return self.lastDayOfMonth
        }
    }
    
    var firstDayOfMonth: Date {
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: self.monthInt, day: 1, hour: 0, minute: 0, second: 1)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var firstDayOfNextMonth: Date {
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: self.monthInt + 1, day: 1, hour: 0, minute: 0, second: 1)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var lastDayOfNextMonth: Date {
        let lastDay = Calendar.current.date(byAdding: DateComponents(month: 2, day: -1), to: self.firstDayOfMonth) ?? Date()
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: lastDay.yearInt, month: lastDay.monthInt, day: lastDay.dayInt, hour: 23, minute: 59, second: 59)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var lastDayOfMonth: Date {
        let lastDay = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.firstDayOfMonth) ?? Date()
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: lastDay.yearInt, month: lastDay.monthInt, day: lastDay.dayInt, hour: 23, minute: 59, second: 59)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var firstDayOfYear: Date {
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var lastDayOfYear: Date {
        let dateComponents = DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: self.yearInt, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return Calendar.current.date(from: dateComponents) ?? Date()
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


