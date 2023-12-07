//
//  ConectionsListView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct ConectionsListView: View {
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var receivedConections: [Conection] = []
    
    @Binding var isLoading: Bool
    
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
                    NavigationLink(destination: ConectionReceivedView(conections: $receivedConections, conection: conection)) {
                        HStack {
                            Text(conection.restaurantName).foregroundStyle(Color.text)
                            Spacer()
                            Text(conection.isAdmin ? "Administrador" : "Limitado").foregroundStyle(Color.text.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                        }.padding(.vertical, 8)
                    }
                    if conection != receivedConections.last {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func getConections() {
        withAnimation {
            isLoading = true
            conectionVM.fetchReceivedConections(for: userVM.user.email) { conections in
                DispatchQueue.main.async {
                    if let conections = conections {
                        receivedConections = conections
                    } else {
                        alertVM.show(.dataObtainingError)
                    }
                    isLoading = false
                }
            }
        }
    }
}


