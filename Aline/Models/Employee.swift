//
//  Employee.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Employee: Hashable, Equatable, Identifiable, Comparable {
    private let keys: EmployeeKeys = EmployeeKeys()
    
    var id: String
    var name: String
    var lastName: String
    var isActive: Bool
    var salary: Bool
    var quantity: Double
    var restaurantId: String
    
    var fullName: String {
        return "\(lastName) \(name)"
    }
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.name] = name
        _record[keys.lastName] = lastName
        _record[keys.isActive] = isActive
        _record[keys.salary] = salary
        _record[keys.quantity] = quantity
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.lastName = ""
        self.isActive = true
        self.restaurantId = ""
        self.salary = true
        self.quantity = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.name = record[keys.name] ?? ""
        self.lastName = record[keys.lastName] ?? ""
        self.isActive = record[keys.isActive] ?? false
        self.salary = record[keys.salary] ?? false
        self.quantity = record[keys.quantity] ?? 0.0
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.isActive == rhs.isActive &&
        lhs.lastName == rhs.lastName &&
        lhs.salary == rhs.salary &&
        lhs.quantity == rhs.quantity &&
        lhs.restaurantId == rhs.restaurantId
    }
    
    static func < (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.fullName < rhs.fullName
    }
}
