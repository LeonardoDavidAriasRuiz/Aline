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
    var fortnightChecksType: FortnightChecksType
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.name] = name
        _record[keys.email] = email
        _record[keys.adminUsersIds] = adminUsersIds
        _record[keys.emploUsersIds] = emploUsersIds
        _record[keys.fortnightChecksType] = fortnightChecksType.rawValue
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.email = ""
        self.adminUsersIds = [""]
        self.emploUsersIds = [""]
        self.fortnightChecksType = .nextFortnight
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.id = record[keys.id] as? String ?? ""
        self.name = record[keys.name] as? String ?? ""
        self.email = record[keys.email] as? String ?? ""
        self.adminUsersIds = record[keys.adminUsersIds] as? [String] ?? [""]
        self.emploUsersIds = record[keys.emploUsersIds] as? [String] ?? [""]
        self.fortnightChecksType = (record[keys.fortnightChecksType] as? Int ?? 2) == 1 ? .monthByMonth : .nextFortnight
        self._record = record
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.adminUsersIds == rhs.adminUsersIds &&
        lhs.emploUsersIds == rhs.emploUsersIds &&
        lhs.fortnightChecksType == rhs.fortnightChecksType
    }
}

enum FortnightChecksType: Int {
    case monthByMonth = 1
    case nextFortnight = 2
}
