//
//  SalesCashOutView.swift
//  Aline
//
//  Created by Leonardo on 29/08/23.
//

import SwiftUI

struct SalesCashOutView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var sale: Sale = Sale()
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .crearingError
    @State private var isLoading: Bool = false
    
    let saleVM: SaleViewModel = SaleViewModel()
    
    var body: some View {
        Sheet(section: .cashOut, isLoading: $isLoading) {
            totals.padding(.top, 20)
            sales.padding(.top, 20)
            datePicker.padding(.top, 20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                discardToolBarButton
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                saveToolBarButton
            }
        }
        .navigationBarBackButtonHidden()
        .alertInfo(alertType, showed: $alertShowed)
    }
    
    private var discardToolBarButton: some View {
        Button(action: {dismiss()}) {
            Text("Descartar").foregroundStyle(Color.red)
        }
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfSpendingReadyToSave() {
                Button(action: save) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    Text("Las cantidades no coincidden.")
                }
            }
        }
    }
    
    private var datePicker: some View {
        WhiteArea {
            DatePicker("", selection: $sale.date, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
    }
    
    private var totals: some View {
        VStack(alignment: .leading){
            Header("Totales")
            WhiteArea(spacing: 0) {
                HStack {
                    Text("RTO. Nos:").bold()
                    DecimalField("0.0", decimal: $sale.rtonos.animation(), alignment: .leading)
                    HStack {
                        Text(String(format: "%.2f", sale.rtonosCalculated))
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .font(.footnote)
                        if sale.rtonosCalculated != sale.rtonos {
                            Text(String(format: "%.2f", sale.rtonosCalculated - sale.rtonos))
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .font(.footnote)
                        }
                    }
                    .frame(width: 140)
                    .padding(3)
                    .background(sale.rtonosCalculated != sale.rtonos ? Color.red : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                }.padding(.vertical, 8)
                Divider()
                HStack {
                    Text("V. equipo:").bold()
                    DecimalField("0.0", decimal: $sale.vequipo.animation(), alignment: .leading)
                    HStack {
                        Text(String(format: "%.2f", sale.vequipoCalculated))
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .font(.footnote)
                        if sale.vequipoCalculated != sale.vequipo {
                            Text(String(format: "%.2f", sale.vequipoCalculated - sale.vequipo))
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .font(.footnote)
                        }
                    }
                    .frame(width: 140)
                    .padding(3)
                    .background(sale.vequipoCalculated != sale.vequipo ? Color.red : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                }.padding(.vertical, 8)
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
        VStack(spacing: 0) {
            HStack {
                Text("CarmenTRJTA:")
                DecimalField("0.0", decimal: $sale.carmenTRJTA.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Depo:")
                DecimalField("0.0", decimal: $sale.depo.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("DSCAN:")
                DecimalField("0.0", decimal: $sale.dscan.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
        }
    }
    
    private var servicesSales: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Door Dash:").foregroundStyle(Color.red)
                DecimalField("0.0", decimal: $sale.doordash.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Online:").foregroundStyle(Color.green)
                DecimalField("0.0", decimal: $sale.online.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("GrubHub:").foregroundStyle(Color.orange)
                DecimalField("0.0", decimal: $sale.grubhub.animation(), alignment: .leading)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Taco Bar:").foregroundStyle(Color.blue)
                DecimalField("0.0", decimal: $sale.tacobar.animation(), alignment: .leading)
            }.padding(.vertical, 8)
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        sale.rtonos == sale.rtonosCalculated && sale.vequipo == sale.vequipoCalculated
    }
    
    private func save() {
        isLoading = true
        if let restaurantId = restaurantM.restaurant?.id {
            sale.restaurantId = restaurantId
            saleVM.save(sale.record) {
                self.sale = Sale()
            } ifNot: {
                alertVM.show(.crearingError)
            } alwaysDo: {
                isLoading = false
            }
        }
    }
}
