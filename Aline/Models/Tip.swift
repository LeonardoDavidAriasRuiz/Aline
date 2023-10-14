//
//  Tip.swift
//  Aline
//
//  Created by Leonardo on 21/09/23.
//

import Foundation
import CloudKit

struct Tip: Identifiable, Equatable {
    private let keys: TipKeys = TipKeys()
    
    var id: String = UUID().uuidString
    var date: Date
    var employeeId: String
    var quantity: Double
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.date] = date
        _record[keys.employeeId] = employeeId
        _record[keys.quantity] = quantity
        return _record
    }
    
    init() {
        self.date = Date()
        self.employeeId = ""
        self.quantity = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.date = record[keys.date] ?? Date()
        self.employeeId = record[keys.employeeId] ?? ""
        self.quantity = record[keys.quantity] ?? 0.0
        self._record = record
    }
    
    static func ==(lhs: Tip, rhs: Tip) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.employeeId == rhs.employeeId &&
        lhs.quantity == rhs.quantity
    }
}
