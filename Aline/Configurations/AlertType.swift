//
//  Alerts.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

extension View {
    func alertAline(_ alertType: AlertType, show: Binding<Bool>) -> some View {
        self.alert(alertType.message, isPresented: show, actions: {})
    }
    
    func alertAline(_ alertType: AlertType, show: Binding<Bool>, action: () -> Void)  -> some View {
        self.alert(isPresented: show) {
            AlertType(title: alertType.message,
                  primaryButton: .destructive(Text("Eliminar"), action: action),
                  secondaryButton: .cancel("Cancelar"))
        }
    }
}

enum AlertType {
    case dataNotObtained
    case notSaved
    case notDeleted
    case deleteEmployeeAlert(name: String, lastName: String)
    
    var message: String {
        switch self {
            case .dataNotObtained:
                return "No se pudieron obtener los datos"
            case .notSaved:
                return "Sucedio un error al tratar de guardarlo"
            case .notDeleted:
                return "Sucedio un error al tratar de eliminarlo"
            case .deleteEmployeeAlert(let name, let lastName):
                return "Estas seguro de que quieres eliminar a \(name) \(lastName)"
        }
    }
}
    
    

