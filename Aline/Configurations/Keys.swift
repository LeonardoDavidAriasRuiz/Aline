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

struct SalesKeys {
    let type: String = "Sales"
    let date: String = "date"
    let rtonos: String = "rtonos"
    let vequipo: String = "vequipo"
    let carmenTRJTA: String = "carmentrjta"
    let depo: String = "depo"
    let dscan: String = "dscan"
    let doordash: String = "doordash"
    let online: String = "online"
    let grubhub: String = "grubhub"
    let tacobar: String = "tacobar"
    let restaurantId: String = "restaurantId"
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

struct TipKeys {
    let type = "Tips"
    let id = "id"
    let date = "date"
    let quantity = "quantity"
    let employeeId = "employeeId"
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


