//
//  SpendingViewModel.swift
//  Aline
//
//  Created by Leonardo on 25/09/23.
//

import CloudKit
import SwiftUI

class SpendingViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let spendingTypeKeys: SpendingTypeKeys = SpendingTypeKeys()
    private let spendingKeys: SpendingKeys = SpendingKeys()
    
    func saveSpending(_ spending: Spending, completion: @escaping (Bool) -> Void) {
        dataBase.save(spending.record) { record, _ in
            completion(record != nil)
        }
    }
    
    func saveType(_ type: SpendingType, completion: @escaping (Bool) -> Void) {
        dataBase.save(type.record) { record, _ in
            completion(record != nil)
        }
    }
    
    func deleteSpending(_ spending: Spending, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: spending.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
    
    func deleteType(_ type: SpendingType, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: type.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
    
    func fetchSpending(for restaurantId: String, date: Date, completion: @escaping ([Spending]?) -> Void) {
        let predicates = [
            NSPredicate(format: "\(spendingKeys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(spendingKeys.date) >= %@", date.firstDayOfMonth as NSDate),
            NSPredicate(format: "\(spendingKeys.date) <= %@", date.lastDayOfMonth as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: spendingKeys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { print("d"); completion(.none); return }
            let spendings: [Spending] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {print("e"); completion(.none); return nil }
                return Spending(record: record)
            }
            completion(spendings)
        }
    }
    
    func fetchSpendings(for restaurantId: String, date: Date, completion: @escaping ([Spending]?) -> Void) {
        var spendings: [Spending] = []
        let predicates = [
            NSPredicate(format: "\(spendingKeys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(spendingKeys.date) >= %@", date.firstDayOfMonth as NSDate),
            NSPredicate(format: "\(spendingKeys.date) <= %@", date.lastDayOfMonth as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: spendingKeys.type, predicate: compoundPredicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = CKQueryOperation.maximumResults
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            spendings += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return Spending(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            if let cursor = cursor {
                self.dataBase.fetch(withCursor: cursor) { result in
                    guard case .success(let data) = result else { completion(.none); return }
                    spendings += data.matchResults.compactMap { _, result in
                        guard case .success(let record) = result else { return nil }
                        return Spending(record: record)
                    }
                    fetchNextPage(cursor: data.queryCursor)
                }
            } else {
                completion(spendings)
            }
        }
    }
    
    func fetchTypes(for restaurantId: String, completion: @escaping ([SpendingType]?) -> Void) {
        let predicate = NSPredicate(format: "\(spendingTypeKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: spendingTypeKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: spendingTypeKeys.name, ascending: true)]
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let types: [SpendingType] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return SpendingType(record: record)
            }
            completion(types)
        }
    }
}
