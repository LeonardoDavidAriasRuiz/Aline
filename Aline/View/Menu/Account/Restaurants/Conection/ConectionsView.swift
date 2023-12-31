//
//  ConectionsView.swift
//  Aline
//
//  Created by Leonardo on 27/07/23.
//

import SwiftUI

struct ConectionsView: View {
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var adminUsers: [User] = []
    @State private var emploUsers: [User] = []
    @State private var sentConections: [Conection] = []
    @State private var firstAppear: Bool = true
    
    let restaurant: Restaurant
    
    var body: some View {
        list
            .onAppear(perform: getConections)
    }
    
    var list: some View {
        VStack(alignment: .leading) {
            Header("Personas")
            WhiteArea {
                ForEach(adminUsers, id: \.self) { user in
                    NavigationLink(destination: ConectionView(user: user, isAdmin: true)) {
                        HStack {
                            Text(user.name).foregroundStyle(Color.text)
                            Spacer()
                            Text("Administrador").foregroundStyle(Color.text.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                        }.padding(.vertical, 8)
                    }
                    if adminUsers.isNotEmpty {
                        Divider()
                    }
                }
                ForEach(emploUsers, id: \.self) { user in
                    NavigationLink(destination: ConectionView(user: user, isAdmin: false)) {
                        HStack {
                            Text(user.name).foregroundStyle(Color.text)
                            Spacer()
                            Text("Limitado").foregroundStyle(Color.text.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                        }.padding(.vertical, 8)
                    }
                    if emploUsers.isNotEmpty {
                        Divider()
                    }
                }
                ForEach(sentConections, id: \.self) { conection in
                    if restaurant.id == conection.restaurantId {
                        NavigationLink(destination: ConectionSentView(conections: $sentConections, conection: conection)) {
                            HStack {
                                Text(conection.email).foregroundStyle(Color.blue)
                                Spacer()
                                Text(conection.isAdmin ? "Administrador" : "Limitado").foregroundStyle(Color.blue.secondary)
                                Image(systemName: "chevron.right").foregroundStyle(Color.blue.secondary)
                            }.padding(.vertical, 8)
                        }
                        Divider()
                    }
                }
                
                NavigationLink(destination: NewConectionView(conections: $sentConections, usersEmails: getUsersEmails(), restaurant: restaurant)) {
                    Text("Invitar").frame(maxWidth: .infinity).padding(.vertical, 8)
                }
            }
        }
    }
    
    private func getUsersEmails() -> [String] {
        let adminUserIDs = adminUsers.map { $0.email }
        let emploUserIDs = emploUsers.map { $0.email }
        return adminUserIDs + emploUserIDs
    }
    
    private func getConections() {
        conectionVM.fetchConections(for: restaurant.adminUsersIds) { users in
            DispatchQueue.main.async {
                if let users = users {
                    adminUsers = users
                } else {
                    alertVM.show(.dataObtainingError)
                }
            }
            self.conectionVM.fetchConections(for: self.restaurant.emploUsersIds) { users in
                DispatchQueue.main.async {
                    if let users = users {
                        emploUsers = users
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                }
            }
        }
        if firstAppear {
            getSentConections()
        }
    }
    
    private func getSentConections() {
        self.conectionVM.fetchSentConections(in: restaurant.id) { conections in
            if let conections = conections {
                sentConections = conections
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
        firstAppear = false
    }
}
