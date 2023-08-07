//
//  Employee.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Employee: Hashable, Equatable, Identifiable {
    var id: String
    var name: String
    var lastName: String
    var restaurantId: String
    var record: CKRecord
    
    private let keys: EmployeeKeys = EmployeeKeys()
    
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
        
        self.record = record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.lastName = ""
        self.restaurantId = ""
        self.record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.record = record
        self.id = record[keys.type] as? String ?? ""
        self.name = record[keys.name] as? String ?? ""
        self.lastName = record[keys.lastName] as? String ?? ""
        self.restaurantId = record[keys.restaurantId] as? String ?? ""
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
