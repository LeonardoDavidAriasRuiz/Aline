//
//  Spending.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import Foundation
import CloudKit

struct Spending: Hashable, Equatable, Identifiable {
    private let keys: SpendingKeys = SpendingKeys()
    var id: String = UUID().uuidString
    var quantity: Double
    var notes: String
    var date: Date
    var spendingTypeId: String
    var beneficiaryId: String
    var restaurantId: String
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.quantity] = quantity
        _record[keys.notes] = notes
        _record[keys.date] = date
        _record[keys.spendingTypeId] = spendingTypeId
        _record[keys.beneficiaryId] = beneficiaryId
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.quantity = 0.00
        self.notes = ""
        self.date = Date()
        self.spendingTypeId = ""
        self.beneficiaryId = "none"
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.quantity = record[keys.quantity] ?? 0.0
        self.notes = record[keys.notes] ?? ""
        self.date = record[keys.date] ?? Date()
        self.spendingTypeId = record[keys.spendingTypeId] ?? ""
        self.beneficiaryId = record[keys.beneficiaryId] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Spending, rhs: Spending) -> Bool {
        lhs.id == rhs.id &&
        lhs.quantity == rhs.quantity &&
        lhs.notes == rhs.notes &&
        lhs.date == rhs.date &&
        lhs.spendingTypeId == rhs.spendingTypeId &&
        lhs.beneficiaryId == rhs.beneficiaryId &&
        lhs.restaurantId == rhs.restaurantId
    }
}
