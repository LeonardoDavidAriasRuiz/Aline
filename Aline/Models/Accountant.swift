//
//  Accountant.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation
import CloudKit

struct Accountant {
    private let keys: AccountantKeys = AccountantKeys()
    var name: String
    var email: String
    var message: String
    var restaurantId: String
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.name] = name
        _record[keys.email] = email
        _record[keys.message] = message
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.name = ""
        self.email = ""
        self.message = "Mensaje predeterminado."
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.name = record[keys.name] ?? ""
        self.email = record[keys.email] ?? ""
        self.message = record[keys.message] ?? ""
        self.restaurantId = record[keys.restaurantId] ?? ""
        self._record = record
    }
}
