//
//  RestaurantViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import Foundation
import CloudKit


class RestaurantViewModel: PublicCloud {
    private let keys: RestaurantKeys = RestaurantKeys()
    
    func save(_ restaurant: Restaurant, isNew: Bool) {
        let record = isNew ? CKRecord(recordType: keys.type) : restaurant.record
        record[keys.id] = restaurant.id
        record[keys.name] = restaurant.name
        record[keys.email] = restaurant.email
        record[keys.adminUsersIds] = restaurant.adminUsersIds
        record[keys.emploUsersIds] = restaurant.emploUsersIds
        
        dataBase.save(record) { _, error in
            guard let _ = error else { return }
        }
    }
    
    func fetchRestaurant(with id: String, completion: @escaping (Restaurant?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.id) == %@", id)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result,
                  case .success(let record) = data.matchResults.first?.1 else { completion(.none); return }
            completion(Restaurant(record: record))
        }
    }
    
    
    func fetchRestaurants(for restaurantsList: [String], completion: @escaping ([Restaurant]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.id) IN %@", restaurantsList)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let restaurants: [Restaurant] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Restaurant(record: record)
            }
            completion(restaurants)
        }
    }

    
    func fetchRestaurants(adminIds: [String], emploIds: [String], completion: @escaping (_ admin: [Restaurant]?, _ emplo: [Restaurant]?) -> Void) {
        var adminRts: [Restaurant]?
        var emploRts: [Restaurant]?
        
        let predicate = NSPredicate(format: "\(keys.id) IN %@", adminIds)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(adminRts, emploRts); return }
            adminRts = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(adminRts, emploRts); return nil }
                return Restaurant(record: record)
            }
            
            let predicate = NSPredicate(format: "\(self.keys.id) IN %@", emploIds)
            let query = CKQuery(recordType: self.keys.type, predicate: predicate)
            
            self.dataBase.fetch(withQuery: query) { result in
                guard case .success(let data) = result else { completion(adminRts, emploRts); return }
                emploRts = data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else {completion(adminRts, emploRts); return nil }
                    return Restaurant(record: record)
                }
                completion(adminRts, emploRts)
            }
        }
    }
}

