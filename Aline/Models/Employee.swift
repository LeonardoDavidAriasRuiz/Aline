//
//  Employee.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Employee: Hashable {
     var id: String
     var name: String
     var lastName: String
     var restaurantLink: String
     var record: CKRecord?
    
    init(id: String, name: String, lastName: String, restaurantLink: String) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.restaurantLink = restaurantLink
        
        let record = CKRecord(recordType: EmployeeKeys.type.rawValue)
        record[EmployeeKeys.type.rawValue] = id
        record[EmployeeKeys.name.rawValue] = name
        record[EmployeeKeys.lastName.rawValue] = lastName
        record[EmployeeKeys.restaurantId.rawValue] = restaurantLink
        
        self.record = record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.lastName = ""
        self.restaurantLink = ""
    }
    
    init(record: CKRecord) {
        self.record = record
        self.id = record[EmployeeKeys.type.rawValue] as? String ?? ""
        self.name = record[EmployeeKeys.name.rawValue] as? String ?? ""
        self.lastName = record[EmployeeKeys.lastName.rawValue] as? String ?? ""
        self.restaurantLink = record[EmployeeKeys.restaurantId.rawValue] as? String ?? ""
    }
    
    
}
