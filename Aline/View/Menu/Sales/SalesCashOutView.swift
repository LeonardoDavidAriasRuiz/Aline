//
//  SalesCashOutView.swift
//  Aline
//
//  Created by Leonardo on 29/08/23.
//

import SwiftUI

struct SalesCashOutView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var loading: LoadingViewModel
    @State private var sale: Sale = Sale()
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .crearingError
    
    @State private var datePickerShowed: Bool = false
    
    let saleVM: SaleViewModel = SaleViewModel()
    
    var body: some View {
        Sheet(section: .cashOut) {
            datePicker.padding(.top, 20)
            totals.padding(.top, 20)
            sales.padding(.top, 20)
            SaveButtonWhite(action: save).padding(.top, 20)
                .disabled(sale.rtonos == 0 || sale.vequipo == 0)
        }
        .alertInfo(alertType, showed: $alertShowed)
    }
    
    private var datePicker: some View {
        WhiteArea {
            OpenSectionButton(pressed: $datePickerShowed, text: sale.date.short)
            if datePickerShowed {
                Divider()
                DatePicker("", selection: $sale.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
        }
    }
    
    private var totals: some View {
        VStack(alignment: .leading){
            Header("Totales")
            WhiteArea {
                HStack {
                    Text("RTO. Nos:").bold()
                    DecimalField("0.0", decimal: $sale.rtonos)
                    HStack {
                        Text(String(format: "%.2f", sale.rtonosCalculated))
                            .padding(2)
                            .padding(.horizontal, 5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        Text(String(format: "%.2f", sale.rtonosCalculated - sale.rtonos))
                            .foregroundStyle(.white)
                    }
                    .padding(2)
                    .padding(.trailing, 5)
                    .background(sale.rtonosCalculated != sale.rtonos ? Color.red : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                }
                Divider()
                HStack {
                    Text("V. equipo:")
                    DecimalField("0.0", decimal: $sale.vequipo)
                    HStack {
                        Text(String(format: "%.2f", sale.vequipoCalculated))
                            .padding(2)
                            .padding(.horizontal, 5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        Text(String(format: "%.2f", sale.vequipoCalculated - sale.vequipo))
                            .foregroundStyle(.white)
                    }
                    .padding(2)
                    .padding(.trailing, 5)
                    .background(sale.vequipoCalculated != sale.vequipo ? Color.red : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
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
        loading.isLoading = true
        if let restaurantId = restaurantM.restaurant?.id {
            sale.restaurantId = restaurantId
            saleVM.save(sale) { sale in
                if let _ = sale {
                    self.sale = Sale()
                } else {
                    alertType = .crearingError
                    alertShowed = true
                }
                loading.isLoading = false
            }
        }
    }
}
