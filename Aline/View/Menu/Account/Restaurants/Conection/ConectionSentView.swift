//
//  ConectionSentView.swift
//  Aline
//
//  Created by Leonardo on 02/08/23.
//

import SwiftUI

struct ConectionSentView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var conections: [Conection]
    
    let conection: Conection
    
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .conectionSent, isLoading: $isLoading) {
            WhiteArea {
                userInfo(title: emailText, value: conection.email)
                Divider()
                userInfo(title: typeText, value: conection.isAdmin ? adminText : emploText)
            }
            CancelInvitationButtonWhite(action: cancel)
        }
        .onChange(of: restaurantM.currentId, {dismiss()})
        .onChange(of: menuSection.section, {dismiss()})
    }
    
    private func cancel() {
        isLoading = true
        conectionVM.delete(conection) { deleted in
            if deleted {
                conections.removeAll { $0 == self.conection }
                dismiss()
            } else {
                alertVM.show(.deletingError)
            }
            isLoading = false
        }
    }
    
    private func userInfo(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }.padding(.vertical, 8)
    }
}
