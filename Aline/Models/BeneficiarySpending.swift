//
//  BeneficiarySpending.swift
//  Aline
//
//  Created by Leonardo on 07/12/23.
//

import Foundation
import CloudKit

struct BeneficiarySpending: Hashable, Equatable, Identifiable {
    private let keys: BeneficiarySpendingKeys = BeneficiarySpendingKeys()
    
    var id = UUID().uuidString
    let beneficiaryId: String
    let date: Date
    var quantity: Double
    var note: String
    let restaurantId: String
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.beneficiaryId] = beneficiaryId
        _record[keys.date] = date
        _record[keys.quantity] = quantity
        _record[keys.note] = note
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init(beneficiary: Beneficiary, date: Date, restaurantId: String) {
        self.id = UUID().uuidString
        self.beneficiaryId = beneficiary.id
        self.date = date
        self.quantity = 0.0
        self.note = ""
        self.restaurantId = restaurantId
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.beneficiaryId = record[keys.beneficiaryId] ?? ""
        self.date = record[keys.date] ?? Date()
        self.quantity = record[keys.quantity] ?? 0.0
        self.note = record[keys.note] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BeneficiarySpending, rhs: BeneficiarySpending) -> Bool {
        lhs.id == rhs.id &&
        lhs.beneficiaryId == rhs.beneficiaryId &&
        lhs.date == rhs.date &&
        lhs.quantity == rhs.quantity &&
        lhs.note == rhs.note &&
        lhs.restaurantId == rhs.restaurantId
    }
}

struct BeneficiarySpendings: Hashable {
    var id = UUID().uuidString
    let beneficiary: Beneficiary
    var date: Date
    var spendings: [BeneficiarySpending]
    var totalSpendings: Double { spendings.reduce(0.0) { $0 + $1.quantity } }
}
