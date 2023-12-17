//
//  BeneficiarySpendingViewModel.swift
//  Aline
//
//  Created by Leonardo on 07/12/23.
//

import CloudKit
import SwiftUI

class BeneficiarySpendingViewModel: PublicCloud {
    private let keys: BeneficiarySpendingKeys = BeneficiarySpendingKeys()
    
    func fetch(for restaurantId: String, completion: @escaping ([BeneficiarySpending]?) -> Void) {
        var spendings: [BeneficiarySpending] = []
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            spendings += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return BeneficiarySpending(record: record)
            }
            fetchNextPage(cursor: data.queryCursor)
        }
        
        func fetchNextPage(cursor: CKQueryOperation.Cursor?) {
            guard let cursor = cursor else { completion(spendings); return }
            self.dataBase.fetch(withCursor: cursor) { result in
                guard case .success(let data) = result else { completion(.none); return }
                spendings += data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { return nil }
                    return BeneficiarySpending(record: record)
                }
                fetchNextPage(cursor: data.queryCursor)
            }
        }
    }
}
