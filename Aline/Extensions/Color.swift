//
//  Color.swift
//  Aline
//
//  Created by Leonardo on 14/09/23.
//

import SwiftUI

extension UIColor {
    convenience init(_ color: Color) {
        let scanner = Scanner(string: color.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        
        scanner.scanHexInt64(&hexNumber)
        
        let red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
        let green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
        let blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
        let alpha = CGFloat(hexNumber & 0x000000FF) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
