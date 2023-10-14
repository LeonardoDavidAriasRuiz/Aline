//
//  TipsReview.swift
//  Aline
//
//  Created by Leonardo on 21/09/23.
//

import SwiftUI
import CloudKit

struct TipsReview: Identifiable, Equatable {
    private let keys: TipReviewKeys = TipReviewKeys()
    
    var id: String = UUID().uuidString
    var restaurantId: String
    var from: Date
    var to: Date
    var employeesIds: [String]
    var quantityForEach: Double
    var notes: String
    
    private var _record: CKRecord
    
    var record: CKRecord {
        get {
            _record[keys.restaurantId] = restaurantId
            _record[keys.from] = from
            _record[keys.to] = to
            _record[keys.employeesIds] = employeesIds
            _record[keys.quantityForEach] = quantityForEach
            _record[keys.notes] = notes
            return _record
        }
    }
    
    init() {
        self.restaurantId = ""
        self.from = Calendar.current.startOfDay(for: Date())
        if let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) {
            self.to = endOfDay
        } else {
            self.to = Date()
        }
        self.employeesIds = []
        self.quantityForEach = 0.0
        self.notes = "Tips del dia \(Date().shortDate)."
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.restaurantId = record[keys.restaurantId] ?? ""
        self.from = record[keys.from] ?? Date()
        self.to = record[keys.to] ?? Date()
        self.employeesIds = record[keys.employeesIds] ?? []
        self.quantityForEach = record[keys.quantityForEach] ?? 0.0
        self.notes = record[keys.notes] ?? ""
        self._record = record
    }
    
    static func ==(lhs: TipsReview, rhs: TipsReview) -> Bool {
        lhs.id == rhs.id &&
        lhs.restaurantId == rhs.restaurantId &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.employeesIds == rhs.employeesIds &&
        lhs.quantityForEach == rhs.quantityForEach &&
        lhs.notes == rhs.notes
    }
}
