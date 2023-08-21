//
//  ConectionReceivedView.swift
//  Aline
//
//  Created by Leonardo on 02/08/23.
//

import SwiftUI

struct ConectionReceivedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var restaurant: Restaurant = Restaurant()
    @State private var isNotAbleToDeleteAlert: Bool = false
    @State private var dataNotObtained: Bool = false
    @State private var done: Bool = false
    
    let conection: Conection
    
    private let nameText: String = "Nombre"
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    @Binding var conections: [Conection]
    
    var body: some View {
        LoadingIfNotReady($done) {
            Sheet(title: "Invitación pendiente") {
                WhiteArea {
                    userInfo(title: nameText, value: restaurant.name)
                    Divider()
                    userInfo(title: emailText, value: restaurant.email.isNotEmpty ? restaurant.email : "---")
                    Divider()
                    userInfo(title: typeText, value: conection.isAdmin ? adminText : emploText)
                }
                .onAppear(perform: getRestaurantInformation)
                .alertInfo(.dataObtainingError, show: $dataNotObtained)
                
                WhiteArea {
                    Button(action: acceptInvitation) {
                        Text("Aceptar")
                            .foregroundStyle(Color.green)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                WhiteArea {
                    Button(action: declineIvitation) {
                        Text("Rechazar")
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                .alertInfo(.invitationRejectingError, show: $isNotAbleToDeleteAlert)
            }
        }
    }
    
    private func getRestaurantInformation() {
        restaurantVM.fetchRestaurant(with: conection.restaurantId) { result in
            switch result {
                case .success(let restaurant): self.restaurant = restaurant; done = true
                case .failure: dataNotObtained = true
            }
        }
    }
    
    private func acceptInvitation() {
        if conection.isAdmin {
            userVM.user.adminRestaurantsIds.append(conection.restaurantId)
            restaurant.adminUsersIds.append(userVM.user.id)
        } else {
            userVM.user.emploRestaurantsIds.append(conection.restaurantId)
            restaurant.emploUsersIds.append(userVM.user.id)
        }
        userVM.save()
        restaurantVM.save(restaurant, isNew: false)
        declineIvitation()
    }
    
    private func declineIvitation() {
        conectionVM.delete(conection) { result in
            switch result {
                case .success:
                    self.presentationMode.wrappedValue.dismiss()
                case .failure:
                    isNotAbleToDeleteAlert = true
            }
        }
        conections.removeAll { conection in
            conection == self.conection
        }
    }
    
    private func userInfo(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
