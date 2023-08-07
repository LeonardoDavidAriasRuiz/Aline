//
//  RestaurantsView.swift
//  Aline
//
//  Created by Leonardo on 28/06/23.
//

import SwiftUI

 enum RestaurantType: String {
    case admin = "Administrativos"
    case emplo = "Corte"
}

struct RestaurantsView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var restaurants: [Restaurant] = []
    @State private var editableRestaurant: Restaurant = Restaurant()
    @State private var dataNotObtained: Bool = false
    @State private var done: Bool = false
    @State private var isNuevoPressed: Bool = false
    @State private var nameValidated: Bool = false
    
    let type: RestaurantType
    
    var body: some View {
        LoadingIfNotReady(done: $done) {
            Sheet(title: type.rawValue) {
                if restaurants.isNotEmpty {
                    restaurantsListArea
                } else {
                    noRestaurantsFoundArea
                }
                type == .admin ? newRestaurantArea : nil
            }
        }
        .alert("No se pudieron obtener los datos.", isPresented: $dataNotObtained, actions: {})
        .onAppear(perform: fetchRestaurants)
    }
    
    private var noRestaurantsFoundArea: some View {
        WhiteArea {
            HStack {
                Text("No se encontraron restaurantes")
                Spacer()
            }
        }
    }
    
    private var restaurantsListArea: some View {
        WhiteArea {
            ForEach(restaurants, id: \.self) { restaurant in
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.foregroundStyle(Color.green)
                }
                if restaurant != restaurants.last {
                    Divider()
                }
            }
        }
    }
    
    private var newRestaurantArea: some View {
        HStack {
            Button(
                action: toggleNewRestaurantArea,
                label: {
                    Image(systemName: isNuevoPressed ? "trash.fill" : "circle.badge.plus")
                        .symbolEffect(.bounce, value: isNuevoPressed)
                }
            )
            if isNuevoPressed {
                TextField("Nombre del nuevo restaurante", text: $editableRestaurant.name)
                    .padding(5)
                    .background(.white)
                    .foregroundStyle(.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
            }
            if nameValidated {
                Button("Guardar", action: createRestaurant)
            }
            if !isNuevoPressed {
                Button("Nuevo", action: toggleNewRestaurantArea)
            }
        }
        .modifier(ButtonColor(color: isNuevoPressed ? (nameValidated ? Color.green : Color.red) : Color.blue))
        .onChange(of: editableRestaurant.name, nameValidation)
    }
    
    private func createRestaurant() {
        withAnimation {
            let userId: String = userVM.user.id
            let restaurantId: String = editableRestaurant.id
            
            editableRestaurant.adminUsersIds.append(userId)
            userVM.user.adminRestaurantsIds.append(restaurantId)
            
            restaurantVM.save(editableRestaurant, isNew: true)
            userVM.save()
            
            restaurants.append(editableRestaurant)
            restaurantVM.adminRestaurants.append(editableRestaurant)
            toggleNewRestaurantArea()
        }
    }
    
    private func nameValidation() {
        withAnimation {
            nameValidated = !editableRestaurant.name.isEmpty
        }
    }
    
    private func toggleNewRestaurantArea() {
        withAnimation {
            isNuevoPressed.toggle()
            if isNuevoPressed == false {
                editableRestaurant = Restaurant()
            }
        }
    }
    
    private func fetchRestaurants() {
        var restaurantIds: [String]
        
        switch type {
            case .admin: restaurantIds = userVM.user.adminRestaurantsIds
            case .emplo: restaurantIds = userVM.user.emploRestaurantsIds
        }
        
        self.restaurantVM.fetchRestaurants(for: restaurantIds) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let restaurants):
                        self.restaurants = restaurants
                        done = true
                    case .failure:
                        dataNotObtained = true
                }
            }
        }
    }
}
