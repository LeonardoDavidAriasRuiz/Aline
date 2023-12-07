//
//  CheckViewModel.swift
//  Aline
//
//  Created by Leonardo on 27/11/23.
//

import CloudKit
import SwiftUI

class CheckViewModel: PublicCloud {
    private let keys: CheckKeys = CheckKeys()
    
    func fetch(restaurantId: String, completion: @escaping ([Check]?) -> Void) {
        var checks: [Check] = []
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(nil); return }
            checks += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(nil); return nil }
                return Check(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(checks); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(nil); return }
                checks += data.matchResults.compactMap {
                    guard case .success(let record) = $0.1 else { return nil }
                    return Check(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
    
    func fetch(restaurantId: String, month: Date, completion: @escaping ([Check]?) -> Void) {
        var checks: [Check] = []
        let predicates = [
            NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(keys.date) >= %@", month.firstDayOfMonth as NSDate),
            NSPredicate(format: "\(keys.date) <= %@", month.lastDayOfMonth as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(nil); return }
            checks += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(nil); return nil }
                return Check(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(checks); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(nil); return }
                checks += data.matchResults.compactMap {
                    guard case .success(let record) = $0.1 else { return nil }
                    return Check(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
}
