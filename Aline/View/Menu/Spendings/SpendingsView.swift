//
//  SpendingsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import Charts

struct SpendingsView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var spendingController: ExpenseViewModel
    @EnvironmentObject private var userController: UserViewModel
    
    @State private var newSpendingType = ExpenseType()
    @State private var newSpending = Expense()
    @State private var newSpendingTypePressed: Bool = false
    
    @State private var shouldShowEmptyFieldAlertsForNewType: Bool = false
    @State private var typeNotSelectedAlert: Bool = false
    @State private var navigationBarBackButtonHidden: Bool = false
    
    
    var body: some View {
        NavigationView {
            typesMenu
        }
        .onAppear(perform: accentColor.red)
        .tint(accentColor.tint)
        .onAppear(perform: onAppear)
    }
    
    private var typesMenu: some View {
        List {
            ForEach(spendingController.types, id: \.self) { type in
                NavigationLink(type.name, destination: SpendingTypeInfo(type: type))
            }
            newTypeArea
                .alert(isPresented: $shouldShowEmptyFieldAlertsForNewType) {
                    Alert(
                        title: Text("Error"),
                        message: Text("Necesitas completar todos los espacios para poder guardar el tipo de gasto."),
                        primaryButton: .destructive(Text("No guardar"), action: closeNewTypeArea),
                        secondaryButton: .cancel(Text("Reintentar"))
                    )
                }
        }
    }
    
    private func addNewSpending() {
        withAnimation {
            if newSpending.typeLink.isEmpty {
                typeNotSelectedAlert = true
            } else {
                spendingController.addSpending(newSpending)
                newSpending = Expense()
            }
        }
    }
    
    private var newTypeArea: some View {
        HStack {
            if newSpendingTypePressed {
                VStack {
                    TextField("Nombre", text: $newSpendingType.name).modifier(TextFieldSpendings())
                    TextField("Descripción", text: $newSpendingType.description).modifier(TextFieldSpendings())
                }.padding(10)
            }
            Button(action: addType) {
                VStack {
                    Image(systemName: "plus.circle.fill").font(.system(size: 30))
                }
                .padding(.horizontal, 20)
                .foregroundColor(Color.white)
                .frame(maxHeight: .infinity)
                .frame(width: 80)
                .background(Color.purple.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func addType(){
        withAnimation {
            
            if newSpendingTypePressed {
                if !newSpendingType.name.isEmpty && !newSpendingType.description.isEmpty {
                    spendingController.addType(newSpendingType)
                    newSpendingType = ExpenseType()
                    newSpendingTypePressed = false
                } else {
                    shouldShowEmptyFieldAlertsForNewType = true
                }
            } else {
                newSpendingTypePressed = true
            }
        }
    }
    
    private func closeNewTypeArea() {
        withAnimation {
            newSpendingTypePressed = false
            newSpendingType = ExpenseType()
        }
    }
    
    private func onAppear() {
        spendingController.currentRestaurantLink = restaurantVM.restaurant.id
        spendingController.fetchTypes()
    }
}

struct SpendingTypeInfo: View {
    let type: ExpenseType
    @State private var spendingsPerMonth: [spendingPerMonth] = []
    
    @EnvironmentObject private var spendingController: ExpenseViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                chart
            }.padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(20)
        }
        .onAppear(perform: onAppear)
        .navigationTitle(type.name)
    }
    
    private var chart: some View {
        Chart(spendingController.spendingsPerMonth, id: \.self) { spending in
            BarMark(
                x: .value("Mes",spending.date, unit: .month),
                y: .value("Gasto",spending.quantity)
            )
            .foregroundStyle(Color.purple.gradient)
        }
        .chartXAxis {
            AxisMarks(values: spendingController.spendingsPerMonth.map { $0.date }) { date in
                AxisValueLabel(format: .dateTime.month())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 600)
    }
    
    private func onAppear() {
        spendingController.fetchSpendingsFrom(type: type)
    }
}




