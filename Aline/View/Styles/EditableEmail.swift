//
//  EditableEmail.swift
//  Aline
//
//  Created by Leonardo on 01/08/23.
//

import SwiftUI

struct EditableEmail: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var email: String
    let accion: () -> Void
    
    @State private var isCodeValidationAreaVisible: Bool = false
    @State private var isWrongCodeAlertActive: Bool = false
    @State private var isEmailWithCodeResent: Bool = false
    @State private var isUpdateButtonDisabled: Bool = true
    @State private var isEmailWithCodeSent: Bool = false
    
    @State private var editableCode: String = ""
    @State private var codeSent: String = ""
    @State private var newEmail: String = ""
    
    var body: some View {
        Sheet(title: "Email") {
            editableEmailArea
            isCodeValidationAreaVisible ? codeValidationArea : nil
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {updateButton})
        }
    }
    
    private var editableEmailArea: some View {
        WhiteArea {
            TextField("Email", text: $newEmail)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .onAppear(perform: onApper)
                .onChange(of: newEmail, isValidEmail)
        }
    }
    
    private var codeValidationArea: some View {
        HStack {
            if isEmailWithCodeSent {
                Button("Reenviar código", action: resendEmailWithCode)
                TextField("Código", text: $editableCode)
                    .padding(5)
                    .foregroundStyle(Color.black)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .onChange(of: editableCode, validateCode)
            } else {
                Button("Verificar email", action: sendEmailWithCode)
            }
        }
        .modifier(ButtonColor(color: isEmailWithCodeSent ? Color.red : Color.blue ))
        .alertInfo(.verificationCodeResent, show: $isEmailWithCodeResent)
        .alertInfo(.verificationCodeMismatch, show: $isWrongCodeAlertActive)
    }
    
    private var updateButton: some View {
        Button("Actualizar", action: update)
            .disabled(isUpdateButtonDisabled)
    }
    
    private func resendEmailWithCode() {
        isEmailWithCodeResent = true
        sendEmailWithCode()
    }
    
    private func sendEmailWithCode() {
        let code = Int.random(in: 100000...999999)
        let emailInfo: VerifyNewEmail = VerifyNewEmail()
        MailSMTP().send(name: newEmail, email: newEmail, subject: emailInfo.subject, body: emailInfo.body(code: String(code)))
        withAnimation {
            codeSent = String(code)
            isEmailWithCodeSent = true
        }
    }
    
    private func validateCode() {
        withAnimation {
            if editableCode.count == 6,
               editableCode == codeSent {
                isCodeValidationAreaVisible = false
                isUpdateButtonDisabled = false
                editableCode = ""
                isEmailWithCodeSent = false
            } else if editableCode.count == 6 {
                isUpdateButtonDisabled = true
                isWrongCodeAlertActive = true
                editableCode = ""
            }
        }
    }
    
    private func onApper() {
        newEmail = email
    }
    
    private func isValidEmail() {
        withAnimation {
            isUpdateButtonDisabled = true
            editableCode = ""
            isEmailWithCodeSent = false
            codeSent = ""
            
            if email != newEmail {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
                isCodeValidationAreaVisible = (emailPredicate.evaluate(with: newEmail) && newEmail.isNotEmpty)
            } else {
                isCodeValidationAreaVisible = false
            }
        }
    }
    
    private func update() {
        self.presentationMode.wrappedValue.dismiss()
        email = newEmail
        accion()
    }
}
