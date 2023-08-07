//
//  Conection.swift
//  Aline
//
//  Created by Leonardo on 02/08/23.
//

import Foundation
import CloudKit

struct Conection: Hashable, Equatable {
    private let keys: ConectionKeys = ConectionKeys()
    
    var id: String = UUID().uuidString
    var email: String
    var isAdmin: Bool
    var restaurantId: String
    var record: CKRecord
    
    init(email: String, isAdmin: Bool, restaurantId: String) {
        self.id = UUID().uuidString
        self.email = email
        self.isAdmin = isAdmin
        self.restaurantId = restaurantId
        self.record = CKRecord(recordType: keys.type)
    }
    
    init(restaurantId: String) {
        self.id = UUID().uuidString
        self.email = ""
        self.isAdmin = false
        self.restaurantId = restaurantId
        self.record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.email = record[keys.email] as? String ?? ""
        self.isAdmin = record[keys.isAdmin] as? Bool ?? false
        self.restaurantId = record[keys.restaurantId] as? String ?? ""
        self.record = record
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Conection, rhs: Conection) -> Bool {
       lhs.id == rhs.id &&
       lhs.email == rhs.email &&
       lhs.isAdmin == rhs.isAdmin &&
       lhs.restaurantId == rhs.restaurantId
   }
}
