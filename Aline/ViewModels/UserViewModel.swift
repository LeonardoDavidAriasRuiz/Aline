//
//  UserViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI
import CloudKit

class UserViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let ckContainer: CKContainer = CKContainer.default()
    private let userKeys: UserKeys = UserKeys()
    
    @Published var user: User = User()
    
    func checkiCloudUser(completion: @escaping (Bool) -> Void) {
        ckContainer.accountStatus { status, _ in
            completion(status == .available)
        }
    }
    
    func getUserId(completion: @escaping (String?) -> Void) {
        ckContainer.fetchUserRecordID { id, _ in
            completion(id?.recordName)
        }
    }
    
    func checkIfLoggedIn(completion: @escaping (Bool) -> Void) {
        if user.id.isNotEmpty {
            let predicate = NSPredicate(format: "\(userKeys.id) == %@", self.user.id)
            let query = CKQuery(recordType: userKeys.type, predicate: predicate)
            let queryOperation = CKQueryOperation(query: query)
            
            queryOperation.recordMatchedBlock = { (_, result) in
                switch result {
                    case .failure: completion(false)
                    case .success(let record):
                        DispatchQueue.main.sync {
                            self.user = User(record: record)
                        }
                        completion(true)
                }
            }
            dataBase.add(queryOperation)
        } else {
            completion(false)
        }
    }
    
    func save() {
        let record: CKRecord = self.user.record
        record[userKeys.id] = self.user.id
        record[userKeys.name] = self.user.name
        record[userKeys.email] = self.user.email
        record[userKeys.adminRestaurantsIds] = self.user.adminIds
        record[userKeys.emploRestaurantsIds] = self.user.emploIds
        
        dataBase.save(record) { (record, error) in
            guard let record = record else { return }
            DispatchQueue.main.async {
                self.user = User(record: record)
            }
        }
    }
}

