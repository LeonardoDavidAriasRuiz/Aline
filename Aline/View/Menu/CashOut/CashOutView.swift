//
//  CashOutView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 05/04/23.
//

import SwiftUI

struct CashOutView: View {
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var cashOutSectionSelected: CashOutType = .sales
    
    var body: some View {
        Sheet(section: .cashOut) {
            cashOutSectionPicker
            switch cashOutSectionSelected {
                case .sales: SalesCashOutView()
                case .tips: TipsCashOutView()
            }
            
        }
        .onAppear(perform: accentColor.red)
        .tint(Color.red)
    }
    
    private var cashOutSectionPicker: some View {
        Picker(cashOutSectionSelected.rawValue, selection: $cashOutSectionSelected) {
            Text(CashOutType.sales.rawValue).tag(CashOutType.sales)
            Text(CashOutType.tips.rawValue).tag(CashOutType.tips)
        }
        .pickerStyle(.segmented)
    }
}

enum CashOutType: String {
    case sales = "Ventas"
    case tips = "Tips"
}
