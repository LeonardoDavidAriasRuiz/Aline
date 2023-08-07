//
//  Restaurant.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import Foundation
import CloudKit

 struct Restaurant: Hashable, Equatable, Identifiable {
    private let keys: RestaurantKeys = RestaurantKeys()
    
     var id: String
     var name: String
     var email: String
     var adminUsersIds: [String]
     var emploUsersIds: [String]
     var record: CKRecord
    
     init(record: CKRecord) {
        self.id = record[keys.id] as? String ?? ""
        self.name = record[keys.name] as? String ?? ""
        self.email = record[keys.email] as? String ?? ""
        self.adminUsersIds = record[keys.adminUsersIds] as? [String] ?? [""]
        self.emploUsersIds = record[keys.emploUsersIds] as? [String] ?? [""]
        self.record = record
    }
    
     init() {
        self.id = UUID().uuidString
        self.name = ""
        self.email = ""
        self.adminUsersIds = [""]
        self.emploUsersIds = [""]
        self.record = CKRecord(recordType: keys.type)
    }
    
     func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    
     static func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.adminUsersIds == rhs.adminUsersIds &&
        lhs.emploUsersIds == rhs.emploUsersIds
    }
}
