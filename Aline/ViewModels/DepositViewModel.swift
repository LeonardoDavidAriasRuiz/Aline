//
//  DepositViewModel.swift
//  Aline
//
//  Created by Leonardo on 12/07/23.
//

import Foundation
import CloudKit

class DepositViewModel: ObservableObject {
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let depositKeys: DepositKeys = DepositKeys()
    
    func save(_ deposit: Deposit, completion: @escaping (Deposit?) -> Void) {
        guard deposit.restaurantId.isNotEmpty else { return }
        dataBase.save(deposit.getCKRecord()) { record, error in
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
        queryOperation.resultsLimit = CKQueryOperation.maximumResults
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    deposits.append(Deposit(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { result in
            switch result {
                case .success(let cursor):
                    if let cursor = cursor {
                        fetchLeftSales(cursor: cursor) { newDeposits in
                            if let newDeposits = newDeposits {
                                deposits.append(contentsOf: newDeposits)
                            }
                            completion(deposits)
                        }
                    } else {
                        completion(deposits)
                    }
                case .failure:
                    completion(.none)
            }
            
        }
        
        dataBase.add(queryOperation)
        
        func fetchLeftSales(cursor: CKQueryOperation.Cursor, completion2: @escaping ([Deposit]?) -> Void) {
            var newDeposits: [Deposit] = []
            
            let queryOperation = CKQueryOperation(cursor: cursor)
            
            queryOperation.recordMatchedBlock = { (_, result) in
                switch result {
                    case .success(let record):
                        newDeposits.append(Deposit(record: record))
                    case .failure:
                        completion2(.none)
                }
            }
            
            queryOperation.queryResultBlock = { result in
                switch result {
                    case .success(let cursor):
                        if let cursor = cursor {
                            fetchLeftSales(cursor: cursor) { returnedDeposits in
                                if let returnedDeposits = returnedDeposits {
                                    newDeposits.append(contentsOf: returnedDeposits)
                                }
                                completion2(newDeposits)
                            }
                        } else {
                            completion2(newDeposits)
                        }
                    case .failure:
                        completion2(.none)
                }
            }
            
            self.dataBase.add(queryOperation)
        }
    }
    
    func delete(deposit: Deposit, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: deposit.getCKRecord().recordID) { recordID, _ in
            completion(recordID != nil)
        }
    }
}
