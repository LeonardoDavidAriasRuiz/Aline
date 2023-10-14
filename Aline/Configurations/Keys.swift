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
    let type = "Sales"
    let date = "date"
    let rtonos = "rtonos"
    let vequipo = "vequipo"
    let carmenTRJTA = "carmentrjta"
    let depo = "depo"
    let dscan = "dscan"
    let doordash = "doordash"
    let online = "online"
    let grubhub = "grubhub"
    let tacobar = "tacobar"
    let restaurantId = "restaurantId"
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
    let salary = "salary"
    let quantity = "quantity"
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

struct TipReviewKeys {
    let type = "TipsReviews"
    let id = "id"
    let restaurantId = "restaurantId"
    let from = "from"
    let to = "to"
    let employeesIds = "employeesIds"
    let quantityForEach = "quantityForEach"
    let notes = "notes"
}

struct AccountantKeys {
    let type = "Accountants"
    let restaurantId = "restaurantId"
    let name = "name"
    let email = "email"
    let message = "message"
}

struct SpendingKeys {
    let type = "Spendings"
    let id = "id"
    let quantity = "quantity"
    let notes = "notes"
    let date = "date"
    let spendingTypeId = "spendingTypeId"
    let beneficiaryId = "beneficiaryId"
    let restaurantId = "restaurantId"
}

struct SpendingTypeKeys {
    let type = "SpendingTypes"
    let id = "id"
    let name = "name"
    let description = "description"
    let restaurantId = "restaurantId"
}

struct BeneficiaryKeys {
    let type = "Beneficiaries"
    let id = "id"
    let name = "name"
    let lastName = "lastName"
    let percentage = "percentage"
    let startDate = "startDate"
    let endDate = "endDate"
    let employeesIds = "employeesIds"
    let restaurantId = "restaurantId"
}

struct WorksheetKeys {
    let type = "Worksheets"
    let id = "id"
    let payDate = "payDate"
    let bonus = "bonus"
    let notes = "notes"
    let sent = "sent"
    let restaurantId = "restaurantId"
}

struct WorksheetRecordKeys {
    let type = "WorksheetRecords"
    let id = "id"
    let worksheetId = "worksheetId"
    let employeeId = "employeeId"
    let salary = "salary"
    let quantity = "quantity"
    let hours = "hours"
    let overTime = "overTime"
    let sickTime = "sickTime"
    let cashTips = "cashTips"
    let cargedTips = "cargedTips"
    let garnishment = "garnishment"
}
