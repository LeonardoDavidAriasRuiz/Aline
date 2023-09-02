//
//  SalesCashOutView.swift
//  Aline
//
//  Created by Leonardo on 29/08/23.
//

import SwiftUI

struct SalesCashOutView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @State private var sale: Sale = Sale()
    
    @State private var isLoading: Bool = false
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .crearingError
    
    let saleVM: SaleViewModel = SaleViewModel()
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            VStack {
                totals.padding(.top, 20)
                sales.padding(.top, 20)
                SaveButtonWhite(action: save).padding(.top, 20)
                    .disabled(sale.rtonos == 0 || sale.vequipo == 0)
            }
        }
        .alertInfo(alertType, showed: $alertShowed)
    }
    
    private var totals: some View {
        VStack(alignment: .leading){
            Header("Totales")
            WhiteArea {
                HStack {
                    Text("RTO. Nos:").bold()
                    Spacer()
                    Text(String(format: "%.2f", sale.rtonos))
                }
                Divider()
                HStack {
                    Text("V. equipo:")
                    Spacer()
                    Text(String(format: "%.2f", sale.vequipo))
                }
            }
        }
    }
    
    private var sales: some View {
        VStack(alignment: .leading){
            Header("Ventas")
            WhiteArea {
                inDoorSales
                servicesSales
            }
        }
    }
    
    private var inDoorSales: some View {
        VStack {
            HStack {
                Text("CarmenTRJTA:")
                DecimalField("0.0", decimal: $sale.carmenTRJTA)
            }
            Divider()
            HStack {
                Text("Depo:")
                DecimalField("0.0", decimal: $sale.depo)
            }
            Divider()
            HStack {
                Text("DSCAN:")
                DecimalField("0.0", decimal: $sale.dscan)
            }
            Divider()
        }
    }
    
    private var servicesSales: some View {
        VStack {
            HStack {
                Text("Door Dash:").foregroundStyle(Color.red)
                DecimalField("0.0", decimal: $sale.doordash)
            }
            Divider()
            HStack {
                Text("Online:").foregroundStyle(Color.green)
                DecimalField("0.0", decimal: $sale.online)
            }
            Divider()
            HStack {
                Text("GrubHub:").foregroundStyle(Color.orange)
                DecimalField("0.0", decimal: $sale.grubhub)
            }
            Divider()
            HStack {
                Text("Taco Bar:").foregroundStyle(Color.blue)
                DecimalField("0.0", decimal: $sale.tacobar)
            }
        }
    }
    
    private func save() {
        isLoading = true
        sale.restaurantId = restaurantVM.currentRestaurantId
        saleVM.save(sale) { sale in
            if let _ = sale {
                self.sale = Sale()
            } else {
                alertType = .crearingError
                alertShowed = true
            }
            isLoading = false
        }
    }
}
