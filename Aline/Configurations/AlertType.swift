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
    
    func alertDecline(showed: Binding<Bool>, action: @escaping () -> Void)  -> some View {
        self.alert(isPresented: showed) {
            Alert(title: Text(AlertType.confirmDecline.message),
                  primaryButton: .destructive(Text("Rechazar"), action: action),
                  secondaryButton: .cancel(Text("Cancelar")))
        }
    }
    
    func alertExport(showed: Binding<Bool>, action: @escaping () -> Void)  -> some View {
        self.alert(isPresented: showed) {
            Alert(title: Text(AlertType.confirmExport.message),
                  primaryButton: .default(Text("Exportar"), action: action),
                  secondaryButton: .cancel(Text("Cancelar")))
        }
    }
    
    func alertCacelInvitation(showed: Binding<Bool>, action: @escaping () -> Void)  -> some View {
        self.alert(isPresented: showed) {
            Alert(title: Text(AlertType.confirmCancelingInvitation.message),
                  primaryButton: .destructive(Text("Cancelar invitación"), action: action),
                  secondaryButton: .cancel(Text("No cancelar")))
        }
    }
}

enum AlertType {
    case noiCloudConnected
    case dataObtainingError
    case crearingError
    case updatingError
    case deletingError
    case decliningError
    case cancelingError
    case sendingInvitationError
    case sendingVerificationCodeError
    case confirmDelete
    case confirmDecline
    case confirmExport
    case verificationCodeResent
    case verificationCodeMismatch
    case signingInError
    case emailAlreadyUsed
    case confirmCancelingInvitation
    case exportationConfirmation
    case exportationError
    
    
    
    var message: String {
        switch self {
            case .noiCloudConnected:
                return "El dispositivo no esta connectado a iCloud."
            case .dataObtainingError:
                return "No se pudieron obtener los datos."
            case .crearingError:
                return "Sucedió un error al tratar de crearlo."
            case .updatingError:
                return "Sucedió un error al tratar de actualizarlo."
            case .deletingError:
                return "Sucedió un error al tratar de eliminar."
            case .decliningError:
                return "Sucedió un error al tratar de rechazar."
            case .cancelingError:
                return "Sucedió un error al tratar de cancelar"
            case .sendingInvitationError:
                return "Sucedió un error al enviar el email de invitación pero si se creo la invitación."
            case .sendingVerificationCodeError:
                return "Sucedió un error al tratar de enviar el código por correo."
            case .confirmDelete:
                return "¿Estás seguro de que lo quieres eliminar?"
            case .confirmDecline:
                return "¿Estás seguro de que la quieres rechazar?"
            case .confirmExport:
                return "¿Estás seguro de que quieres exportar los datos?"
            case .verificationCodeResent:
                return "El código se ha reenviado."
            case .verificationCodeMismatch:
                return "El código de verificación no coincide con el que se envió."
            case .signingInError:
                return "No se pudo iniciar sesión."
            case .emailAlreadyUsed:
                return "Este email ya está registrado en el restaurante."
            case .confirmCancelingInvitation:
                return "¿Estás seguro de que quieres cancelar la invitación?"
            case .exportationConfirmation:
                return "Se envió correctamente la información."
            case .exportationError:
                return "Sucedió un error al tratar de enviar la información."
        }
    }
}
