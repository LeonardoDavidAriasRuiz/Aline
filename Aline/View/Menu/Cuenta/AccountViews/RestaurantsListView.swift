//
//  RestaurantsListView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct RestaurantsListView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var adminRestaurants: [Restaurant] = []
    @State private var emploRestaurants: [Restaurant] = []
    
    @State private var isSheetForNewRestaurantOpened: Bool = false
    @State private var editableRestaurant: Restaurant = Restaurant()
    
    var body: some View {
        Sheet(section: .resturants) {
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
                        Text(editableRestaurant.email).foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
                Divider()
                SaveButton(action: saveRestaurant)
                .disabled(editableRestaurant.name.isEmpty || editableRestaurant.email.isEmpty)
            }
        }
    }
    
    private func saveRestaurant() {
        editableRestaurant.adminUsersIds.append(userVM.user.id)
        userVM.user.adminIds.append(editableRestaurant.id)
        userVM.save()
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
                if restaurant != adminRestaurants.first {
                    Divider()
                }
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(.black)
                        Spacer()
                        Text("Administrador").foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
            }
        }
    }
    
    private var emploRestaurantsList: some View {
        VStack {
            if adminRestaurants.isNotEmpty {
                Divider()
            }
            ForEach(emploRestaurants) { restaurant in
                if restaurant != emploRestaurants.first {
                    Divider()
                }
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(.black)
                        Spacer()
                        Text("Limitado").foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
            }
        }
    }
    
    private func fetchRestaurants(for ids: [String], completion: @escaping ([Restaurant]) -> Void) {
        restaurantVM.fetchRestaurants(for: ids) { restaurants in
            if let restaurants = restaurants {
                completion(restaurants)
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getRestaurants() {
        loading.isLoading = true
        fetchRestaurants(for: userVM.user.adminIds) { restaurants in
            adminRestaurants = restaurants
        }
        fetchRestaurants(for: userVM.user.emploIds) { restaurants in
            emploRestaurants = restaurants
            loading.isLoading = false
        }
    }
}
