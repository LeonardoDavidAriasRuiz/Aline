//
//  Buttons.swift
//  Aline
//
//  Created by Leonardo on 23/08/23.
//

import SwiftUI

struct OpenSectionButton: View {
    @Binding var pressed: Bool
    
    let text: String
    
    private let cancelButtonText: String = "Cancelar"
    private let buttonSymbol: String = "plus"
    
    var body: some View {
        
        Button(action: {withAnimation{pressed.toggle()}}) {
            Text(text)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.title2)
                .rotationEffect(Angle(degrees: pressed ? -180 : 0))
                .symbolEffect(.bounce, value: pressed)
        }
    }
}

struct NewButton: View {
    @Binding var pressed: Bool
    
    let newText: String
    let action: () -> Void
    
    private let cancelButtonText: String = "Cancelar"
    private let buttonSymbol: String = "plus"
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(pressed ? cancelButtonText : newText)
                Spacer()
                Image(systemName: buttonSymbol)
                    .font(.title2)
                    .rotationEffect(Angle(degrees: pressed ? 45 : 0))
                    .symbolEffect(.bounce, value: pressed)
            }
        }
    }
}

struct SaveButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Guardar").frame(maxWidth: .infinity)
        }
    }
}

struct CancelButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Cancelar").frame(maxWidth: .infinity)
        }
    }
}

struct UpdateButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Actualizar").frame(maxWidth: .infinity)
        }
    }
}

struct DeleteButton: View {
    @State private var deleteAlertShowed: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: showDeleteAlert) {
            Text("Eliminar").frame(maxWidth: .infinity)
        }
        .alertDelete(showed: $deleteAlertShowed, action: action)
    }
    
    private func showDeleteAlert() {
        deleteAlertShowed = true
    }
}

struct SaveButtonWhite: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            WhiteArea {
                Text("Guardar").frame(maxWidth: .infinity)
            }
        }
    }
}

struct CancelButtonWhite: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            WhiteArea {
                Text("Cancelar").frame(maxWidth: .infinity)
            }
        }
    }
}

struct UpdateButtonWhite: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            WhiteArea {
                Text("Actualizar").frame(maxWidth: .infinity)
            }
        }
    }
}

struct DeleteButtonWhite: View {
    @State private var deleteAlertShowed: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: showDeleteAlert) {
            WhiteArea {
                Text("Eliminar").frame(maxWidth: .infinity)
            }
        }
        .alertDelete(showed: $deleteAlertShowed, action: action)
    }
    
    private func showDeleteAlert() {
        deleteAlertShowed = true
    }
}

struct AcceptButtonWhite: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            WhiteArea {
                Text("Aceptar").frame(maxWidth: .infinity)
            }
        }
    }
}

struct DeclineButtonWhite: View {
    @State private var declineAlertShowed: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: showDeclineAlert) {
            WhiteArea {
                Text("Rechazar").frame(maxWidth: .infinity)
            }
        }
        .alertDecline(showed: $declineAlertShowed, action: action)
        
    }
    
    private func showDeclineAlert() {
        declineAlertShowed = true
    }
}

struct CancelInvitationButtonWhite: View {
    @State private var cancelAlertShowed: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: showDeclineAlert) {
            WhiteArea {
                Text("Cancelar invitación").frame(maxWidth: .infinity)
            }
        }
        .alertCacelInvitation(showed: $cancelAlertShowed, action: action)
    }
    
    private func showDeclineAlert() {
        cancelAlertShowed = true
    }
}
