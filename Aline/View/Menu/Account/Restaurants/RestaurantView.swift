//
//  RestaurantView.swift
//  Aline
//
//  Created by Leonardo on 07/07/23.
//

import SwiftUI

struct RestaurantView: View {
    @EnvironmentObject private var conectionVM: ConectionViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var restaurantEditable: Restaurant
    
    let restaurant: Restaurant
    
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
                            accion: {RestaurantViewModel().save(restaurantEditable, isNew: false)}
                        ),
                    label: {
                        HStack {
                            Text(nameTitle).foregroundStyle(Color.text)
                            Spacer()
                            Text(restaurantEditable.name).foregroundStyle(Color.text.opacity(0.5))
                            Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                        }.padding(.vertical, 8)
                    }
                )
                Divider()
                NavigationLink(
                    destination:
                        EditableEmail(
                            email: $restaurantEditable.email,
                            accion: {RestaurantViewModel().save(restaurantEditable, isNew: false)}
                        ),
                    label: {
                        HStack {
                            Text(emailTitle).foregroundStyle(Color.text)
                            Spacer()
                            Text(restaurantEditable.email).foregroundStyle(Color.text.opacity(0.5))
                            Image(systemName: "chevron.right").foregroundStyle(Color.text.opacity(0.5))
                        }.padding(.vertical, 8)
                    }
                )
            }
        }
    }
}
