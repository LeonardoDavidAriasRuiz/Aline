//
//  DecimalField.swift
//  Aline
//
//  Created by Leonardo on 28/08/23.
//

import SwiftUI

struct DecimalField: View {
    @State private var decimalInText: String
    let titleKey: String
    let alignment: TextAlignment
    @Binding var decimal: Double
    
    
    init(_ titleKey: String, decimal: Binding<Double>, alignment: TextAlignment = .center) {
        self.titleKey = titleKey
        self.alignment = alignment
        self._decimal = decimal
        self.decimalInText = decimal.wrappedValue > 0.0 ? String(decimal.wrappedValue) : ""
    }
    
    var body: some View {
        TextField(titleKey, text: $decimalInText)
            .keyboardType(.decimalPad)
            .onChange(of: decimalInText, validateTipsQuantity)
            .multilineTextAlignment(alignment)
    }
    
    private func validateTipsQuantity(oldValue: String, newValue: String) {
        if newValue.isEmpty {
            decimal = 0
        } else if newValue == "-"{
            
        } else if newValue.isNotEmpty {
            if let decimal = Double(newValue) {
                self.decimal = decimal
            } else {
                decimalInText = oldValue
            }
        }
    }
}
