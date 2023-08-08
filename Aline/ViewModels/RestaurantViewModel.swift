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
    
    @Published  var restaurant: Restaurant = Restaurant()
    @Published  var currentRestaurantId: String = ""
    @Published public var adminRestaurants: [Restaurant] = []
    @Published public var emploRestaurants: [Restaurant] = []
    @Published  var dataNotObtained: Bool = false
    
    func save(_ restaurant: Restaurant, isNew: Bool) {
        let record = isNew ? CKRecord(recordType: restaurantKeys.type) : restaurant.record
        record[restaurantKeys.id] = restaurant.id
        record[restaurantKeys.name] = restaurant.name
        record[restaurantKeys.email] = restaurant.email
        record[restaurantKeys.adminUsersIds] = restaurant.adminUsersIds
        record[restaurantKeys.emploUsersIds] = restaurant.emploUsersIds
        saveRestaurant(record)
    }
    
    func fetchRestaurant(with id: String, completion: @escaping (Result<Restaurant, Error>) -> Void) {
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) == %@", id)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    completion(.success(Restaurant(record: record)))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        addQueryOperation(queryOperation)
    }
    
    func fetchRestaurants(for restaurantsList: [String], completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        var restaurants: [Restaurant] = []
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) IN %@", restaurantsList)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    restaurants.append(Restaurant(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(restaurants))
        }
        addQueryOperation(queryOperation)
        
    }
    
    func fetchRestaurantsDictionary(for restaurantsList: [String], completion: @escaping (Result<[String : Restaurant], Error>) -> Void) {
        var restaurants: [String : Restaurant] = [:]
        
        let predicate = NSPredicate(format: "\(restaurantKeys.id) IN %@", restaurantsList)
        let query = CKQuery(recordType: restaurantKeys.type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    let restaurant: Restaurant = Restaurant(record: record)
                    restaurants[restaurant.id] = restaurant
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { result in
            completion(.success(restaurants))
        }
        addQueryOperation(queryOperation)
        
    }
    
    func setCurrentRestaurant(_ restaurant: Restaurant) {
        DispatchQueue.main.async {
            self.restaurant = restaurant
        }
    }
    
    private func saveRestaurant(_ record: CKRecord) {
        dataBase.save(record) { _, error in
            guard let _ = error else { return }
        }
    }
    
    private func addQueryOperation(_ queryOperation: CKQueryOperation) {
        dataBase.add(queryOperation)
    }
    
    func getRestaurants(adminRestaurantsIds: [String], emploRestaurantsIds: [String]) {
        fetchRestaurants(for: adminRestaurantsIds) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let restaurants): self.adminRestaurants = restaurants
                    case .failure: self.dataNotObtained = true
                }
            }
            self.fetchRestaurants(for: emploRestaurantsIds) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let restaurants):
                            self.emploRestaurants.append(contentsOf: restaurants)
                            guard let fistRestaurant = self.adminRestaurants.first else { return }
                            self.currentRestaurantId = fistRestaurant.id
                            self.setCurrentRestaurant(fistRestaurant)
                        case .failure: self.dataNotObtained = true
                    }
                }
            }
        }
    }
}

