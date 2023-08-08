//
//  UserInformationView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct UserInformationView: View {
    @EnvironmentObject private var userVM: UserViewModel
    
    private let nameTitle = "Nombre"
    private let emailTitle = "Email"
    
    var body: some View {
        VStack {
            WhiteArea {
                NavigationLink(destination: EditableName(name: $userVM.user.name, accion: userVM.save), label: {
                    HStack {
                        Text(nameTitle).foregroundStyle(.black)
                        Spacer()
                        Text(userVM.user.name).foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                })
                Divider()
                NavigationLink(destination: EditableEmail(email: $userVM.user.email, accion: userVM.save), label: {
                    HStack {
                        Text(emailTitle).foregroundStyle(.black)
                        Spacer()
                        Text(userVM.user.email).foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                })
            }
        }
    }
}
