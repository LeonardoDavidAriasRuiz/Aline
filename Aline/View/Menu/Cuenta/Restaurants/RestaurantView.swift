//
//  RestaurantView.swift
//  Aline
//
//  Created by Leonardo on 07/07/23.
//

import SwiftUI

struct RestaurantView: View {
    
    let restaurant: Restaurant
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var restaurantEditable: Restaurant
    
    private let nameTitle = "Nombre"
    private let emailTitle = "Email"
    private let nameText = "Nombre"
    private let emailText = "correo@ejemplo.com"
    
    init(restaurant: Restaurant) {
        self.restaurantEditable = restaurant
        self.restaurant = restaurant
    }
    
    var body: some View {
        Sheet(section: .restaurant) {
            restauranInfo
            ConectionsView(restaurant: restaurant).padding(.top, 20)
        }
    }
    
    private var restauranInfo: some View {
        VStack(alignment: .leading) {
            WhiteArea {
                NavigationLink(
                    destination:
                        EditableName(
                            name: $restaurantEditable.name,
                            accion: {restaurantVM.save(restaurantEditable, isNew: false)}
                        ),
                    label: {
                        HStack {
                            Text(nameTitle).foregroundStyle(.black)
                            Spacer()
                            Text(restaurantEditable.name).foregroundStyle(.black.opacity(0.5))
                            Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                        }
                    }
                )
                Divider()
                NavigationLink(
                    destination:
                        EditableEmail(
                            email: $restaurantEditable.email,
                            accion: {restaurantVM.save(restaurantEditable, isNew: false)}
                        ),
                    label: {
                        HStack {
                            Text(emailTitle).foregroundStyle(.black)
                            Spacer()
                            Text(restaurantEditable.email).foregroundStyle(.black.opacity(0.5))
                            Image(systemName: "chevron.right").foregroundStyle(.black.opacity(0.5))
                        }
                    }
                )
            }
        }
    }
}
