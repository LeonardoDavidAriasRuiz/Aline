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
    case login
    case spendings
    case payRoll
    case sales
    case tips
    
    case resturants
    case conectionSent
    case conectionReceived
    case conection
    case editableEmail
    case editableName
    case restaurant
    case inviteUser
    
    var title: String {
        switch self {
            case .account: return "Cuenta"
            case .beneficiaries: return "Beneficiarios"
            case .cashOut: return "Corte"
            case .checks: return "Cheques"
            case .contador: return "Contador"
            case .deposits: return "Depósitos"
            case .employees: return "Empleados"
            case .login: return "Registro"
            case .spendings: return "Gastos"
            case .payRoll: return "PayRoll"
            case .sales: return "Ventas"
            case .tips: return "Propinas"
                
            case .resturants: return "Restaurantes"
            case .conectionReceived: return "Invitación pendiente"
            case .conectionSent: return "Invitación pendiente"
            case .conection: return "Usuario"
            case .editableEmail: return "Email"
            case .editableName: return "Nombre"
            case .restaurant: return "Restaurante"
            case .inviteUser: return "Invitar usuario"
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
            case .login: return Color.green
            case .spendings: return Color.red
            case .payRoll: return Color.red
            case .sales: return Color.green
            case .tips: return Color.orange
                
            case .resturants: return Color.green
            case .conectionReceived: return Color.green
            case .conectionSent: return Color.green
            case .conection: return Color.green
            case .editableEmail: return AccentColor().tint
            case .editableName: return AccentColor().tint
            case .restaurant: return Color.green
            case .inviteUser: return Color.green
        }
    }
}
