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
    
    @State private var isNotAbleToDeleteAlert: Bool = false
    
    let conection: Conection
    
    private let nameText: String = "Nombre"
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    @Binding var conections: [Conection]
    
    var body: some View {
        Sheet(title: "Invitación pendiente") {
            WhiteArea {
                userInfo(title: nameText, value: "---")
                Divider()
                userInfo(title: emailText, value: conection.email)
                Divider()
                userInfo(title: typeText, value: conection.isAdmin ? adminText : emploText)
            }
            
            WhiteArea {
                Button(action: cancelIvitation) {
                    Text("Cancelar invitación")
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                }
            }
            .alertInfo(.invitationCancelingError, show: $isNotAbleToDeleteAlert)
        }
    }
    
    private func cancelIvitation() {
        conectionVM.delete(conection) { result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        conections.removeAll { conection in
                            conection == self.conection
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                case .failure:
                    isNotAbleToDeleteAlert = true
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
