//
//  MenuView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @State private var changingRestaurant: Bool = false
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Loading($isLoading) {
            if !changingRestaurant {
                NavigationSplitView {
                    menuList
                        .background(Color.background)
                        .navigationTitle("Menu")
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                restaurantPicker
                            }
                        }
                }  detail: {
                    
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
            MenuViewSection(title: "Tips del día", tint: Color.red, icon: "list.bullet.clipboard.fill", destination: TipsCashOutView())
            if let adminRts = restaurantM.adminRts, let restaurant = restaurantM.restaurant, adminRts.contains(restaurant) {
                MenuViewSection(title: "Ventas",        tint: Color.green,  icon: "chart.bar.xaxis",                destination: SalesView())
                MenuViewSection(title: "Tips",          tint: Color.orange, icon: "dollarsign.circle.fill",         destination: TipsView())
                MenuViewSection(title: "Depositos",     tint: Color.blue,   icon: "tray.full.fill",                 destination: DepositsView())
                MenuViewSection(title: "Gastos",        tint: Color.red,    icon: "cart.fill",                      destination: SpendingsView())
                MenuViewSection(title: "Beneficiarios", tint: Color.green,  icon: "person.line.dotted.person.fill", destination: BeneficiariosView())
                MenuViewSection(title: "Cheques",       tint: Color.blue,   icon: "banknote.fill",                  destination: ChecksView())
                MenuViewSection(title: "Payroll",       tint: Color.red,    icon: "calendar",                       destination: PayrollView())
                MenuViewSection(title: "Empleados",     tint: Color.orange, icon: "person.3.fill",                  destination: EmployeesView())
                MenuViewSection(title: "Contador",      tint: Color.blue,   icon: "person.text.rectangle.fill",     destination: AccountantView())
            }
            MenuViewSection(title: "Cuenta",     tint: Color.green,          icon: "person.crop.circle", destination: AccountView())
        }
    }
    
    private func setRestaurant() {
        withAnimation {
            changingRestaurant = true
            isLoading = true
            if let adminRts = restaurantM.adminRts, let emploRts = restaurantM.emploRts {
                let restaurants = adminRts + emploRts
                restaurantM.restaurant = restaurants.first(where: { $0.id == restaurantM.currentId })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
                changingRestaurant = false
            }
        }
    }
    
    func MenuViewSection(title: String, tint: Color, icon: String, destination: some View) -> some View {
        NavigationLink {
            destination
                .tint(tint)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .onAppear(perform: {
                    accentColor.set(tint)
                })
        } label: {
            Label(
                title: { Text(title) },
                icon: { Image(systemName: icon).foregroundStyle(tint) }
            )
        }
    }
}


