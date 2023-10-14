//
//  ConectionViewModel.swift
//  Aline
//
//  Created by Leonardo on 27/07/23.
//

import Foundation
import CloudKit

class ConectionViewModel: ObservableObject {
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let userKeys: UserKeys = UserKeys()
    private let conectionKeys: ConectionKeys = ConectionKeys()
    
    func save(_ conection: Conection, completion: @escaping (Bool) -> Void) {
        let record: CKRecord = CKRecord(recordType: conectionKeys.type)
        record[conectionKeys.id] = conection.id
        record[conectionKeys.email] = conection.email
        record[conectionKeys.isAdmin] = conection.isAdmin
        record[conectionKeys.restaurantId] = conection.restaurantId
        record[conectionKeys.restaurantName] = conection.restaurantName
        
        dataBase.save(record) { (record, _) in
            completion(record != nil)
        }
    }
    
    func fetchConections(for userList: [String], completion: @escaping ([User]?) -> Void) {
        let predicate = NSPredicate(format: "\(userKeys.id) IN %@", userList)
        let query = CKQuery(recordType: userKeys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let users: [User] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return User(record: record)
            }
            completion(users)
        }
    }
    
    func fetchReceivedConections(for email: String, completion: @escaping ([Conection]?) -> Void) {
        let predicate = NSPredicate(format: "\(conectionKeys.email) == %@", email)
        let query = CKQuery(recordType: conectionKeys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let conections: [Conection] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Conection(record: record)
            }
            completion(conections)
        }
    }
    
    func fetchSentConections(in restaurantId: String, completion: @escaping ([Conection]?) -> Void) {
        let predicate = NSPredicate(format: "\(conectionKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: conectionKeys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let conections: [Conection] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Conection(record: record)
            }
            completion(conections)
        }
    }
    
    func delete(_ conection: Conection, completion: @escaping (Bool) -> Void) {
        self.dataBase.delete(withRecordID: conection.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
