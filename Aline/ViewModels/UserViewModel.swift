//
//  UserViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI
import CloudKit

enum LoginStatus {
    case iCloudOff
    case iCLoudOn
    case loggedIn
    case signedIn
}

class UserViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let ckContainer: CKContainer = CKContainer.default()
    private let userKeys: UserKeys = UserKeys()
    
    @Published var loginStatus: LoginStatus = .iCloudOff
    @Published var user: User = User()
    
     init() {
        checkiCloudUser()
    }
    
    private func checkiCloudUser() {
        ckContainer.accountStatus { status, _ in
            let isAvailable = (status == .available)
            self.loginStatus = isAvailable ? .iCLoudOn : .iCloudOff
            isAvailable ? self.getUserId() : nil
        }
    }
    
    private func getUserId() {
        ckContainer.fetchUserRecordID { (id, error) in
            guard let id = id, error == nil else { return }
            DispatchQueue.main.async {
                self.user.id = id.recordName
                self.checkIfLoggedIn()
            }
        }
    }
    
     func save() {
        let record: CKRecord = self.user.record
        record[userKeys.id] = self.user.id
        record[userKeys.name] = self.user.name
        record[userKeys.email] = self.user.email
        record[userKeys.adminRestaurantsIds] = self.user.adminRestaurantsIds
        record[userKeys.emploRestaurantsIds] = self.user.emploRestaurantsIds
        self.saveUser(record)
    }
    
    private func checkIfLoggedIn() {
        guard self.user.id.isNotEmpty else { return }
        let predicate = NSPredicate(format: "\(userKeys.id) == %@", self.user.id)
        let query = CKQuery(recordType: userKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            guard case .success(let record) = result else { return }
            DispatchQueue.main.sync {
                self.user = User(record: record)
                self.loginStatus = .loggedIn
            }
        }
        addQueryOperation(queryOperation)
    }
    
    private func addQueryOperation(_ queryOperation: CKQueryOperation) {
        dataBase.add(queryOperation)
    }
    
    private func saveUser(_ record: CKRecord) {
        dataBase.save(record) { (record, error) in
            guard let record = record else { return }
            DispatchQueue.main.async {
                self.user = User(record: record)
            }
        }
    }
    
}

