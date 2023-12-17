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
    let fortnightChecksType = "fortnightChecksType"
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

struct FortnightTotalTipsKeys {
    let type = "FortnightTips"
    let id = "id"
    let date = "date"
    let employeeId = "employeeId"
    let employee = "employee"
    let total = "total"
    let direct = "direct"
    let delivered = "delivered"
    let restaurantId = "restaurantId"
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

struct SpendingKeys {
    let type = "Spendings"
    let id = "id"
    let quantity = "quantity"
    let notes = "notes"
    let date = "date"
    let spendingTypeId = "spendingTypeId"
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
    let status = "status"
    let startEndDates = "startEndDates"
    let employeesIds = "employeesIds"
    let restaurantId = "restaurantId"
}
struct BeneficiarySpendingKeys {
    let type = "BeneficiariesSpendings"
    let id = "id"
    let beneficiaryId = "beneficiaryId"
    let date = "date"
    let quantity = "quantity"
    let note = "note"
    let restaurantId = "restaurantId"
}

struct WorksheetKeys {
    let type = "Worksheets"
    let id = "id"
    let payDate = "payDate"
    let bonus = "bonus"
    let notes = "notes"
    let pdf = "pdf"
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

struct WorksheetSettingsKeys {
    let type = "WorksheetsSettings"
    let id = "id"
    let worksheetTitle = "worksheetTitle"
    let companyName = "companyName"
    let numberStreetSte = "numberStreetSte"
    let cityStatePC = "cityStatePC"
    let logo = "logo"
    let restaurantId = "restaurantId"
}

struct CheckKeys {
    let type = "Checks"
    let id = "id"
    let date = "date"
    let fortnight = "fortnight"
    let cash = "cash"
    let direct = "direct"
    let employeeId = "employeeId"
    let restaurantId = "restaurantId"
}
