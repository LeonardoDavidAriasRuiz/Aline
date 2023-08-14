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
    
    @Binding var done: Bool
    @Binding var dataNotObtained: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Header("Restaurantes")
            WhiteArea {
                adminRestaurants.isNotEmpty ? adminRestaurantsList : nil
                emploRestaurants.isNotEmpty ? emploRestaurantsList : nil
                newRestaurantsButton
                    .sheet(isPresented: $isSheetForNewRestaurantOpened) {
                        RestaurantView(restaurant: Restaurant())
                    }
            }
        }
        .onAppear(perform: getRestaurants)
    }
    
    private var newRestaurantArea: some View {
        Sheet(title: "Nuevo Restaurante") {
            VStack(alignment: .leading) {
                newRestaurantAreaTitle
                nameTextField
                saveButton
                cancelButton
            }
        }
    }
    
    private var newRestaurantAreaTitle: some View {
        Text("Nuevo restaurante")
            .bold()
            .font(.largeTitle)
    }
    
    private var nameTextField: some View {
        WhiteArea {
            TextField("Nombre", text: $newRestaurant.name)
                .foregroundStyle(.secondary)
        }
    }
    
    private var saveButton: some View {
        WhiteArea {
            Button(action: {}) {
                Text("Guardar").frame(maxWidth: .infinity)
                    .frame(maxWidth: .infinity)
                    .disabled(updateButtonDisabled)
            }
        }
    }
    
    private var cancelButton: some View {
        WhiteArea {
            Button(action: closeNewRestaurantArea) {
                Text("Cancelar")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var newRestaurantsButton: some View {
        Button(action: openNewRestaurantArea) {
            Text("Nuevo")
        }
    }
    
    private func openNewRestaurantArea() {
        isSheetForNewRestaurantOpened = true
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
