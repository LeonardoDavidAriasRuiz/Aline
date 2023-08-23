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
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .dataObtainingError
    
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack {
            receivedConections.isNotEmpty ? conectionsReceivedList : nil
        }
        .alertInfo(alertType, showed: $alertShowed)
        .onAppear(perform: getConections)
    }
    
    private var conectionsReceivedList: some View {
        VStack (alignment: .leading) {
            Header("Invitaciones recividas")
            WhiteArea {
                ForEach(receivedConections, id: \.self) { conection in
                    NavigationLink(destination: ConectionReceivedView(conection: conection, conections: $receivedConections)) {
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
        }
    }
    
    private func getConections() {
        isLoading = true
        conectionVM.fetchReceivedConections(for: userVM.user.email) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let conections):
                        receivedConections = conections
                        isLoading = false
                    case .failure:
                        alertShowed = true
                        isLoading = false
                }
            }
        }
    }
}


