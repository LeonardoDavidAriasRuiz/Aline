//
//  Deposit.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Deposit: Hashable, Equatable {
    private let keys: DepositKeys = DepositKeys()
     var id: String = UUID().uuidString
     var quantity: Int
     var date: Date
     var restaurantId: String
    private var record: CKRecord?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Deposit, rhs: Deposit) -> Bool {
        lhs.id == rhs.id &&
        lhs.quantity == rhs.quantity &&
        lhs.date == rhs.date &&
        lhs.restaurantId == rhs.restaurantId
    }
    
    init(id: String, quantity: Int, date: Date, restaurantId: String) {
        self.id = id
        self.quantity = quantity
        self.date = date
        self.restaurantId = restaurantId
    }
    
    init(record: CKRecord) {
        self.record = record
        self.id = record[keys.id] as? String ?? ""
        self.quantity = record[keys.quantity] as? Int ?? 0
        self.date = record[keys.date] as? Date ?? Date()
        self.restaurantId = record[keys.restaurantId] as? String ?? ""
    }
    
    init() {
        self.quantity = 2000
        self.date = Date()
        self.restaurantId = ""
    }
    
    func getCKRecord() -> CKRecord {
        let record = self.record ?? CKRecord(recordType: keys.type)
        record[keys.id] = self.id
        record[keys.quantity] = self.quantity
        record[keys.date] = self.date
        record[keys.restaurantId] = self.restaurantId
        return record
    }
}
