//
//  DepositViewModel.swift
//  Aline
//
//  Created by Leonardo on 12/07/23.
//

import Foundation
import CloudKit

class DepositViewModel: ObservableObject {
    private let depositKeys: DepositKeys = DepositKeys()
    
    @Published  var deposits: [Deposit] = []
    
    private let publicCloudDB = CKContainer.default().publicCloudDatabase
    
     func fetchDeposits(for restaurantLink: String, completion: @escaping ([Deposit]) -> Void) {
        var deposits: [Deposit] = []
        let predicate = NSPredicate(format: "\(depositKeys.restaurantId) == %@", restaurantLink)
        let query = CKQuery(recordType: depositKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: depositKeys.date, ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        
        self.deposits = []
        queryOperation.recordMatchedBlock = { (_, result) in
            guard let deposit = try? Deposit(record: result.get()) else { return }
            deposits.append(deposit)
        }
        
        queryOperation.queryResultBlock = { result in
            completion(deposits)
        }
        self.addQueryOperation(queryOperation)
    }
    
     func delete(deposit: Deposit) {
        self.publicCloudDB.delete(withRecordID: deposit.getCKRecord().recordID) { recordID, error in
        }
    }
    
     func save(_ deposit: Deposit) {
        guard deposit.restaurantLink.isNotEmpty else { return }
        self.publicCloudDB.save(deposit.getCKRecord(), completionHandler: {_,_ in })
    }
    
    private func addQueryOperation(_ queryOperation: CKQueryOperation) {
        self.publicCloudDB.add(queryOperation)
    }
}

extension Collection {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
