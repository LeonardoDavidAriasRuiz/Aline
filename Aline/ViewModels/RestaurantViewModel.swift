//
//  RestaurantViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import Foundation
import CloudKit


class RestaurantViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let restaurantKeys = RestaurantKeys()
    
    func save(_ restaurant: Restaurant, isNew: Bool) {
        let record = isNew ? CKRecord(recordType: restaurantKeys.type) : restaurant.record
        record[restaurantKeys.id] = restaurant.id
        record[restaurantKeys.name] = restaurant.name
        record[restaurantKeys.email] = restaurant.email
        record[restaurantKeys.adminUsersIds] = restaurant.adminUsersIds
        record[restaurantKeys.emploUsersIds] = restaurant.emploUsersIds
        
        dataBase.save(record) { _, error in
            guard let _ = error else { return }
        }
    }
    
    func fetchRestaurant(with id: String, completion: @escaping (Restaurant?) -> Void) {
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) == %@", id)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    completion(Restaurant(record: record))
                case .failure:
                    completion(.none)
            }
        }
        dataBase.add(queryOperation)
    }
    
    func fetchRestaurants(for restaurantsList: [String], completion: @escaping ([Restaurant]?) -> Void) {
        var restaurants: [Restaurant] = []
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) IN %@", restaurantsList)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    restaurants.append(Restaurant(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(restaurants)
        }
        dataBase.add(queryOperation)
        
    }
    
    func fetchRestaurantsDictionary(for restaurantsList: [String], completion: @escaping ([String : Restaurant]?) -> Void) {
        var restaurants: [String : Restaurant] = [:]
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) IN %@", restaurantsList)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    let restaurant: Restaurant = Restaurant(record: record)
                    restaurants[restaurant.id] = restaurant
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(restaurants)
        }
        
        dataBase.add(queryOperation)
    }
    
    func getRestaurants(adminIds: [String], emploIds: [String], completion: @escaping (_ admin: [Restaurant]?, _ emplo: [Restaurant]?) -> Void) {
        var adminRts: [Restaurant]?
        var emploRts: [Restaurant]?
        fetchRestaurants(for: adminIds) { restaurants in
            adminRts = restaurants
            
            self.fetchRestaurants(for: emploIds) { restaurants in
                emploRts = restaurants
                completion(adminRts, emploRts)
            }
        }
    }
}

