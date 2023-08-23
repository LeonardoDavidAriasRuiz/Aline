//
//  MenuView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            if !isLoading {
                menuList
                    .background(Color.background)
                    .navigationTitle("Menu")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            restaurantPicker
                        }
                    }
            }
            
        }
        .onChange(of: restaurantVM.currentRestaurantId, setRestaurant)
        .alertInfo(.dataObtainingError, showed: $restaurantVM.dataNotObtained)
    }
    
    private var restaurantPicker: some View {
        VStack {
            if restaurantVM.adminRestaurants.isNotEmpty || restaurantVM.emploRestaurants.isNotEmpty {
                Picker("Restaurants", selection: $restaurantVM.currentRestaurantId) {
                    ForEach(restaurantVM.adminRestaurants) { restaurant in
                        Text(restaurant.name).tag(restaurant.id)
                    }
                    ForEach(restaurantVM.emploRestaurants) { restaurant in
                        Text(restaurant.name).tag(restaurant.id)
                    }
                }
            }
        }
    }
    
    private var menuList: some View {
        List {
            MenuOption(title: "Corte", content: { CashOutView() })
            if restaurantVM.adminRestaurants.contains(restaurantVM.restaurant) {
                MenuOption(title: "Ventas", content: { SalesView() })
                MenuOption(title: "Tips", content: { TipsView() })
                MenuOption(title: "Depositos", content: { DepositsView() })
                MenuOption(title: "Gastos", content: { SpendingsView() })
                MenuOption(title: "Beneficiarios", content: { BeneficiariosView() })
                MenuOption(title: "Cheques", content: { ChecksView() })
                MenuOption(title: "PayRoll", content: { PayRollView() })
                MenuOption(title: "Empleados", content: { EmployeesView() })
                MenuOption(title: "Contador", content: { ContadorView() })
            }
            MenuOption(title: "Cuenta", content: { AccountView() })
        }
    }
    
    private func setRestaurant(_old: String, _ id: String) {
        withAnimation {
            isLoading = true
            if let newRestaurant = restaurantVM.adminRestaurants.first(where: { $0.id == id }) {
                restaurantVM.restaurant = newRestaurant
            }
            if let newRestaurant = restaurantVM.emploRestaurants.first(where: { $0.id == id }) {
                restaurantVM.restaurant = newRestaurant
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            isLoading = false
        }
        
    }
}

fileprivate struct MenuOption<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        NavigationLink( destination: content(), label: {options[title]})
    }
    
    private let options = [
        "Corte" :         OptionTitleView(color: .red,  title: "Corte",             icon: "list.bullet.clipboard.fill"),
        "Ventas" :        OptionTitleView(color: .green,   title: "Ventas",         icon: "chart.bar.fill"),
        "Tips" :          OptionTitleView(color: .orange,    title: "Tips",         icon: "dollarsign.circle.fill"),
        "Depositos" :     OptionTitleView(color: .blue, title: "Depositos",         icon: "tray.and.arrow.down.fill"),
        "Gastos" :        OptionTitleView(color: .red, title: "Gastos",             icon: "cart.fill"),
        "Beneficiarios" : OptionTitleView(color: .green,  title: "Beneficiarios",   icon: "person.line.dotted.person.fill"),
        "Cheques" :       OptionTitleView(color: .blue,   title: "Cheques",         icon: "banknote.fill"),
        "PayRoll" :       OptionTitleView(color: .red,    title: "PayRoll",         icon: "calendar"),
        "Empleados" :     OptionTitleView(color: .orange, title: "Empleados",       icon: "person.2.fill"),
        "Contador" :      OptionTitleView(color: .blue, title: "Contador",          icon: "person.text.rectangle.fill"),
        "Cuenta" :        OptionTitleView(color: .green,  title: "Cuenta",          icon: "person.crop.circle")
    ]
}

fileprivate struct OptionTitleView: View {
    let color: Color
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 35)
                .font(.title2)
            Text(title)
        }
    }
}
