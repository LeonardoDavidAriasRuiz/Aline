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
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .cancelingError
    
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
        .alertInfo(alertType, showed: $alertShowed)
    }
    
    private func cancel() {
        conectionVM.delete(conection) { result in
            switch result {
                case .success:
                    conections.removeAll { $0 == self.conection }
                    presentationMode.wrappedValue.dismiss()
                case .failure:
                    alertShowed = true
            }
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
