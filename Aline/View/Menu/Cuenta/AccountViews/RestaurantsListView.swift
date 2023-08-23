//
//  RestaurantsListView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct RestaurantsListView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var adminRestaurants: [Restaurant] = []
    @State private var emploRestaurants: [Restaurant] = []
    
    @State private var isSheetForNewRestaurantOpened: Bool = false
    @State private var editableRestaurant: Restaurant = Restaurant()
    @State private var updateButtonDisabled: Bool = true
    
    @Binding var done: Bool
    @Binding var dataNotObtained: Bool
    
    var body: some View {
        Sheet(title: "Restaurantes") {
            newRestaurantsButton
            WhiteArea {
                adminRestaurants.isNotEmpty ? adminRestaurantsList : nil
                emploRestaurants.isNotEmpty ? emploRestaurantsList : nil
            }
        }
        .onAppear(perform: getRestaurants)
    }
    
    private var newRestaurantsButton: some View {
        WhiteArea {
            Button(action: toggleEditableRestaurant) {
                Text(isSheetForNewRestaurantOpened ? "Cancelar" : "Nuevo restaurante")
                Spacer()
                Image(systemName: "plus")
                    .font(.title2)
                    .rotationEffect(Angle(degrees: isSheetForNewRestaurantOpened ? 45 : 0))
                    .symbolEffect(.bounce, value: isSheetForNewRestaurantOpened)
            }
            if isSheetForNewRestaurantOpened {
                Divider()
                NavigationLink(destination: EditableName(name: $editableRestaurant.name, accion: {})) {
                    HStack {
                        Text("Nombre").foregroundStyle(.black)
                        Spacer()
                        Text(editableRestaurant.name).foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
                Divider()
                NavigationLink(destination: EditableEmail(email: $editableRestaurant.email, accion: {})) {
                    HStack {
                        Text("Email").foregroundStyle(.black)
                        Spacer()
                        Text(editableRestaurant.name).foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
                Divider()
                Button(action: saveRestaurant) {
                    Text("Guardar").frame(maxWidth: .infinity)
                        .frame(maxWidth: .infinity)
                }
                .disabled(editableRestaurant.name.isEmpty || editableRestaurant.email.isEmpty)
            }
        }
    }
    
    private func saveRestaurant() {
        editableRestaurant.adminUsersIds.append(userVM.user.id)
        userVM.user.adminRestaurantsIds.append(editableRestaurant.id)
        restaurantVM.save(editableRestaurant, isNew: true)
        adminRestaurants.append(editableRestaurant)
        toggleEditableRestaurant()
    }
    
    private func toggleEditableRestaurant() {
        withAnimation {
            isSheetForNewRestaurantOpened.toggle()
            editableRestaurant = Restaurant()
        }
    }
    
    private var adminRestaurantsList: some View {
        VStack {
            ForEach(adminRestaurants) { restaurant in
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(.black)
                        Spacer()
                        Text("Administrador").foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
                Divider()
            }
        }
    }
    
    private var emploRestaurantsList: some View {
        VStack {
            if adminRestaurants.isNotEmpty {
                Divider()
            }
            ForEach(emploRestaurants) { restaurant in
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(.black)
                        Spacer()
                        Text("Limitado").foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
                Divider()
            }
        }
    }
    
    private func getRestaurants() {
        restaurantVM.fetchRestaurants(for: userVM.user.adminRestaurantsIds) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let restaurants):
                        self.adminRestaurants = restaurants
                        done = true
                    case .failure:
                        dataNotObtained = true
                }
            }
        }
        
        restaurantVM.fetchRestaurants(for: userVM.user.emploRestaurantsIds) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let restaurants):
                        self.emploRestaurants = restaurants
                        done = true
                    case .failure:
                        dataNotObtained = true
                }
            }
        }
    }
}
