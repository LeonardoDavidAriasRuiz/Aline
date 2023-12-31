//
//  TipViewModel.swift
//  Aline
//
//  Created by Leonardo on 21/09/23.
//

import CloudKit
import SwiftUI

class TipViewModel: PublicCloud {
    private let keys: TipKeys = TipKeys()
    
    func fetchTips(employees: [Employee], date: Date, list: @escaping ([Tip]?) -> Void) {
        var employees = employees
        guard let employee = employees.popLast() else { list(.none); return }
        var tips: [Tip] = []
        
        fetchNextPage(employee: employee)
        
        func fetchNextPage(employee: Employee) {
            let predicates = [
                NSPredicate(format: "\(keys.employeeId) == %@", employee.id),
                NSPredicate(format: "\(keys.date) >= %@", date.firstDayOfMonth as NSDate),
                NSPredicate(format: "\(keys.date) <= %@", date.lastDayOfMonth as NSDate)
            ]
            
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
            
            dataBase.fetch(withQuery: query) { result in
                guard case .success(let data) = result else { list(.none); return }
                tips += data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { list(.none); return nil }
                    return Tip(record: record)
                }
                if let employee = employees.popLast() {
                    fetchNextPage(employee: employee)
                } else {
                    list(tips)
                }
            }
        }
    }
    
    func fetchTips(employees: [Employee], list: @escaping ([Tip]?) -> Void) {
        var employees = employees
        guard let employee = employees.popLast() else { list(.none); return }
        var tips: [Tip] = []
        
        fetchNextPage(employee: employee)
        
        func fetchNextPage(employee: Employee) {
            let predicate = NSPredicate(format: "\(keys.employeeId) == %@", employee.id)
            let query = CKQuery(recordType: keys.type, predicate: predicate)
            
            dataBase.fetch(withQuery: query) { result in
                guard case .success(let data) = result else { list(.none); return }
                tips += data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { list(.none); return nil }
                    return Tip(record: record)
                }
                if let employee = employees.popLast() {
                    fetchNextPage(employee: employee)
                } else {
                    list(tips)
                }
            }
        }
    }
    
    func fetchTips(employee: Employee, from fromDate: Date, to toDate: Date, completion: @escaping ([Tip]?) -> Void) {
        let predicates = [
            NSPredicate(format: "\(keys.employeeId) == %@", employee.id),
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
    
    func fetchTotalFortnights(restaurantId: String, date: Date, completion: @escaping ([FortnightTotalTips]?) -> Void) {
        let fnKeys = FortnightTotalTipsKeys()
        let predicates = [
            NSPredicate(format: "\(fnKeys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(fnKeys.date) >= %@", date.firstDayOfMonth as NSDate),
            NSPredicate(format: "\(fnKeys.date) <= %@", date.lastDayOfMonth as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: fnKeys.type, predicate: compoundPredicate)
        var totals: [FortnightTotalTips] = []
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            totals += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return FortnightTotalTips(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(totals); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(.none); return }
                totals += data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { return nil }
                    return FortnightTotalTips(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
}
