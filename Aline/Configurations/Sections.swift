//
//  Section.swift
//  Aline
//
//  Created by Leonardo on 23/08/23.
//

import SwiftUI

enum MenuSection {
    case account
    case beneficiaries
    case cashOut
    case checks
    case contador
    case deposits
    case employees
    case spendings
    case payRoll
    case sales
    case tips
    
    var title: String {
        switch self {
            case .account: return "Cuenta"
            case .beneficiaries: return "Beneficiarios"
            case .cashOut: return "Corte"
            case .checks: return "Cheques"
            case .contador: return "Contador"
            case .deposits: return "Depósitos"
            case .employees: return "Empleados"
            case .spendings: return "Gastos"
            case .payRoll: return "PayRoll"
            case .sales: return "Ventas"
            case .tips: return "Propinas"
        }
    }
    
    var color: Color {
        switch self {
            case .account: return Color.green
            case .beneficiaries: return Color.green
            case .cashOut: return Color.red
            case .checks: return Color.blue
            case .contador: return Color.blue
            case .deposits: return Color.blue
            case .employees: return Color.orange
            case .spendings: return Color.red
            case .payRoll: return Color.red
            case .sales: return Color.green
            case .tips: return Color.orange
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
            case .account: AccountView()
            case .beneficiaries: BeneficiariosView()
            case .cashOut: CashOutView()
            case .checks: ChecksView()
            case .contador: ContadorView()
            case .deposits: DepositsView()
            case .employees: EmployeesView()
            case .spendings: SpendingsView()
            case .payRoll: PayRollView()
            case .sales: SalesView()
            case .tips: TipsView()
        }
    }
}

enum MenuSubsection {
    case conectionReceived
    case resturants
    
    var title: String {
        switch self {
            case .conectionReceived: return "Invitación pendiente"
            case .resturants: return "Restaurantes"
        }
    }
    
    var color: Color {
        switch self {
            case .conectionReceived: return Color.green
            case .resturants: return Color.green
        }
    }
}
