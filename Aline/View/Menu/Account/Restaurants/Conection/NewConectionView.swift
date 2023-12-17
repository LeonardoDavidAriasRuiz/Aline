//
//  NewConectionView.swift
//  Aline
//
//  Created by Leonardo on 01/08/23.
//

import SwiftUI

struct NewConectionView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var conection: Conection = Conection(restaurant: Restaurant())
    @State private var isSendButtonDisabled: Bool = true
    
    @Binding var conections: [Conection]
    
    let usersEmails: [String]
    let restaurant: Restaurant
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .inviteUser, isLoading: $isLoading) {
            WhiteArea {
                HStack {
                    Text("Para:")
                    TextField("Email", text: $conection.email)
                        .foregroundStyle(.secondary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .onChange(of: conection.email, isValidEmail)
                }.padding(.vertical, 8)
                Divider()
                Toggle("Administrador", isOn: $conection.isAdmin).padding(.vertical, 8)
            }
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { sendButton } }
        }
        .onChange(of: restaurantM.currentId, {dismiss()})
        .onChange(of: menuSection.section, {dismiss()})
    }
    
    private var sendButton: some View {
        
        Button("Enviar", action: send).disabled(isSendButtonDisabled)
        
    }
    
    private func send() {
        if usersEmails.contains(conection.email) {
            alertVM.show(.emailAlreadyUsed)
        } else {
            isLoading = true
            let name = restaurant.name
            let isAdmin = conection.isAdmin
            let email = conection.email
            let emailInfo: ConectionInvitation = ConectionInvitation()
            conection.restaurantId = restaurant.id
            conection.restaurantName = restaurant.name
            
            conectionVM.save(conection) { saved in
                if saved {
                    DispatchQueue.main.async {
                        self.conections.append(conection)
                        MailSMTP().send(
                            name: email,
                            email: email,
                            subject: emailInfo.subject,
                            body: emailInfo.body(isAdmin: isAdmin, restaurantName: name)
                        ) {
                            dismiss()
                        } ifNot: {
                            alertVM.show(.sendingInvitationError)
                        } alwaysDo: {}
                    }
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
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
