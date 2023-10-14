//
//  Worksheet.swift
//  Aline
//
//  Created by Leonardo on 11/10/23.
//

import SwiftUI
import CloudKit

struct Worksheet: Identifiable, Hashable, Equatable {
    private let keys: WorksheetKeys = WorksheetKeys()
    var id: String
    var payDate: Date
    var bonus: Bool
    var notes: String
    var sent: Bool
    var restaurantId: String
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.payDate] = payDate
        _record[keys.bonus] = bonus
        _record[keys.notes] = notes
        _record[keys.sent] = sent
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        let calendar = Calendar.current
        let day = Date().dayInt
        var date = Date()
        if day != 5 && day != 20 {
            var newDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            newDateComponents.day = day < 5 ? 5 : 20
            
            if let newDate = calendar.date(from: newDateComponents) {
                date = newDate
            }
        }
        self.payDate = date
        self.bonus = false
        self.notes = ""
        self.sent = false
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.payDate = record[keys.payDate] ?? Date()
        self.bonus = record[keys.bonus] ?? false
        self.notes = record[keys.notes] ?? ""
        self.sent = record[keys.sent] ?? false
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Worksheet, rhs: Worksheet) -> Bool {
        lhs.id == rhs.id &&
        lhs.payDate == rhs.payDate &&
        lhs.bonus == rhs.bonus &&
        lhs.notes == rhs.notes &&
        lhs.sent == rhs.sent &&
        lhs.restaurantId == rhs.restaurantId
    }
}

struct WorksheetRecord: Identifiable, Hashable, Equatable {
    private let keys : WorksheetRecordKeys = WorksheetRecordKeys()
    var id: String
    var worksheetId: String
    var employeeId: String
    var salary: Bool
    var quantity: Double
    var hours: Hour
    var overTime: Hour
    var sickTime: Hour
    var cashTips: Double
    var cargedTips: Double
    var garnishment: Double
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.worksheetId] = worksheetId
        _record[keys.employeeId] = employeeId
        _record[keys.salary] = salary
        _record[keys.quantity] = quantity
        _record[keys.hours] = hours.double
        _record[keys.overTime] = overTime.double
        _record[keys.sickTime] = sickTime.double
        _record[keys.cashTips] = cashTips
        _record[keys.cargedTips] = cargedTips
        _record[keys.garnishment] = garnishment
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.worksheetId = ""
        self.employeeId = ""
        self.salary = true
        self.quantity = 0.0
        self.hours = Hour(hours: 0, minutes: 0)
        self.overTime = Hour(hours: 0, minutes: 0)
        self.sickTime = Hour(hours: 0, minutes: 0)
        self.cashTips = 0.0
        self.cargedTips = 0.0
        self.garnishment = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(employee: Employee) {
        self.id = UUID().uuidString
        self.worksheetId = ""
        self.employeeId = employee.id
        self.salary = employee.salary
        self.quantity = employee.quantity
        self.hours = Hour(hours: 0, minutes: 0)
        self.overTime = Hour(hours: 0, minutes: 0)
        self.sickTime = Hour(hours: 0, minutes: 0)
        self.cashTips = 0.0
        self.cargedTips = 0.0
        self.garnishment = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.worksheetId = record[keys.worksheetId] ?? ""
        self.worksheetId = record[keys.id] ?? ""
        self.employeeId = record[keys.employeeId] ?? ""
        self.salary = record[keys.salary] ?? true
        self.quantity = record[keys.quantity] ?? 0.0
        self.hours = Hour(record[keys.hours] ?? 0.0)
        self.overTime = Hour(record[keys.overTime] ?? 0.0)
        self.sickTime = Hour(record[keys.sickTime] ?? 0.0)
        self.cashTips = record[keys.cashTips] ?? 0.0
        self.cargedTips = record[keys.cargedTips] ?? 0.0
        self.garnishment = record[keys.garnishment] ?? 0.0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WorksheetRecord, rhs: WorksheetRecord) -> Bool {
        lhs.id == rhs.id &&
        lhs.worksheetId == rhs.worksheetId &&
        lhs.employeeId == rhs.employeeId &&
        lhs.salary == rhs.salary &&
        lhs.quantity == rhs.quantity &&
        lhs.hours == rhs.hours &&
        lhs.overTime == rhs.overTime &&
        lhs.sickTime == rhs.sickTime &&
        lhs.cashTips == rhs.cashTips &&
        lhs.cargedTips == rhs.cargedTips &&
        lhs.garnishment == rhs.garnishment
    }
}
