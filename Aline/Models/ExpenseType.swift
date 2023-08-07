//
//  ExpenseType.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import Foundation

struct ExpenseType: Hashable {
     var id: String
     var name: String
     var description: String
     var restaurantLink: String
    
    enum Keys: String{
        case type = "GastoTipos"
        case id
        case name
        case description
        case restaurantLink
    }
    
    init(id: String, name: String, description: String, restaurantLink: String) {
        self.id = id
        self.name = name
        self.description = description
        self.restaurantLink = restaurantLink
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.description = ""
        self.restaurantLink = ""
    }
}
