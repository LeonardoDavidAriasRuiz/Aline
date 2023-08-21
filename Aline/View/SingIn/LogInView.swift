//
//  LogInView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct LogInView: View {
    
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var rc: RestaurantViewModel
    
    @State private var fieldsValidated: Bool = false
    @State private var nameValided: Bool = false
    @State private var emailValided: Bool = false
    @State private var tint: Color = Color.red
    @State private var symbol: Bool = false
    @State private var emailSent: Bool = false
    @State private var editableCode: String = ""
    @State private var rightCode: String = ""
    @State private var wrongCodeAlertActive: Bool = false
    @State private var codeValid: Bool = false
    
    private let title: String = "Registro"
    private let titleFont: Font = Font.system(size: 90)
    private let nameTitle: String = "Nombre"
    private let emailTitle: String = "Email"
    private let xmarkImageName: String = "xmark.circle.fill"
    private let checkmarkImageName: String = "checkmark.circle.fill"
    private let saveButtonText: String = "Guardar"
    private let verifyEmailText: String = "Verificar email"
    
    
    var body: some View {
        Sheet(title: title) {
            Text(title)
                .bold()
                .font(titleFont)
            WhiteArea {
                HStack {
                    Text(nameTitle)
                    TextField(nameTitle, text: self.$userVM.user.name)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.words)
                        .keyboardType(.alphabet)
                        .autocorrectionDisabled(true)
                        .onChange(of: self.userVM.user.name, isValidName)
                    Image(systemName: nameValided ? checkmarkImageName : xmarkImageName)
                        .foregroundStyle(nameValided ? Color.green : Color.red)
                        .font(.title2)
                        .symbolEffect(.bounce, value: nameValided)
                }
                Divider()
                HStack {
                    Text(emailTitle)
                    TextField(emailTitle, text: self.$userVM.user.email)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .onChange(of: self.userVM.user.email, isValidEmail)
                    Image(systemName: emailValided ? checkmarkImageName : xmarkImageName)
                        .foregroundStyle(emailValided ? Color.green : Color.red)
                        .font(.title2)
                        .symbolEffect(.bounce, value: emailValided)
                }
            }
            if fieldsValidated {
                HStack {
                    if fieldsValidated, !codeValid {
                        if !emailSent {
                            Button(verifyEmailText, action: verifyEmail)
                        } else {
                            Button("Cancelar", action: cancelVerification)
                            TextField("Código", text: $editableCode)
                                .padding(5)
                                .foregroundStyle(Color.black)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .onChange(of: editableCode, validateCode)
                        }
                    } else {
                        Button(saveButtonText, action: createCustomUser)
                    }
                }
                .modifier(ButtonColor(color: emailSent ? codeValid ? Color.green : Color.red : Color.blue ))
                .alertInfo(.verificationCodeMismatch, show: $wrongCodeAlertActive)
            }
        }
    }
    
    private func cancelVerification() {
        emailSent = false
    }
    
    private func verifyEmail() {
        let code = Int.random(in: 100000...999999)
        let emailInfo: VerifyLoginEmail = VerifyLoginEmail()
        MailSMTP().send(to: userVM.user, subject: emailInfo.subject, body: emailInfo.body(code: "\(code)"))
        withAnimation {
            rightCode = String(code)
            emailSent = true
        }
    }
    
    private func validateCode() {
        withAnimation {
            if editableCode.count == 6 {
                if editableCode == rightCode {
                    codeValid = true
                } else {
                    codeValid = false
                    wrongCodeAlertActive = true
                }
            }
        }
    }
    
    private func createCustomUser() {
        userVM.save()
        userVM.loginStatus = .loggedIn
    }
    
    private func isValidFields() {
        withAnimation {
            if nameValided,
               emailValided {
                tint = Color.green
                fieldsValidated = true
                return
            }
            tint = Color.red
            fieldsValidated = false
        }
    }
    
    private func isValidName() {
        withAnimation {
            if self.userVM.user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                nameValided = false
                isValidFields()
                return
            } else {
                let nameRegex = "^[a-zA-Z ]+$"
                let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
                nameValided = namePredicate.evaluate(with: self.userVM.user.name)
                isValidFields()
            }
        }
    }
    
    private func isValidEmail() {
        withAnimation {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            emailValided = emailPredicate.evaluate(with: self.userVM.user.email) && !self.userVM.user.email.isEmpty
            isValidFields()
        }
    }
}

