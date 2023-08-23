//
//  ContentView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    
    @State private var dataNotObtained: Bool = false
    
    var body: some View {
        VStack {
            if !dataNotObtained {
                switch userVM.loginStatus {
                    case .iCloudOff: iCloudOffView()
                    case .iCLoudOn: LogInView()
                    case .loggedIn: SignInView()
                    case .signedIn: MenuView()
                }
            } else {
                LoadingView()
            }
        }
        .tint(accentColor.tint)
        .onAppear(perform: setRestaurantList)
    }
    
    private func setRestaurantList() {
        let adminRestaurantsIds = userVM.user.adminRestaurantsIds
        let emploRestaurantsIds = userVM.user.emploRestaurantsIds
        restaurantVM.getRestaurants(
            adminRestaurantsIds: adminRestaurantsIds,
            emploRestaurantsIds: emploRestaurantsIds
        )
    }
}

