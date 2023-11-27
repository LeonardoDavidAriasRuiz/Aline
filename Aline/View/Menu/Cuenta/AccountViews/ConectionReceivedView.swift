//
//  ConectionReceivedView.swift
//  Aline
//
//  Created by Leonardo on 02/08/23.
//

import SwiftUI

struct ConectionReceivedView: View {
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var restaurant: Restaurant = Restaurant()
    
    @Binding var conections: [Conection]
    
    let conection: Conection
    
    private let nameText: String = "Nombre"
    private let emailText: String = "Email"
    private let typeText: String = "Tipo"
    private let adminText: String = "Administrador"
    private let emploText: String = "Limitado"
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .conectionReceived, isLoading: $isLoading) {
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
        .onAppear(perform: getRestaurantInformation)
    }
    
    private func getRestaurantInformation() {
        isLoading = true
        RestaurantViewModel().fetchRestaurant(with: conection.restaurantId) { result in
            if let restaurant = result {
                self.restaurant = restaurant
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
    
    private func accept() {
        if conection.isAdmin {
            userVM.user.adminIds.append(conection.restaurantId)
            restaurant.adminUsersIds.append(userVM.user.id)
        } else {
            userVM.user.emploIds.append(conection.restaurantId)
            restaurant.emploUsersIds.append(userVM.user.id)
        }
        userVM.save()
        RestaurantViewModel().save(restaurant, isNew: false)
        decline()
    }
    
    private func decline() {
        isLoading = true
        conectionVM.delete(conection) { deleted in
            if deleted {
                conections.removeAll{ $0 == conection }
                dismiss()
            } else {
                alertVM.show(.deletingError)
            }
            isLoading = false
        }
    }
    
    private func userInfo(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }.padding(.vertical, 8)
    }
}
