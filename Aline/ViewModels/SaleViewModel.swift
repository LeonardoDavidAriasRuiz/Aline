//
//  SaleViewModel.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import CloudKit
import SwiftUI

class SaleViewModel: PublicCloud {
    private let keys: SalesKeys = SalesKeys()
    
    func fetchSales(for restaurantId: String, from: Date, to: Date, completion: @escaping ([Sale]?) -> Void) {
        var sales: [Sale] = []
        let predicates = [
            NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(keys.date) >= %@", from as NSDate),
            NSPredicate(format: "\(keys.date) <= %@", to as NSDate)
        ]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let query = CKQuery(recordType: keys.type, predicate: compoundPredicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            sales += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return Sale(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(sales); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(.none); return }
                sales += data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { return nil }
                    return Sale(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
    
    func delete(_ sales: [Sale]) {
        for sale in sales {
            dataBase.delete(withRecordID: sale.record.recordID) { (recordID, _) in
                
            }
        }
    }
}

