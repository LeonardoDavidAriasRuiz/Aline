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
    
    func save(_ conection: Conection, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let record: CKRecord = CKRecord(recordType: conectionKeys.type)
        record[conectionKeys.id] = conection.id
        record[conectionKeys.email] = conection.email
        record[conectionKeys.isAdmin] = conection.isAdmin
        record[conectionKeys.restaurantId] = conection.restaurantId
        record[conectionKeys.restaurantName] = conection.restaurantName
        
        dataBase.save(record) { (record, error) in
            if let record = record {
                completion(.success(record))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func fetchConections(for userList: [String], completion: @escaping (Result<[User], Error>) -> Void) {
        var users: [User] = []
        
        let predicate = NSPredicate(format: "\(userKeys.id) IN %@", userList)
        let query = CKQuery(recordType: userKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    users.append(User(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(users))
        }
        dataBase.add(queryOperation)
    }
    
    func fetchReceivedConections(for email: String, completion: @escaping (Result<[Conection], Error>) -> Void) {
        var conections: [Conection] = []
        
        let predicate = NSPredicate(format: "\(conectionKeys.email) == %@", email)
        let query = CKQuery(recordType: conectionKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    conections.append(Conection(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(conections))
        }
        dataBase.add(queryOperation)
    }
    
    func fetchSentConections(in restaurantId: String, completion: @escaping (Result<[Conection], Error>) -> Void) {
        var conections: [Conection] = []
        
        let predicate = NSPredicate(format: "\(conectionKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: conectionKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    conections.append(Conection(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(conections))
        }
        dataBase.add(queryOperation)
    }
    
    func delete(_ conection: Conection, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.dataBase.delete(withRecordID: conection.record.recordID) { (_, error) in
            guard let error = error else {
                completion(.success(true))
                return
            }
            completion(.failure(error))
        }
    }
}
