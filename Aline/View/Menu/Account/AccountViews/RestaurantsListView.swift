//
//  RestaurantsListView.swift
//  Aline
//
//  Created by Leonardo on 08/08/23.
//

import SwiftUI

struct RestaurantsListView: View {
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var adminRestaurants: [Restaurant] = []
    @State private var emploRestaurants: [Restaurant] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(section: .resturants, isLoading: $isLoading) {
            WhiteArea {
                adminRestaurants.isNotEmpty ? adminRestaurantsList : nil
                emploRestaurants.isNotEmpty ? emploRestaurantsList : nil
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewRestaurantView())
                UpdateRecordsToolbarButton(action: getRestaurants)
            }
        }
        .overlay { if adminRestaurants.isEmpty, emploRestaurants.isEmpty, !isLoading { EmptyRestaurantsView() } }
        .onAppear(perform: getRestaurants)
    }
    
    private var adminRestaurantsList: some View {
        VStack(spacing: 0) {
            ForEach(adminRestaurants) { restaurant in
                if restaurant != adminRestaurants.first {
                    Divider()
                }
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(Color.text)
                        Spacer()
                        Text("Administrador").foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
            }
        }
    }
    
    private var emploRestaurantsList: some View {
        VStack(spacing: 0) {
            if adminRestaurants.isNotEmpty {
                Divider()
            }
            ForEach(emploRestaurants) { restaurant in
                if restaurant != emploRestaurants.first {
                    Divider()
                }
                NavigationLink(destination: RestaurantView(restaurant: restaurant)) {
                    HStack {
                        Text(restaurant.name).foregroundStyle(Color.text)
                        Spacer()
                        Text("Limitado").foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
            }
        }
    }
    
    private func fetchRestaurants(for ids: [String], completion: @escaping ([Restaurant]) -> Void) {
        RestaurantViewModel().fetchRestaurants(for: ids) { restaurants in
            if let restaurants = restaurants {
                completion(restaurants)
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func getRestaurants() {
        isLoading = true
        fetchRestaurants(for: userVM.user.adminIds) { restaurants in
            adminRestaurants = restaurants
            fetchRestaurants(for: userVM.user.emploIds) { restaurants in
                emploRestaurants = restaurants
                isLoading = false
            }
        }
    }
}
