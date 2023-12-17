//
//  Beneficiary.swift
//  Aline
//
//  Created by Leonardo on 28/09/23.
//

import Foundation
import CloudKit

struct Beneficiary: Equatable, Identifiable, Hashable {
    private let keys: BeneficiaryKeys = BeneficiaryKeys()
    
    var id: String
    var name: String
    var lastName: String
    var percentage: Double
    var status: Double
    var startEndDates: [Date]
    var employeesIds: [String]
    var restaurantId: String
    var spendings: [BeneficiarySpendings] = []
    var resumes: [BeneficiaryResume] = []
    
    private var _record: CKRecord
    
    var fullName: String {
        "\(lastName) \(name)"
    }
    var record: CKRecord {
        get {
            _record[keys.id] = id
            _record[keys.name] = name
            _record[keys.lastName] = lastName
            _record[keys.percentage] = percentage
            _record[keys.status] = status
            _record[keys.startEndDates] = startEndDates
            _record[keys.employeesIds] = employeesIds
            _record[keys.restaurantId] = restaurantId
            return _record
        }
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.lastName = ""
        self.percentage = 1
        self.status = 0
        self.startEndDates = [Date()]
        self.employeesIds = [""]
        self.restaurantId = ""
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self.id = record[keys.id] ?? ""
        self.name = record[keys.name] ?? ""
        self.lastName = record[keys.lastName] ?? ""
        self.percentage = record[keys.percentage] ?? 0
        self.status = record[keys.status] ?? 0
        self.startEndDates = record[keys.startEndDates] ?? [Date()]
        self.employeesIds = record[keys.employeesIds] ?? [""]
        self.restaurantId = record[keys.restaurantId] ?? ""
        self._record = record
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Beneficiary, rhs: Beneficiary) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.lastName == rhs.lastName &&
        lhs.percentage == rhs.percentage &&
        lhs.status == rhs.status &&
        lhs.startEndDates == rhs.startEndDates &&
        lhs.employeesIds == rhs.employeesIds &&
        lhs.restaurantId == rhs.restaurantId &&
        lhs.spendings == rhs.spendings &&
        lhs.resumes == rhs.resumes
    }
}
