//
//  Hour.swift
//  Aline
//
//  Created by Leonardo on 11/10/23.
//

import Foundation

struct Hour: Equatable, Hashable {
    var hours: Int = 0
    var minutes: Int = 0
    
    init(hours: Int, minutes: Int) {
        self.hours = hours
        switch minutes {
            case 25: self.minutes = 15
            case 50: self.minutes = 30
            case 75: self.minutes = 45
            default: self.minutes = 0
        }
    }
    
    init(_ double: Double) {
        hours = Int(double)
        switch Int(double * 100) % 100 {
            case 25: minutes = 15
            case 50: minutes = 30
            case 75: minutes = 45
            default: minutes = 0
        }
    }
    
    var fullHour: String {
        return "\(hours):\(minutes == 0 ? "00" : "\(minutes)")"
    }
    var double: Double {
        var hoursDouble = Double(hours)
        switch minutes {
            case 15: hoursDouble += 0.25
            case 30: hoursDouble += 0.50
            case 45: hoursDouble += 0.75
            default: hoursDouble += 0.0
        }
        return hoursDouble
    }
    
    
}

extension Hour {
    static func + (lhs: Hour, rhs: Hour) -> Hour { Hour(lhs.double + rhs.double) }
    static func - (lhs: Hour, rhs: Hour) -> Hour { Hour(lhs.double - rhs.double) }
    static func * (lhs: Hour, rhs: Hour) -> Hour { Hour(lhs.double * rhs.double) }
    static func / (lhs: Hour, rhs: Hour) -> Hour { Hour(lhs.double / rhs.double) }
    static func > (lhs: Hour, rhs: Hour) -> Bool { lhs.double > rhs.double }
    static func < (lhs: Hour, rhs: Hour) -> Bool { lhs.double < rhs.double }
}


