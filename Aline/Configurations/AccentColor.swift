//
//  AccentColor.swift
//  Aline
//
//  Created by Leonardo on 20/07/23.
//

import SwiftUI

class AccentColor: ObservableObject {
    @Published  var color: Color = Color.green
    
    func green() {
        color = Color.green
    }
    
    func blue() {
        color = Color.blue
    }
    
    func red() {
        color = Color.red
    }
    
    func orange() {
        color = Color.orange
    }
    
    func set(_ color: Color) {
        self.color = color
    }
}
