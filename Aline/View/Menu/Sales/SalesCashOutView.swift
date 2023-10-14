//
//  SalesCashOutView.swift
//  Aline
//
//  Created by Leonardo on 29/08/23.
//

import SwiftUI

struct SalesCashOutView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @State private var sale: Sale = Sale()
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .crearingError
    
    @State private var datePickerShowed: Bool = false
    
    let saleVM: SaleViewModel = SaleViewModel()
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .cashOut, isLoading: $isLoading) {
            datePicker.padding(.top, 20)
            totals.padding(.top, 20)
            sales.padding(.top, 20)
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
        Button(action: discard) {
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
            OpenSectionButton(pressed: $datePickerShowed, text: sale.date.shortDate)
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
            WhiteArea(spacing: 8) {
                HStack {
                    Text("RTO. Nos:").bold()
                    DecimalField("0.0", decimal: $sale.rtonos)
                    HStack {
                        Text(String(format: "%.2f", sale.rtonosCalculated))
                            .frame(width: 50)
                            .padding(2)
                            .padding(.horizontal, 5)
                            .background(Color.whiteArea)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        Spacer()
                        Text(String(format: "%.2f", sale.rtonosCalculated - sale.rtonos))
                            .frame(width: 50)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 115)
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
                            .frame(width: 50)
                            .padding(.horizontal, 5)
                            .background(Color.whiteArea)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        Spacer()
                        Text(String(format: "%.2f", sale.vequipoCalculated - sale.vequipo))
                            .frame(width: 50)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 105)
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
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Depo:")
                DecimalField("0.0", decimal: $sale.depo)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("DSCAN:")
                DecimalField("0.0", decimal: $sale.dscan)
            }.padding(.vertical, 8)
            Divider()
        }
    }
    
    private var servicesSales: some View {
        VStack {
            HStack {
                Text("Door Dash:").foregroundStyle(Color.red)
                DecimalField("0.0", decimal: $sale.doordash)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Online:").foregroundStyle(Color.green)
                DecimalField("0.0", decimal: $sale.online)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("GrubHub:").foregroundStyle(Color.orange)
                DecimalField("0.0", decimal: $sale.grubhub)
            }.padding(.vertical, 8)
            Divider()
            HStack {
                Text("Taco Bar:").foregroundStyle(Color.blue)
                DecimalField("0.0", decimal: $sale.tacobar)
            }.padding(.vertical, 8)
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        sale.rtonos == sale.rtonosCalculated && sale.vequipo == sale.vequipoCalculated
    }
    
    private func discard() {
        self.presentationMode.wrappedValue.dismiss()
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
