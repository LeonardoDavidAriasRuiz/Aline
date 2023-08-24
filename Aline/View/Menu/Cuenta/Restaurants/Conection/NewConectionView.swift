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
    
    @State private var conection: Conection = Conection(restaurant: Restaurant())
    @State private var isSendButtonDisabled: Bool = true
    @State private var isAlreadyUser: Bool = false
    @State private var dataNotObtained: Bool = false
    @State private var done: Bool = true
    
    @Binding var conections: [Conection]
    
    let usersEmails: [String]
    let restaurant: Restaurant
    
    var body: some View {
        LoadingIfNotReady($done) {
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
            }
            .alertInfo(.dataObtainingError, showed: $dataNotObtained)
            .alertInfo(.emailAlreadyUsed, showed: $isAlreadyUser)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { sendButton } }
        }
    }
    
    private var sendButton: some View {
        
        Button("Enviar", action: send).disabled(isSendButtonDisabled)
        
    }
    
    private func send() {
        done = false
        if usersEmails.contains(conection.email) {
            isAlreadyUser = true
        } else {
            let name = restaurant.name
            let isAdmin = conection.isAdmin
            let email = conection.email
            let emailInfo: ConectionInvitation = ConectionInvitation()
            conection.restaurantId = restaurant.id
            conection.restaurantName = restaurant.name
            
            conectionVM.save(conection) { result in
                switch result {
                    case .success(let record):
                        DispatchQueue.main.async {
                            self.conections.append(Conection(record: record))
                            MailSMTP().send(
                                name: email,
                                email: email,
                                subject: emailInfo.subject,
                                body: emailInfo.body(isAdmin: isAdmin, restaurantName: name)
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                done = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    case .failure:
                        DispatchQueue.main.async {
                            dataNotObtained.toggle()
                            done = true
                        }
                }
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
