//
//  AccountantViewModel.swift
//  Aline
//
//  Created by Leonardo on 25/09/23.
//

import Foundation
import CloudKit

struct AccountantViewModel {
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let keys: AccountantKeys = AccountantKeys()
    
    func save(_ accountant: Accountant, completion: @escaping (Bool) -> Void) {
        dataBase.save(accountant.record) { record, _ in
            completion(record != nil)
        }
    }
    
    func fetch(for restaurantId: String, completion: @escaping ([Accountant]?) -> Void) {
        var accountants: [Accountant] = []
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            accountants += data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else { completion(.none); return nil }
                return Accountant(record: record)
            }
            completion(accountants)
        }
    }
    
    func delete(_ accountant: Employee, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: accountant.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
