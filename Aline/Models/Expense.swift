//
//  Expense.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import Foundation

struct Expense: Hashable {
     var id: String
     var quantity: String
     var description: String
     var month: Int
     var year: Int
     var typeLink: String
     var restaurantLink: String
    
    enum Keys: String {
        case type = "Gastos"
        case id
        case quantity
        case description
        case date
        case typeLink
        case restaurantLink
    }
    
    init(id: String, quantity: String, description: String, month: Int, year: Int, typeLink: String, restaurantLink: String) {
        self.id = id
        self.quantity = quantity
        self.description = description
        self.month = month
        self.year = year
        self.typeLink = typeLink
        self.restaurantLink = restaurantLink
    }
    
    init() {
        let date = Date()
        let calendar = Calendar.current
        
        self.id = UUID().uuidString
        self.quantity = "0.00"
        self.description = ""
        self.month = calendar.component(.month, from: date) - 1
        self.year = calendar.component(.year, from: date)
        self.typeLink = ""
        self.restaurantLink = ""
    }
}
