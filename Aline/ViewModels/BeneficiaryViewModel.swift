//
//  BeneficiaryViewModel.swift
//  Aline
//
//  Created by Leonardo on 28/09/23.
//

import Foundation
import CloudKit

class BeneficiaryViewModel: PublicCloud {
    private let keys: BeneficiaryKeys = BeneficiaryKeys()
    
    func fetch(for restaurantId: String, completion: @escaping ([Beneficiary]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: keys.name, ascending: true)]
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let spendingType: [Beneficiary] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Beneficiary(record: record)
            }
            completion(spendingType)
        }
    }
}
