//
//  Sale.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import Foundation
import CloudKit

struct Sale {
    private let keys: SalesKeys = SalesKeys()
    var date: Date = Date()
    var restaurantId: String = ""
    var carmenTRJTA: Double = 0.0
    var depo: Double = 0.0
    var dscan: Double = 0.0
    var doordash: Double = 0.0
    var online: Double = 0.0
    var grubhub: Double = 0.0
    var tacobar: Double = 0.0
    var vequipo: Double { carmenTRJTA + depo }
    var rtonos: Double {
        carmenTRJTA +
        depo +
        dscan +
        doordash +
        online +
        grubhub +
        tacobar
    }
    
    private var _record: CKRecord
    
    var record: CKRecord {
        get {
            _record[keys.date] = date
            _record[keys.restaurantId] = restaurantId
            _record[keys.carmenTRJTA] = carmenTRJTA
            _record[keys.depo] = depo
            _record[keys.dscan] = dscan
            _record[keys.doordash] = doordash
            _record[keys.online] = online
            _record[keys.grubhub] = grubhub
            _record[keys.tacobar] = tacobar
            return _record
        }
        set(newRecord) {
            date = record[keys.date] ?? Date()
            restaurantId = record[keys.restaurantId] ?? ""
            carmenTRJTA = record[keys.carmenTRJTA] ?? 0.0
            depo = record[keys.depo] ?? 0.0
            dscan = record[keys.dscan] ?? 0.0
            doordash = record[keys.doordash] ?? 0.0
            online = record[keys.online] ?? 0.0
            grubhub = record[keys.grubhub] ?? 0.0
            tacobar = record[keys.tacobar] ?? 0.0
            _record = newRecord
        }
    }
    
    init(record: CKRecord) {
        self.date = record[keys.date] ?? Date()
        self.restaurantId = record[keys.restaurantId] ?? ""
        self.carmenTRJTA = record[keys.carmenTRJTA] ?? 0.0
        self.depo = record[keys.depo] ?? 0.0
        self.dscan = record[keys.dscan] ?? 0.0
        self.doordash = record[keys.doordash] ?? 0.0
        self.online = record[keys.online] ?? 0.0
        self.grubhub = record[keys.grubhub] ?? 0.0
        self.tacobar = record[keys.tacobar] ?? 0.0
        self._record = record
    }
    
    init() {
        self.date = Date()
        self.restaurantId = ""
        self.carmenTRJTA = 0.0
        self.depo = 0.0
        self.dscan = 0.0
        self.doordash = 0.0
        self.online = 0.0
        self.grubhub = 0.0
        self.tacobar = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
}
