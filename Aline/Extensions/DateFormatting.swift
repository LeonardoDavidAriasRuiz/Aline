//
//  DateFormatting.swift
//  Aline
//
//  Created by Leonardo on 21/08/23.
//

import Foundation

extension Date {
    var firstDayOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var lastDayOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: self.firstDayOfMonth) ?? self
    }
    
    var shortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    var shortDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy h:mm a"
        return formatter.string(from: self)
    }
    
    var time: String {
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
    
    var weekdayInitial: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return String(dateFormatter.string(from: self).prefix(1))
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


