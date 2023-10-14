//
//  TipViewModel.swift
//  Aline
//
//  Created by Leonardo on 21/09/23.
//

import CloudKit
import SwiftUI

class TipViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let keys: TipKeys = TipKeys()
    
    func save(_ tip: Tip, completion: @escaping (Bool) -> Void) {
        dataBase.save(tip.record) { record, _ in
            completion(record != nil)
        }
    }
    
    func fetchTips(for employeeId: String, from fromDate: Date, to toDate: Date, completion: @escaping ([Tip]?) -> Void) {
        let predicates = [
            NSPredicate(format: "\(keys.employeeId) == %@", employeeId),
            NSPredicate(format: "\(keys.date) >= %@", fromDate as NSDate),
            NSPredicate(format: "\(keys.date) <= %@", toDate as NSDate)
        ]
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let employees: [Tip] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Tip(record: record)
            }
            completion(employees)
        }
    }
    
    func fetchTip(for employee: Employee, date: Date, completion: @escaping (Tip?) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        let predicates = [
            NSPredicate(format: "\(keys.employeeId) == %@", employee.id),
            NSPredicate(format: "\(keys.date) >= %@", startOfDay as NSDate),
            NSPredicate(format: "\(keys.date) <= %@", endOfDay as NSDate)
        ]
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result,
                  case .success(let record) = data.matchResults.first?.1 else { completion(.none); return }
            completion(Tip(record: record))
        }
    }
    
    func delete(_ tip: Tip, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: tip.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
