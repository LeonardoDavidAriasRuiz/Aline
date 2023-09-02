//
//  DepositViewModel.swift
//  Aline
//
//  Created by Leonardo on 12/07/23.
//

import Foundation
import CloudKit

class DepositViewModel: ObservableObject {
    private let publicCloudDB = CKContainer.default().publicCloudDatabase
    private let depositKeys: DepositKeys = DepositKeys()
    
    func save(_ deposit: Deposit, completion: @escaping (Deposit?) -> Void) {
        guard deposit.restaurantId.isNotEmpty else { return }
        publicCloudDB.save(deposit.getCKRecord()) { record, error in
            if let record = record {
                completion(Deposit(record: record))
            } else {
                completion(.none)
            }
        }
    }
    
    func fetchDeposits(for restaurantId: String, completion: @escaping ([Deposit]?) -> Void) {
        var deposits: [Deposit] = []
        let predicate = NSPredicate(format: "\(depositKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: depositKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: depositKeys.date, ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    deposits.append(Deposit(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(deposits)
        }
        publicCloudDB.add(queryOperation)
    }
    
    func delete(deposit: Deposit, completion: @escaping (Bool) -> Void) {
        publicCloudDB.delete(withRecordID: deposit.getCKRecord().recordID) { recordID, _ in
            completion(recordID != nil)
        }
    }
}
