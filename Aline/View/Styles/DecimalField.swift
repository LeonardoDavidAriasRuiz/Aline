//
//  DecimalField.swift
//  Aline
//
//  Created by Leonardo on 28/08/23.
//

import SwiftUI

struct DecimalField: View {
    @State private var decimalInText: String = ""
    let titleKey: String
    @Binding var decimal: Double
    
    init(_ titleKey: String, decimal: Binding<Double>) {
        self.titleKey = titleKey
        self._decimal = decimal
        if decimal.wrappedValue != 0.0 {
            decimalInText = String(decimal.wrappedValue)
        }
    }
    
    var body: some View {
        TextField(titleKey, text: $decimalInText)
            .keyboardType(.decimalPad)
            .foregroundStyle(Color.black.secondary)
            .onChange(of: decimalInText, validateTipsQuantity)
    }
    
    private func validateTipsQuantity(oldValue: String, newValue: String) {
        if newValue.isEmpty {
            decimal = 0.0
        } else if newValue.isNotEmpty {
            if let decimal = Double(newValue) {
                decimalInText = newValue
                self.decimal = decimal
            } else {
                decimalInText = oldValue
            }
        }
    }
}
