//
//  ConectionView.swift
//  Aline
//
//  Created by Leonardo on 27/07/23.
//

import SwiftUI

struct ConectionView: View {
    let user: User
    let isAdmin: Bool
    
    private let nameText: String = "Nombre"
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    var body: some View {
        Sheet(section: .conection) {
            WhiteArea {
                userInfo(title: nameText, value: user.name)
                Divider()
                userInfo(title: emailText, value: user.email)
                Divider()
                userInfo(title: typeText, value: isAdmin ? adminText : emploText)
            }
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
