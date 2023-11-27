//
//  Sale.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import Foundation
import CloudKit

struct Sale: Identifiable, Equatable {
    private let keys: SalesKeys = SalesKeys()
    
    var id: String = UUID().uuidString
    var date: Date = Date()
    var restaurantId: String
    var rtonos: Double
    var vequipo: Double
    var carmenTRJTA: Double
    var depo: Double
    var dscan: Double
    var doordash: Double
    var online: Double
    var grubhub: Double
    var tacobar: Double
    var vequipoCalculated: Double { carmenTRJTA + depo }
    var rtonosCalculated: Double {
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
            _record[keys.rtonos] = rtonos
            _record[keys.vequipo] = vequipo
            _record[keys.carmenTRJTA] = carmenTRJTA
            _record[keys.depo] = depo
            _record[keys.dscan] = dscan
            _record[keys.doordash] = doordash
            _record[keys.online] = online
            _record[keys.grubhub] = grubhub
            _record[keys.tacobar] = tacobar
            return _record
        }
//        set(newRecord) {
//            date = record[keys.date] ?? Date()
//            restaurantId = record[keys.restaurantId] ?? ""
//            carmenTRJTA = record[keys.carmenTRJTA] ?? 0.0
//            depo = record[keys.depo] ?? 0.0
//            dscan = record[keys.dscan] ?? 0.0
//            doordash = record[keys.doordash] ?? 0.0
//            online = record[keys.online] ?? 0.0
//            grubhub = record[keys.grubhub] ?? 0.0
//            tacobar = record[keys.tacobar] ?? 0.0
//            _record = newRecord
//        }
    }
    
    init(record: CKRecord) {
        self.date = record[keys.date] ?? Date()
        self.restaurantId = record[keys.restaurantId] ?? ""
        self.rtonos = record[keys.rtonos] ?? 0.0
        self.vequipo = record[keys.vequipo] ?? 0.0
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
        self.rtonos = 0.0
        self.vequipo = 0.0
        self.carmenTRJTA = 0.0
        self.depo = 0.0
        self.dscan = 0.0
        self.doordash = 0.0
        self.online = 0.0
        self.grubhub = 0.0
        self.tacobar = 0.0
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(date: Date, restaurantId: String, rtonos: Double, vequipo: Double, carmenTRJTA: Double, depo: Double, dscan: Double, doordash: Double, online: Double, grubhub: Double, tacobar: Double) {
        self.date = date
        self.restaurantId = restaurantId
        self.rtonos = rtonos
        self.vequipo = vequipo
        self.carmenTRJTA = carmenTRJTA
        self.depo = depo
        self.dscan = dscan
        self.doordash = doordash
        self.online =  online
        self.grubhub = grubhub
        self.tacobar = tacobar
        self._record = CKRecord(recordType: keys.type)
    }
    
    static func ==(lhs: Sale, rhs: Sale) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.restaurantId == rhs.restaurantId &&
        lhs.rtonos == rhs.rtonos &&
        lhs.vequipo == rhs.vequipo &&
        lhs.carmenTRJTA == rhs.carmenTRJTA &&
        lhs.depo == rhs.depo &&
        lhs.dscan == rhs.dscan &&
        lhs.doordash == rhs.doordash &&
        lhs.online == rhs.online &&
        lhs.grubhub == rhs.grubhub &&
        lhs.tacobar == rhs.tacobar
    }
}
