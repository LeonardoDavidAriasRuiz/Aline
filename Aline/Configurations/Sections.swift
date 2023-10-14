//
//  Section.swift
//  Aline
//
//  Created by Leonardo on 23/08/23.
//

import SwiftUI

enum MenuSubsection {
    case newBeneficiary
    case cashOut
    case newDeposit
    case login
    case spendingTypes
    case newSpending
    case newEmployee
    case tipsReview
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
            case .newBeneficiary: return "Nuevo beneficiario"
            case .cashOut: return "Corte"
            case .newDeposit: return "Nuevo deposito"
            case .login: return "Registro"
            case .spendingTypes: return "Tipos de gastos"
            case .newSpending: return "Nuevo gasto"
            case .newEmployee: return "Nuevo empleado"
            case .tipsReview: return "Revisión de tips"
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
}
