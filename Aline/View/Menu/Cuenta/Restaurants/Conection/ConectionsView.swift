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
    
    @State private var dataNotObtained: Bool = false
    @State private var adminUsers: [User] = []
    @State private var emploUsers: [User] = []
    @State private var sentConections: [Conection] = []
    @State private var firstAppear: Bool = true
    
    var body: some View {
        list
            .onAppear(perform: getConections)
            .alert("No se pudieron obtener los datos.", isPresented: $dataNotObtained, actions: {})
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
                        NavigationLink(destination: ConectionSentView(conection: conection, conections: $sentConections)) {
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
        conectionVM.fetchConections(for: restaurant.adminUsersIds) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let users): self.adminUsers = users
                    case .failure: self.dataNotObtained = true
                }
            }
            self.conectionVM.fetchConections(for: self.restaurant.emploUsersIds) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let users): self.emploUsers.append(contentsOf: users)
                        case .failure: self.dataNotObtained = true
                    }
                }
            }
        }
        if firstAppear {
            getSentConections()
        }
    }
    
    private func getSentConections() {
        self.conectionVM.fetchSentConections(in: restaurant.id) { result in
            switch result {
                case .success(let conections):
                    sentConections = conections
                case .failure:
                    dataNotObtained = true
            }
        }
        firstAppear = false
    }
}
