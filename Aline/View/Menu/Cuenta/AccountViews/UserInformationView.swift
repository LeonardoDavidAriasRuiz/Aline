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
                NavigationLink(destination: EditableName(name: $userVM.user.name, accion: userVM.save)){
                    HStack {
                        Text(nameTitle).foregroundStyle(Color.text)
                        Spacer()
                        Text(userVM.user.name).foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
                Divider()
                NavigationLink(destination: EditableEmail(email: $userVM.user.email, accion: userVM.save)) {
                    HStack {
                        Text(emailTitle).foregroundStyle(Color.text)
                        Spacer()
                        Text(userVM.user.email).foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
            }
        }
    }
}
