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
    
    func fetchDeposits(for restaurantId: String, completion: @escaping (Result<[Deposit], Error>) -> Void) {
        var deposits: [Deposit] = []
        let predicate = NSPredicate(format: "\(depositKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: depositKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: depositKeys.date, ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    deposits.append(Deposit(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(deposits))
        }
        publicCloudDB.add(queryOperation)
    }
    
    func delete(deposit: Deposit, completion: @escaping (Result<Bool, Error>) -> Void) {
        publicCloudDB.delete(withRecordID: deposit.getCKRecord().recordID) { recordID, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func save(_ deposit: Deposit, completion: @escaping (Result<Deposit, Error>) -> Void) {
        guard deposit.restaurantId.isNotEmpty else { return }
        publicCloudDB.save(deposit.getCKRecord()) { record, error in
            if let record = record {
                completion(.success(Deposit(record: record)))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}

extension Collection {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
