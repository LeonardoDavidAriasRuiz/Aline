//
//  SpendingType.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import Foundation
import CloudKit

struct SpendingType: Hashable, Equatable, Identifiable {
    private let keys: SpendingTypeKeys = SpendingTypeKeys()
    var id: String
    var name: String
    var description: String
    var restaurantId: String
    var spendings: [Spending] = []
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.name] = name
        _record[keys.description] = description
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.description = ""
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.name = record[keys.name] ?? ""
        self.description = record[keys.description] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SpendingType, rhs: SpendingType) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.spendings == rhs.spendings &&
        lhs.restaurantId == rhs.restaurantId
    }
}
