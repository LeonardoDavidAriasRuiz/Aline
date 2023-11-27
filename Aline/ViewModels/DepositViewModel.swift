//
//  DepositViewModel.swift
//  Aline
//
//  Created by Leonardo on 12/07/23.
//

import Foundation
import CloudKit

class DepositViewModel: PublicCloud {
    private let keys: DepositKeys = DepositKeys()
    
    func fetch(restaurantId: String, year: Date, completion: @escaping ([Deposit]?) -> Void) {
        var deposits: [Deposit] = []
        let predicates = [
            NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(keys.date) >= %@", year.firstDayOfYear as NSDate),
            NSPredicate(format: "\(keys.date) <= %@", year.lastDayOfYear as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(nil); return }
            deposits += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(nil); return nil }
                return Deposit(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(deposits); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(nil); return }
                deposits += data.matchResults.compactMap {
                    guard case .success(let record) = $0.1 else { return nil }
                    return Deposit(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
}
