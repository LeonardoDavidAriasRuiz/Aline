//
//  Check.swift
//  Aline
//
//  Created by Leonardo on 23/11/23.
//

import Foundation
import CloudKit

struct Check: Hashable, Equatable, Identifiable {
    private let keys: CheckKeys = CheckKeys()
    
    let id: String
    var cash: Double
    var direct: Double
    var employeeId: String
    var restaurantId: String
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.cash] = cash
        _record[keys.direct] = direct
        _record[keys.employeeId] = employeeId
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.cash = 0
        self.direct = 0
        self.restaurantId = ""
        self.employeeId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.cash = record[keys.cash] ?? 0
        self.direct = record[keys.direct] ?? 0
        self.employeeId = record[keys.employeeId] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Check, rhs: Check) -> Bool {
        lhs.id == rhs.id &&
        lhs.cash == rhs.cash &&
        lhs.direct == rhs.direct &&
        lhs.employeeId == rhs.employeeId &&
        lhs.restaurantId == rhs.restaurantId
    }
}

