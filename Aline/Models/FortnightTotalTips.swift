//
//  FortnightTotalTips.swift
//  Aline
//
//  Created by Leonardo on 13/12/23.
//

import Foundation
import CloudKit

struct FortnightTotalTips: Hashable, Equatable, Comparable {
    private let keys: FortnightTotalTipsKeys = FortnightTotalTipsKeys()
    
    var id: String
    let date: Date
    let employeeId: String
    let restaurantId: String
    let employee: Employee?
    var total: Double
    var direct: Double
    var delivered: Bool
    var cahs: Double { total - direct }
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.date] = date
        _record[keys.employeeId] = employeeId
        _record[keys.restaurantId] = restaurantId
        _record[keys.direct] = direct
        _record[keys.delivered] = delivered
        return _record
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.date = record[keys.date] ?? Date()
        self.employeeId = record[keys.employeeId] ?? ""
        self.employee = nil
        self.restaurantId = record[keys.restaurantId] ?? ""
        self.total = 0.0
        self.direct = record[keys.direct] ?? 0.0
        self.delivered = record[keys.delivered] ?? false
    }
    
    init(date: Date, employee: Employee, total: Double, direct: Double, restaurantId: String) {
        self.id = UUID().uuidString
        self.date = date
        self.restaurantId = restaurantId
        self.employeeId = employee.id
        self.employee = employee
        self.total = total
        self.direct = direct
        self.delivered = false
        self._record = CKRecord(recordType: keys.type)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FortnightTotalTips, rhs: FortnightTotalTips) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.employeeId == rhs.employeeId &&
        lhs.restaurantId == rhs.restaurantId &&
        lhs.employee == rhs.employee &&
        lhs.total == rhs.total &&
        lhs.direct == rhs.direct &&
        lhs.delivered == rhs.delivered
    }
    
    static func < (lhs: FortnightTotalTips, rhs: FortnightTotalTips) -> Bool {
        lhs.employee?.fullName ?? "Error" > rhs.employee?.fullName ?? "Error"
    }
}
