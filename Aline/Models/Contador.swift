//
//  Contador.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import Foundation

struct Contador {
     var name: String
     var email: String
     var message: String
    
    init(name: String, email: String, message: String) {
        self.name = name
        self.email = email
        self.message = message
    }
    
    init() {
        self.name = ""
        self.email = ""
        self.message = "Mensaje predeterminado."
    }
}
