//
//  Double.swift
//  Aline
//
//  Created by Leonardo on 02/09/23.
//

import Foundation

extension Double {
    var comasText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self.rounded())) ?? ""
    }
    
    var comasTextWithDecimals: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(self))) ?? ""
    }
}
