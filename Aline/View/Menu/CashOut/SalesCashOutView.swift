//
//  SalesCashOutView.swift
//  Aline
//
//  Created by Leonardo on 29/08/23.
//

import SwiftUI

struct SalesCashOutView: View {
    
    @State private var carmenTRJTA: Double = 0.0
    @State private var depo: Double = 0.0
    @State private var dscan: Double = 0.0
    @State private var doordash: Double = 0.0
    @State private var online: Double = 0.0
    @State private var grubhub: Double = 0.0
    @State private var tacobar: Double = 0.0
    @State private var spendingsArray: [Double] = [0]
    
    var body: some View {
        VStack {
            totals.padding(.top, 20)
            sales.padding(.top, 20)
            spendings.padding(.top, 20)
            SaveButtonWhite(action: save)
        }
    }
    
    private var totals: some View {
        VStack(alignment: .leading){
            Header("Totales")
            WhiteArea {
                HStack {
                    Text("RTO. Nos:").bold()
                    Spacer()
                    Text(String(format: "%.2f", depo + dscan + doordash + online + grubhub + tacobar + carmenTRJTA))
                }
                Divider()
                HStack {
                    Text("V. equipo:")
                    Spacer()
                    Text(String(format: "%.2f", depo + carmenTRJTA))
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
                DecimalField("0.0", decimal: $carmenTRJTA)
            }
            Divider()
            HStack {
                Text("Depo:")
                DecimalField("0.0", decimal: $depo)
            }
            Divider()
            HStack {
                Text("DSCAN:")
                DecimalField("0.0", decimal: $dscan)
            }
            Divider()
        }
    }
    
    private var servicesSales: some View {
        VStack {
            HStack {
                Text("Door Dash:").foregroundStyle(Color.red)
                DecimalField("0.0", decimal: $doordash)
            }
            Divider()
            HStack {
                Text("Online:").foregroundStyle(Color.green)
                DecimalField("0.0", decimal: $online)
            }
            Divider()
            HStack {
                Text("GrubHub:").foregroundStyle(Color.orange)
                DecimalField("0.0", decimal: $grubhub)
            }
            Divider()
            HStack {
                Text("Taco Bar:").foregroundStyle(Color.blue)
                DecimalField("0.0", decimal: $tacobar)
            }
        }
    }
    
    private var spendings: some View {
        VStack(alignment: .leading) {
            Header("Gastos")
            WhiteArea {
                HStack {
                    Text("Total:").bold()
                    Spacer()
                    Text(String(format: "%.2f", spendingsArray.reduce(0.0, +)))

                }
                ForEach(spendingsArray.indices, id: \.self) { index in
                    Divider()
                    HStack {
                        Text("Gasto \(index + 1):")
                        DecimalField("0.0", decimal: $spendingsArray[index])
                    }
                }
                Divider()
                Button(action: addSpending) {
                    Text("Agregar gasto")
                    Image(systemName: "plus.circle.fill")
                    Spacer()
                }.foregroundStyle(.blue)
            }
        }
    }
    
    private func addSpending() {
        withAnimation {
            spendingsArray.append(0.0)
        }
    }
    
    private func save() {
        
    }
}
