//
//  ConectionsListView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct ConectionsListView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var receivedConections: [Conection] = []
    
    @Binding var done: Bool
    @Binding var dataNotObtained: Bool
    
    var body: some View {
        VStack {
            receivedConections.isNotEmpty ? conectionsReceivedList : nil
        }
        .onAppear(perform: getConections)
    }
    
    private var conectionsReceivedList: some View {
        VStack (alignment: .leading) {
            Header("Invitaciones recividas")
            WhiteArea {
                ForEach(receivedConections, id: \.self) { conection in
                    NavigationLink(destination: ConectionsReceivedView(conection: conection, conections: $receivedConections)) {
                        HStack {
                            Text(conection.restaurantName).foregroundStyle(.black)
                            Spacer()
                            Text(conection.isAdmin ? "Administrador" : "Limitado").foregroundStyle(.black.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
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
        done = false
        conectionVM.fetchReceivedConections(for: userVM.user.email) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let conections):
                        receivedConections = conections
                        done = true
                    case .failure:
                        dataNotObtained = true
                        done = true
                }
            }
        }
    }
}


