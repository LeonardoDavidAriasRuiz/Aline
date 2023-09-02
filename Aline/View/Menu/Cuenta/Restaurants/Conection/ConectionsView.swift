//
//  ConectionsView.swift
//  Aline
//
//  Created by Leonardo on 27/07/23.
//

import SwiftUI

struct ConectionsView: View {
    
    let restaurant: Restaurant
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var alertType: AlertType = .dataObtainingError
    @State private var alertShowed: Bool = false
    
    @State private var adminUsers: [User] = []
    @State private var emploUsers: [User] = []
    @State private var sentConections: [Conection] = []
    @State private var firstAppear: Bool = true
    
    var body: some View {
        list
            .onAppear(perform: getConections)
            .alertInfo(alertType, showed: $alertShowed)
    }
    
    var list: some View {
        VStack(alignment: .leading) {
            Header("Personas")
            WhiteArea {
                ForEach(adminUsers, id: \.self) { user in
                    NavigationLink(destination: ConectionView(user: user, isAdmin: true)) {
                        HStack {
                            Text(user.name).foregroundStyle(.black)
                            Spacer()
                            Text("Administrador").foregroundStyle(.black.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                        }
                    }
                    if adminUsers.isNotEmpty {
                        Divider()
                    }
                }
                ForEach(emploUsers, id: \.self) { user in
                    NavigationLink(destination: ConectionView(user: user, isAdmin: false)) {
                        HStack {
                            Text(user.name).foregroundStyle(.black)
                            Spacer()
                            Text("Limitado").foregroundStyle(.black.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                        }
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
                            }
                        }
                        Divider()
                    }
                }
                
                NavigationLink(destination: NewConectionView(conections: $sentConections, usersEmails: getUsersEmails(), restaurant: restaurant)) {
                    Text("Invitar").frame(maxWidth: .infinity)
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
                    alertType = .dataObtainingError
                    alertShowed = true
                }
            }
            self.conectionVM.fetchConections(for: self.restaurant.emploUsersIds) { users in
                DispatchQueue.main.async {
                    if let users = users {
                        emploUsers.append(contentsOf: users)
                    } else {
                        alertType = .dataObtainingError
                        alertShowed = true
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
                alertType = .dataObtainingError
                alertShowed = true
            }
        }
        firstAppear = false
    }
}
