//
//  NewConectionView.swift
//  Aline
//
//  Created by Leonardo on 01/08/23.
//

import SwiftUI

struct NewConectionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var loading: LoadingViewModel
    
    @State private var conection: Conection = Conection(restaurant: Restaurant())
    @State private var alertType: AlertType = .dataObtainingError
    @State private var alertShowed: Bool = false
    @State private var isSendButtonDisabled: Bool = true
    
    @Binding var conections: [Conection]
    
    let usersEmails: [String]
    let restaurant: Restaurant
    
    var body: some View {
        Sheet(section: .inviteUser) {
            WhiteArea {
                HStack {
                    Text("Para:")
                    TextField("Email", text: $conection.email)
                        .foregroundStyle(.secondary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .onChange(of: conection.email, isValidEmail)
                }
                Divider()
                Toggle("Administrador", isOn: $conection.isAdmin)
            }
            .alertInfo(alertType, showed: $alertShowed)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { sendButton } }
        }
    }
    
    private var sendButton: some View {
        
        Button("Enviar", action: send).disabled(isSendButtonDisabled)
        
    }
    
    private func send() {
        if usersEmails.contains(conection.email) {
            alertType = .emailAlreadyUsed
            alertShowed = true
        } else {
            loading.isLoading = true
            let name = restaurant.name
            let isAdmin = conection.isAdmin
            let email = conection.email
            let emailInfo: ConectionInvitation = ConectionInvitation()
            conection.restaurantId = restaurant.id
            conection.restaurantName = restaurant.name
            
            conectionVM.save(conection) { conection in
                if let conection = conection {
                    DispatchQueue.main.async {
                        self.conections.append(conection)
                        MailSMTP().send(
                            name: email,
                            email: email,
                            subject: emailInfo.subject,
                            body: emailInfo.body(isAdmin: isAdmin, restaurantName: name)
                        ) { sent in
                            if sent {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                alertShowed = true
                                alertType = .sendingInvitationError
                            }
                        }
                    }
                } else {
                    alertShowed = true
                    alertType = .dataObtainingError
                }
                loading.isLoading = false
            }
        }
    }
    
    private func isValidEmail() {
        withAnimation {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            isSendButtonDisabled = !(emailPredicate.evaluate(with: conection.email) && conection.email.isNotEmpty)
        }
    }
}
