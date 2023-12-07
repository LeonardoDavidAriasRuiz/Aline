//
//  ContentView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var content: AnyView = AnyView(iCloudOffView())
    @State private var readyToLogOrSignIn: Bool = false
    @State private var loggedIn: Bool = false
    @State private var signedIn: Bool = false
    @State private var twoSecondsPassed: Bool = false
    @State private var employeedFetched: Bool = false
    
    @State private var error: Bool = false
    
    var body: some View {
        VStack {
            if twoSecondsPassed, restaurantM.adminRts != nil, restaurantM.emploRts != nil, readyToLogOrSignIn {
                content
            } else if twoSecondsPassed, error {
                ZStack {
                    LoadingView()
                    Image(systemName: "icloud.and.arrow.down.fill").font(.system(size: 200)).opacity(0.5)
                    Image(systemName: "xmark").font(.system(size: 200)).opacity(0.5)
                }
            } else {
                LoadingView()
            }
        }
        .tint(accentColor.tint)
        .environmentObject(restaurantM)
        .onAppear(perform: startupProcess)
        .onChange(of: signedIn, checkIfSignedIn)
    }
    
    private func startupProcess() {
        checkIfiCloudUser()
        checkLoadingView()
    }
    
    private func checkLoadingView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            twoSecondsPassed = true
        }
    }
    
    private func checkIfiCloudUser() {
        userVM.checkiCloudUser { isIcloudUser in
            if isIcloudUser {
                print("Si tiene iCloud")
                getUserId()
            } else {
                alertVM.show(.noiCloudConnected)
                content = AnyView(iCloudOffView())
                error = true
            }
        }
    }
    
    private func getUserId() {
        userVM.getUserId { userId in
            if let userId = userId {
                print("Si se obtuvo el Id")
                userVM.user.id = userId
                checkIfLoggedIn()
            } else {
                alertVM.show(.noiCloudConnected)
                content = AnyView(iCloudOffView())
                error = true
            }
        }
    }
    
    private func setRestaurantList() {
        let adminIds = userVM.user.adminIds
        let emploIds = userVM.user.emploIds
        RestaurantViewModel().getRestaurants(adminIds: adminIds, emploIds: emploIds) { adminRts, emploRts in
            if let emploRts = emploRts {
                restaurantM.emploRts = emploRts
                if let restaurant = emploRts.first{
                    restaurantM.restaurant = restaurant
                    restaurantM.currentId = restaurant.id
                    fetchEmployees()
                }
            } else {
            }
            if let adminRts = adminRts {
                restaurantM.adminRts = adminRts
                if let restaurant = adminRts.first {
                    restaurantM.restaurant = restaurant
                    restaurantM.currentId = restaurant.id
                    fetchEmployees()
                }
            }
        }
    }
    
    private func fetchEmployees() {
        employeeVM.fetch(restaurantId: restaurantM.currentId) { fetched in
            if fetched {
                employeedFetched = fetched
            } else {
                alertVM.show(.dataObtainingError)
            }
        }
    }
    
    private func checkIfLoggedIn() {
        userVM.checkIfLoggedIn { loggedIn in
            if loggedIn {
                print("Si tiene sesion")
                setRestaurantList()
                
                content = AnyView(SignInView(signedIn: $signedIn))
            } else {
                print("Se fue a registro")
                content = AnyView(LogInView(loggedIn: $loggedIn))
            }
            readyToLogOrSignIn = true
        }
    }
    
    private func checkIfSignedIn() {
        if signedIn {
            content = AnyView(MenuView())
        }
    }
}


class RestaurantPickerManager: ObservableObject {
    @Published var adminRts: [Restaurant]? = []
    @Published var emploRts: [Restaurant]? = []
    @Published var restaurant: Restaurant?
    @Published var currentId: String = ""
}
