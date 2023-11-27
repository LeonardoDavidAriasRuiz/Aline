//
//  MenuView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var changingRestaurant: Bool = false
    @State private var isLoading: Bool = false
    @State private var section: Section = .none
    
    var body: some View {
        HStack(spacing: 0) {
            menuList
            Divider()
            NavigationStack {
                AnyView(
                    self.section.destination
                        .onAppear(perform: {accentColor.set(self.section.color)})
                )
                .navigationTitle(self.section.title)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HideKeyboardToolbarButton()
                    }
                }
            }.tint(self.section.color)
        }
        .background(Color.background)
        .alertInfo(alertVM.alertType, showed: $alertVM.alertInfoShowed)
        .onChange(of: restaurantM.currentId, setRestaurant)
    }
    
    private var menuList: some View {
        VStack {
            restaurantPicker
            ScrollView {
                VStack {
                    MenuViewSection(section: .tipsCashOutView)
                    if let adminRts = restaurantM.adminRts, let restaurant = restaurantM.restaurant, adminRts.contains(restaurant) {
                        MenuViewSection(section: .sales)
                        MenuViewSection(section: .tips)
                        MenuViewSection(section: .deposits)
                        MenuViewSection(section: .spendings)
                        MenuViewSection(section: .beneficiaries)
                        MenuViewSection(section: .checks)
                        MenuViewSection(section: .payroll)
                        MenuViewSection(section: .employees)
                    }
                }.padding(.horizontal, 7)
            }
            MenuViewSection(section: .account).padding(.bottom, 7)
        }
        .frame(width: 70)
    }
    
    private var restaurantPicker: some View {
        VStack {
            if let adminRts = restaurantM.adminRts,
               let emploRts = restaurantM.emploRts {
                let restaurants = adminRts + emploRts
                if adminRts.isNotEmpty || emploRts.isNotEmpty {
                    Menu {
                        Picker("Restaurantes", selection: $restaurantM.currentId.animation()) {
                            ForEach(restaurants) { restaurant in
                                Text(restaurant.name).tag(restaurant.id)
                            }
                        }.pickerStyle(.inline)
                    } label: {
                        if let restaurant = restaurantM.restaurant {
                            Circle()
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(getGradient())
                                .overlay {
                                    Text(getInitials(from: restaurant.name))
                                        .bold()
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func setRestaurant() {
        withAnimation {
            if let adminRts = restaurantM.adminRts, let emploRts = restaurantM.emploRts {
                let restaurants = adminRts + emploRts
                restaurantM.restaurant = restaurants.first(where: { $0.id == restaurantM.currentId })
                updateRecords()
            }
        }
    }
    
    func MenuViewSection(section: Section) -> some View {
        Button {
            withAnimation {
                self.section =  self.section == section ? .none : section
            }
        } label: {
            HStack {
                section.icon
                    .padding(.horizontal, 4)
                    .foregroundStyle(self.section == section ? .white : section.color)
                    .font(.title2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(self.section.color.opacity(self.section == section ? 1 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func getInitials(from string: String) -> String {
        let words = string.split(separator: " ")
        let initials = words.compactMap { $0.first }
        return initials.map { String($0) }.joined()
    }
    
    private func getGradient() -> Gradient {
        switch accentColor.tint {
            case Color.green:
                Gradient(colors: [Color.green, Color.orange])
            case Color.blue:
                Gradient(colors: [Color.blue, Color.red])
            case Color.red:
                Gradient(colors: [Color.red, Color.green])
            case Color.orange:
                Gradient(colors: [Color.orange, Color.blue])
            default:
                Gradient(colors: [Color.blue, Color.red])
        }
    }
    
    private func updateRecords() {
        withAnimation {
            isLoading = true
            employeeVM.fetch(restaurantId: restaurantM.currentId) { fetched in
                if !fetched {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
}




enum Section {
    case none
    case tipsCashOutView
    case sales
    case tips
    case deposits
    case spendings
    case beneficiaries
    case checks
    case payroll
    case employees
    case account
    
    var title: String {
        switch self {
            case .none: ""
            case .tipsCashOutView: "Tips del día"
            case .sales: "Ventas"
            case .tips: "Tips"
            case .deposits: "Depositos"
            case .spendings: "Gastos"
            case .beneficiaries: "Beneficiarios"
            case .checks: "Cheques"
            case .payroll: "Payroll"
            case .employees: "Empleados"
            case .account: "Cuenta"
        }
    }
    
    var color: Color {
        switch self {
            case .none: Color.green
            case .tipsCashOutView: Color.red
            case .sales: Color.green
            case .tips: Color.orange
            case .deposits: Color.blue
            case .spendings: Color.red
            case .beneficiaries: Color.green
            case .checks: Color.blue
            case .payroll: Color.red
            case .employees: Color.orange
            case .account: Color.green
        }
    }
    
    var destination: any View {
        switch self {
            case .none: WelcomeView()
            case .tipsCashOutView: TipsCashOutView()
            case .sales: SalesView()
            case .tips: TipsView()
            case .deposits: DepositsView()
            case .spendings: SpendingsView()
            case .beneficiaries: BeneficiariosView()
            case .checks: ChecksView()
            case .payroll: PayrollView()
            case .employees: EmployeesView()
            case .account: AccountView()
        }
    }
    
    var icon: Image {
        switch self {
            case .none: Image("")
            case .tipsCashOutView: Image(systemName: "list.bullet.clipboard.fill")
            case .sales: Image(systemName: "chart.bar.xaxis")
            case .tips: Image(systemName: "dollarsign.circle.fill")
            case .deposits: Image(systemName: "tray.full.fill")
            case .spendings: Image(systemName: "cart.fill")
            case .beneficiaries: Image(systemName: "person.line.dotted.person.fill")
            case .checks: Image(systemName: "banknote.fill")
            case .payroll: Image(systemName: "calendar")
            case .employees: Image(systemName: "person.3.fill")
            case .account: Image(systemName: "person.crop.circle.fill")
        }
    }
}

