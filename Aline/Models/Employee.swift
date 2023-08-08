//
//  Employee.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Employee: Hashable, Equatable, Identifiable {
    private let keys: EmployeeKeys = EmployeeKeys()
    
    var id: String
    var name: String
    var lastName: String
    var restaurantId: String
    
    private var _record: CKRecord
    
    var record: CKRecord {
        get {
            _record[keys.id] = id
            _record[keys.name] = name
            _record[keys.lastName] = lastName
            _record[keys.restaurantId] = restaurantId
            return _record
        }
        set(newRecord) {
            id = record[keys.type] ?? ""
            name = record[keys.name] ?? ""
            lastName = record[keys.lastName] ?? ""
            restaurantId = record[keys.restaurantId] ?? ""
            _record = newRecord
        }
    }
    
    init(id: String, name: String, lastName: String, restaurantId: String) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.restaurantId = restaurantId
        
        let record = CKRecord(recordType: keys.type)
        record[keys.type] = id
        record[keys.name] = name
        record[keys.lastName] = lastName
        record[keys.restaurantId] = restaurantId
        
        self._record = record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.lastName = ""
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.type] ?? ""
        self.name = record[keys.name] ?? ""
        self.lastName = record[keys.lastName] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.lastName == rhs.lastName &&
        lhs.restaurantId == rhs.restaurantId
    }
}
