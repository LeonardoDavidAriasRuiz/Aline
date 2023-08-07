//
//  CustomUserController.swift
//  Jalisco_Dashboard
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI
import CloudKit

enum LoginStatus {
    case loading
    case iCloudOff
    case iCLoudOn
    case loggedIn
    case signedIn
    case restaurantSelected
}

class UserController: ObservableObject {
    
    private let userKeys = User.Keys.self
    private let restaurantKeys = Restaurant.Keys.self
    
    private let linkAdminNoAllowed = "Vínculo Admin no permitido"
    
    // Published properties to track the user's iCloud account and authentication status, as well as other data
    @Published var loginStatus: LoginStatus = .loading
    
    @Published private var userId: String? = nil
    
    @Published var userRecord: CKRecord? = nil
    @Published var userModel: User = User()
    @Published var restaurants: [Restaurant] = []
    @Published var emploRestaurants: [Restaurant] = []
    @Published var adminRestaurants: [Restaurant] = []
    @Published var queriesDone: Bool = false
    @Published var currentRestaurantLink: String = ""
    @Published var currentRestaurantAdmin: Bool = false
    
    // Initializer that checks the user's iCloud account status, gets their CloudKit user ID, and checks if they are logged in
    init() {
        checkiCloudUser()
    }
    
    // Function to add a new user to the CloudKit database
    func addUser(user: User) {
        let newUser = CKRecord(recordType: userKeys.type.rawValue)
        newUser[userKeys.id.rawValue] = userId
        newUser[userKeys.name.rawValue] = user.name
        newUser[userKeys.email.rawValue] = user.email
        newUser[userKeys.pin.rawValue] = user.pin
        newUser[userKeys.restaurants.rawValue] = user.restaurants
        
        saveRecord(newUser)
    }
    
    func saveRestaurantInUser() {
        userRecord?[userKeys.restaurants.rawValue] = userModel.restaurants
        
        saveRecord(userRecord ?? CKRecord(recordType: userKeys.type.rawValue))
        userModel = userModel
    }
    
    private func saveRecord(_ record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { [self] (record, _) in
            guard let _ = record else { return }
            loadUserInfo()
        }
    }
    
    // Private function to check if the user has an iCloud account
    private func checkiCloudUser() {
        CKContainer.default().accountStatus { [self] (status, _) in
            guard case .available = status else {
                loginStatus = .iCloudOff
                return
            }
            DispatchQueue.main.async { [self] in
                loginStatus = .iCLoudOn
                print("Si tiene iCloud iniciado")
                loadUserInfo()
            }
        }
    }
    
    // Private function to get the user's CloudKit user ID
    func loadUserInfo() {
        CKContainer.default().fetchUserRecordID {  (id, error) in
                guard let id = id, error == nil else {
                    print("Error al obtener el ID del usuario: \(error?.localizedDescription ?? "Desconocido")")
                    return
                }
                
                DispatchQueue.main.async { [self] in
                    userId = id.recordName
                    print("Se ha encontrado el ID del usuario: \(userId ?? "Error")")
                    checkIfLoggedIn()
                }
            }
    }
    
    // Private function to check if the user is logged in and retrieve their data if they are
    private func checkIfLoggedIn() {
        guard let id = userId else {
            self.queriesDone = true
            return
        }
        let predicate = NSPredicate(format: "\(userKeys.id.rawValue) == %@", id)
        let query = CKQuery(recordType: userKeys.type.rawValue, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { [self] (_, result) in
            guard case .success(let record) = result,
                  let name: String = record[userKeys.name.rawValue],
                  let email: String = record[userKeys.email.rawValue],
                  let pin: String = record[userKeys.pin.rawValue],
                  let restaurants: [String] = record[userKeys.restaurants.rawValue] else { return }
            DispatchQueue.main.sync {
                loginStatus = .loggedIn
                userRecord = record
                userModel = User(name: name, email: email, pin: pin, restaurants: restaurants)
                getRestaurantsList()
            }
        }
        queryOperation.queryResultBlock = { _ in
            DispatchQueue.main.async { [self] in
                queriesDone = true
            }
        }
        addQueryOperation(queryOperation)
    }
    
    /**
     Fetches the list of restaurants from the CloudKit public database and appends them to the restaurantes array if they belong to the user's list of restaurants.
     */
    private func getRestaurantsList() {
        DispatchQueue.main.async {
            self.restaurants = []
            self.emploRestaurants = []
            self.adminRestaurants = []
        }
        let predicateA = NSPredicate(format: "\(restaurantKeys.linkAdmin) IN %@", userModel.restaurants)
        let predicateE = NSPredicate(format: "\(restaurantKeys.linkEmployee) IN %@", userModel.restaurants)
        handleRecord(predicate: predicateA)
        handleRecord(predicate: predicateE)
        
        func handleRecord(predicate: NSPredicate) {
            let query = CKQuery(recordType: restaurantKeys.type.rawValue, predicate: predicate)
            let queryOperation = CKQueryOperation(query: query)
            
            queryOperation.recordMatchedBlock = { [self] (_, result) in
                guard case .success(let record) = result,
                      let name: String = record[restaurantKeys.name.rawValue],
                      let linkAdmin: String = record[restaurantKeys.linkAdmin.rawValue],
                      let linkEmployee: String = record[restaurantKeys.linkEmployee.rawValue] else { return }
                DispatchQueue.main.sync {
                    var restaurant = Restaurant()
                    if userModel.restaurants.contains(linkAdmin) {
                        restaurant = Restaurant(name: name, linkAdmin: linkAdmin, linkEmployee: linkEmployee, record: record)
                        self.currentRestaurantAdmin = true
                        adminRestaurants.append(restaurant)
                    } else if userModel.restaurants.contains(linkEmployee) {
                        restaurant = Restaurant(name: name, linkEmployee: linkEmployee, record: record)
                        currentRestaurantAdmin = false
                        emploRestaurants.append(restaurant)
                    }
                    
                    restaurants.append(restaurant)
                    restaurants = restaurants
                    adminRestaurants = adminRestaurants
                    emploRestaurants = emploRestaurants
                }
            }
            
            queryOperation.queryResultBlock = { result in
                DispatchQueue.main.async { [self] in
                    queriesDone = true
                }
            }
            addQueryOperation(queryOperation)
        }
    }
    
    func setCurrentRestaurant(restaurant: Restaurant) {
        let linkAdmin = restaurant.linkAdmin
        let linkEmployee = restaurant.linkEmployee
        let predicate = restaurant.linkAdmin == linkAdminNoAllowed ? NSPredicate(format: "\(restaurantKeys.linkEmployee) == %@", linkEmployee) : NSPredicate(format: "\(restaurantKeys.linkAdmin) == %@", linkAdmin)
        let query = CKQuery(recordType: restaurantKeys.type.rawValue, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { [self] (_, result) in
            guard case .success(let record) = result,
                  let link: String = record[restaurantKeys.linkAdmin.rawValue] else { return }
            DispatchQueue.main.sync {
                currentRestaurantLink = link
                currentRestaurantAdmin = (link == linkAdmin)
                loginStatus = .restaurantSelected
            }
        }
        addQueryOperation(queryOperation)
        
    }
    
    func addQueryOperation(_ queryOperation: CKQueryOperation) {
        CKContainer.default().publicCloudDatabase.add(queryOperation)
    }
}

