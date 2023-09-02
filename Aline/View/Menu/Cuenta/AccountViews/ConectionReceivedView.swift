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
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = .dataObtainingError
    @State private var isLoading: Bool = false
    
    @Binding var conections: [Conection]
    
    let conection: Conection
    
    private let nameText: String = "Nombre"
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(section: .conectionReceived) {
                WhiteArea {
                    userInfo(title: nameText, value: restaurant.name)
                    Divider()
                    userInfo(title: emailText, value: restaurant.email.isNotEmpty ? restaurant.email : "---")
                    Divider()
                    userInfo(title: typeText, value: conection.isAdmin ? adminText : emploText)
                }
                
                AcceptButtonWhite(action: accept)
                DeclineButtonWhite(action: decline)
            }
        }
        .onAppear(perform: getRestaurantInformation)
        .alertInfo(alertType, showed: $alertShowed)
    }
    
    private func getRestaurantInformation() {
        restaurantVM.fetchRestaurant(with: conection.restaurantId) { result in
            if let restaurant = result {
                self.restaurant = restaurant
            } else {
                alertType = .dataObtainingError
                alertShowed = true
            }
            isLoading = false
        }
    }
    
    private func accept() {
        if conection.isAdmin {
            userVM.user.adminRestaurantsIds.append(conection.restaurantId)
            restaurant.adminUsersIds.append(userVM.user.id)
        } else {
            userVM.user.emploRestaurantsIds.append(conection.restaurantId)
            restaurant.emploUsersIds.append(userVM.user.id)
        }
        userVM.save()
        restaurantVM.save(restaurant, isNew: false)
        decline()
    }
    
    private func decline() {
        isLoading = true
        conectionVM.delete(conection) { result in
            switch result {
                case .success:
                    isLoading = false
                    conections.removeAll { $0 == conection}
                    self.presentationMode.wrappedValue.dismiss()
                case .failure:
                    isLoading = false
                    alertType = .decliningError
                    alertShowed = true
            }
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
