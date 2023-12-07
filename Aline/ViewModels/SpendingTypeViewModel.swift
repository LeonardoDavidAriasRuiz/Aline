//
//  SpendingViewModel.swift
//  Aline
//
//  Created by Leonardo on 25/09/23.
//

import CloudKit
import SwiftUI

class SpendingViewModel: PublicCloud {
    private let spendingTypeKeys: SpendingTypeKeys = SpendingTypeKeys()
    private let spendingKeys: SpendingKeys = SpendingKeys()
    
    func fetch(restaurantId: String, date: Date, completion: @escaping ([Spending]?) -> Void) {
        var spendings: [Spending] = []
        let predicates = [
            NSPredicate(format: "\(spendingKeys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(spendingKeys.date) >= %@", date.firstDayOfMonth as NSDate),
            NSPredicate(format: "\(spendingKeys.date) <= %@", date.lastDayOfMonth as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: spendingKeys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(nil); return }
            spendings += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(nil); return nil }
                return Spending(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(spendings); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(nil); return }
                spendings += data.matchResults.compactMap {
                    guard case .success(let record) = $0.1 else { return nil }
                    return Spending(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
    
    func fetchSpendings(for restaurantId: String, completion: @escaping ([Spending]?) -> Void) {
        var spendings: [Spending] = []
        let predicate = NSPredicate(format: "\(spendingKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: spendingKeys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            spendings += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return Spending(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(spendings); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(nil); return }
                spendings += data.matchResults.compactMap {
                    guard case .success(let record) = $0.1 else { return nil }
                    return Spending(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
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
