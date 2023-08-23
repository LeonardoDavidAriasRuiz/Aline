//
//  Alerts.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

extension View {
    func alertInfo(_ alertType: AlertType, showed: Binding<Bool>) -> some View {
        self.alert(alertType.message, isPresented: showed, actions: {})
    }
    
    func alertDelete(showed: Binding<Bool>, action: @escaping () -> Void)  -> some View {
        self.alert(isPresented: showed) {
            Alert(title: Text(AlertType.confirmDelete.message),
                  primaryButton: .destructive(Text("Eliminar"), action: action),
                  secondaryButton: .cancel(Text("Cancelar")))
        }
    }
}

enum AlertType {
    case dataObtainingError
    case crearingError
    case updatingError
    case deletingError
    case confirmDelete
    case invitationRejectingError
    case invitationCancelingError
    case verificationCodeResent
    case verificationCodeMismatch
    case signingInError
    case emailAlreadyUsed
    
    
    var message: String {
        switch self {
            case .dataObtainingError:
                return "No se pudieron obtener los datos."
            case .crearingError:
                return "Sucedió un error al tratar de crearlo."
            case .updatingError:
                return "Sucedió un error al tratar de actualizarlo."
            case .deletingError:
                return "Sucedió un error al tratar de eliminar."
            case .confirmDelete:
                return "¿Estás seguro de que lo quieres eliminar?"
            case .invitationRejectingError:
                return "No se pudo rechazar la invitación, intenta más tarde."
            case .invitationCancelingError:
                return "No se pudo cancelar la invitación, intenta más tarde."
            case .verificationCodeResent:
                return "El código se ha reenviado."
            case .verificationCodeMismatch:
                return "El código de verificación no coincide con el que se envió."
            case .signingInError:
                return "No se pudo iniciar sesión."
            case .emailAlreadyUsed:
                return "Este email ya está registrado en el restaurante."
        }
    }
}
