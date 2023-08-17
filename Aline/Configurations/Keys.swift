//
//  Keys.swift
//  Aline
//
//  Created by Leonardo on 18/07/23.
//

import Foundation

struct UserKeys {
    let type = "CustomUsers"
    let id = "id"
    let name = "name"
    let email = "email"
    let adminRestaurantsIds = "adminRestaurantsIds"
    let emploRestaurantsIds = "emploRestaurantsIds"
}

struct RestaurantKeys {
    let type = "Restaurants"
    let id = "id"
    let name = "name"
    let email = "email"
    let adminUsersIds = "adminUsersIds"
    let emploUsersIds = "emploUsersIds"
    let linkAdminNoPermited = "Vínculo Admin no permitido"
}

struct ConectionKeys {
    let type = "Conections"
    let id = "id"
    let email = "email"
    let isAdmin = "isAdmin"
    let restaurantId = "restaurantId"
    let restaurantName = "restaurantName"
}

struct EmployeeKeys {
    let type = "Employees"
    let id = "id"
    let name = "name"
    let lastName = "lastName"
    let isActive = "isActive"
    let restaurantId = "restaurantId"
}

struct DepositKeys {
    let type = "Deposits"
    let id = "id"
    let date = "date"
    let quantity = "quantity"
    let restaurantId = "restaurantId"
}

enum ExpenseKeys: String {
    case type = "Expenses"
    case id
    case quantity
    case description
    case date
    case typeLink
    case restaurantId
}


