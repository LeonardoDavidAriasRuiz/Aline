//
//  Check.swift
//  Aline
//
//  Created by Leonardo on 23/11/23.
//

import Foundation
import CloudKit

struct Check: Hashable, Equatable, Identifiable, Comparable {
    private let keys: CheckKeys = CheckKeys()
    
    let id: String
    var date: Date
    var fortnight: Fortnight
    var cash: Double
    var direct: Double
    var employeeId: String
    var restaurantId: String
    var employee: Employee
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.date] = date
        _record[keys.fortnight] = fortnight.rawValue
        _record[keys.cash] = cash
        _record[keys.direct] = direct
        _record[keys.employeeId] = employeeId
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init(employee: Employee, restaurantId: String, date: Date, fortnight: Fortnight) {
        self.id = UUID().uuidString
        self.date = date
        self.fortnight = fortnight
        self.cash = 0
        self.direct = 0
        self.restaurantId = restaurantId
        self.employeeId = employee.id
        self.employee = employee
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.date = record[keys.date] ?? Date()
        switch record[keys.fortnight] as? Int ?? 1 {
            case 2: self.fortnight = .second
            default: self.fortnight = .first
        }
        self.cash = record[keys.cash] ?? 0.0
        self.direct = record[keys.direct] ?? 0.0
        self.employeeId = record[keys.employeeId] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
        self.employee = Employee()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Check, rhs: Check) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.fortnight == rhs.fortnight &&
        lhs.cash == rhs.cash &&
        lhs.direct == rhs.direct &&
        lhs.employeeId == rhs.employeeId &&
        lhs.restaurantId == rhs.restaurantId
    }
    
    static func < (lhs: Check, rhs: Check) -> Bool {
        lhs.employee.fullName < rhs.employee.fullName
    }
}

enum Fortnight: Int {
    case first = 1
    case second = 2
}

