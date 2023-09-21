//
//  User.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct User: Hashable, Equatable, Identifiable {
    private let keys: UserKeys = UserKeys()
    
    var id: String = ""
    var name: String
    var email: String
    var adminIds: [String]
    var emploIds: [String]
    var record: CKRecord
    
    init(record: CKRecord) {
        self.id = record[keys.id] as? String ?? ""
        self.name = record[keys.name] as? String ?? ""
        self.email = record[keys.email] as? String ?? ""
        self.adminIds = record[keys.adminRestaurantsIds] as? [String] ?? [""]
        self.emploIds = record[keys.emploRestaurantsIds] as? [String] ?? [""]
        self.record = record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.email = ""
        self.adminIds = [""]
        self.emploIds = [""]
        self.record = CKRecord(recordType: keys.type)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.adminIds == rhs.adminIds &&
        lhs.emploIds == rhs.emploIds
    }
}
