//
//  DateFormatting.swift
//  Aline
//
//  Created by Leonardo on 21/08/23.
//

import Foundation

extension Date {
    
    var short: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
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
    
    var getMonthAbbreviation: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    var seconds: Int {
        return Calendar.current.component(.second, from: self)
    }
}


