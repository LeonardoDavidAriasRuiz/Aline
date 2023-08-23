//
//  AccentColor.swift
//  Aline
//
//  Created by Leonardo on 20/07/23.
//

import SwiftUI

class AccentColor: ObservableObject {
    @Published  var tint: Color = Color.green
    
    func green() {
        tint = Color.green
    }
    
    func blue() {
        tint = Color.blue
    }
    
    func red() {
        tint = Color.red
    }
    
    func orange() {
        tint = Color.orange
    }
    
    func set(_ tint: Color) {
        self.tint = tint
    }
}
