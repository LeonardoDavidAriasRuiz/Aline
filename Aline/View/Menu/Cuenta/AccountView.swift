//
//  Cuenta.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var receivedConections: [Conection] = []
    @State private var dataNotObtained: Bool = false
    @State private var done: Bool = false
    @State private var restaurantConections: [String : Restaurant] = [:]
    
    private let title = "Cuenta"
    private let tint = Color.green
    private let nameTitle = "Nombre"
    private let emailTitle = "Email"
    private let pinTitle = "Pin"
    
    var body: some View {
        LoadingIfNotReady(done: $done) {
            Sheet(title: title) {
                userInfo
                restaurantType.padding(.vertical, 20)
                receivedConections.isNotEmpty ? receivedConectionsArea : nil
            }
            .tint(tint)
            .onAppear(perform: accentColor.green)
            .onAppear(perform: getConections)
            .onAppear(perform: getRestaurantInfoFromConection)
            .alert("No se pudieron obtener los datos.", isPresented: $dataNotObtained, actions: {})
        }
    }
    
    private var userInfo: some View {
        VStack(alignment: .leading) {
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
    
    private var restaurantType: some View {
        VStack(alignment: .leading) {
            Header("Restaurantes").font(.footnote)
            WhiteArea {
                NavigationLink(destination: RestaurantsView(type: .admin)) {
                    HStack {
                        Text("Administrativos")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                Divider()
                NavigationLink(destination: RestaurantsView(type: .emplo)) {
                    HStack {
                        Text("Corte")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            Footer("Restaurantes vinculados a la cuenta.")
        }
    }
    
    private var receivedConectionsArea: some View {
        VStack (alignment: .leading) {
            Header("Invitaciones recividas")
            WhiteArea {
                ForEach(receivedConections, id: \.self) { conection in
                    NavigationLink(destination: ConectionsReceivedView(conection: conection, conections: $receivedConections)) {
                        HStack {
                            Text(restaurantConections[conection.restaurantId]?.name ?? "Not Found").foregroundStyle(Color.orange)
                            Spacer()
                            Text(conection.isAdmin ? "Administrador" : "Limitado").foregroundStyle(Color.orange.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(Color.orange.secondary)
                        }
                    }
                    if conection != receivedConections.last {
                        Divider()
                    }
                }
            }
            Footer("Aquí estan las invitaciones que recives para administrar un nuevo restaurante.")
        }
    }
    
    private func getConections() {
        conectionVM.fetchReceivedConections(for: userVM.user.email, in: restaurantVM.restaurant.id) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let conections): self.receivedConections = conections
                    case .failure: self.dataNotObtained = true
                }
            }
        }
    }
    
    private func getRestaurantInfoFromConection() {
        let restaurantsIds: [String] = receivedConections.map { connection in
            return connection.restaurantId
        }
        restaurantVM.fetchRestaurantsDictionary(for: restaurantsIds) { result in
            switch result {
                case .success(let restaurants): self.restaurantConections = restaurants; self.done = true; 
                case .failure: self.dataNotObtained = true; self.done = true
            }
        }
    }
}
