//
//  MenuView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var loadingVM: LoadingViewModel
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @State private var changingRestaurant: Bool = false
    
    var body: some View {
        Loading($loadingVM.isLoading) {
            if !changingRestaurant {
                NavigationView {
                    menuList
                        .background(Color.background)
                        .navigationTitle("Menu")
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                restaurantPicker
                            }
                        }
                    SalesView()
                }
            }
        }
        .alertInfo(alertVM.alertType, showed: $alertVM.alertInfoShowed)
        .onChange(of: restaurantM.currentId, setRestaurant)
    }
    
    private var restaurantPicker: some View {
        VStack {
            if let adminRts = restaurantM.adminRts,
               let emploRts = restaurantM.emploRts {
                let restaurants = adminRts + emploRts
                if adminRts.isNotEmpty || emploRts.isNotEmpty {
                    Picker("Restaurantes", selection: $restaurantM.currentId) {
                        ForEach(restaurants) { restaurant in
                            Text(restaurant.name).tag(restaurant.id)
                        }
                    }
                }
            }
        }
    }
    
    private var menuList: some View {
        List {
            MenuOption(title: "Tips Día", content: { TipsCashOutView() })
            if let adminRts = restaurantM.adminRts,
               let restaurant = restaurantM.restaurant {
                if adminRts.contains(restaurant) {
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
            }
            MenuOption(title: "Cuenta", content: { AccountView() })
        }
    }
    
    private func setRestaurant() {
        withAnimation {
            changingRestaurant = true
            loadingVM.isLoading = true
            if let adminRts = restaurantM.adminRts,
               let emploRts = restaurantM.emploRts {
                let restaurants = adminRts + emploRts
                restaurantM.restaurant = restaurants.first(where: { $0.id == restaurantM.currentId })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadingVM.isLoading = false
                changingRestaurant = false
            }
        }
    }
}

fileprivate struct MenuOption<Content: View>: View {
    @EnvironmentObject private var accentColor: AccentColor
    let title: String
    let content: () -> Content
    
    var body: some View {
        NavigationLink( destination: content().onAppear(perform: setAccentColor), label: {options[title]})
    }
    
    private let options = [
        "Tips Día" :      OptionTitleView(color: .red,  title: "Tips Día",             icon: "list.bullet.clipboard.fill"),
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
    
    private func setAccentColor() {
        accentColor.set(options[title]?.color ?? Color.green)
    }
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
