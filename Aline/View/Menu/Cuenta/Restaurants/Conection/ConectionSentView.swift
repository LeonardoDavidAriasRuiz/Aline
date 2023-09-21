//
//  ConectionSentView.swift
//  Aline
//
//  Created by Leonardo on 02/08/23.
//

import SwiftUI

struct ConectionSentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @Binding var conections: [Conection]
    
    let conection: Conection
    
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    var body: some View {
        Sheet(section: .conectionSent) {
            WhiteArea {
                userInfo(title: emailText, value: conection.email)
                Divider()
                userInfo(title: typeText, value: conection.isAdmin ? adminText : emploText)
            }
            
            CancelInvitationButtonWhite(action: cancel)
        }
    }
    
    private func cancel() {
        loading.isLoading = true
        conectionVM.delete(conection) { deleted in
            if deleted {
                conections.removeAll { $0 == self.conection }
                presentationMode.wrappedValue.dismiss()
            } else {
                alertVM.show(.deletingError)
            }
            loading.isLoading = false
        }
    }
    
    private func userInfo(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
