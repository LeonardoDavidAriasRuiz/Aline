//
//  TipsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct TipsView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    @State private var newDeposit = Deposit()
    @State private var aaa = 299.0
    
    var body: some View {
        Sheet(section: .tips) {
            WhiteArea {
                DatePicker("", selection: $newDeposit.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Divider()
                Stepper("$\(String(format: "%.0f", aaa))", value: $aaa, in: 100...10000, step: 50, format: .number)
                Divider()
                Button("Guardar", action: {})
            }
        }
    }
}

