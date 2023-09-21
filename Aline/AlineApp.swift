//
//  AlineApp.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import Network

@main
struct AlineApp: App {
    private let userVM = UserViewModel()
    private let restaurantVM = RestaurantViewModel()
    private let employeeVM = EmployeeViewModel()
    private let spendingVM = ExpenseViewModel()
    private let accentColor = AccentColor()
    private let depositVM = DepositViewModel()
    private let conectionVM = ConectionViewModel()
    private let loadingVM = LoadingViewModel()
    private let alertVM = AlertViewModel()
    let restaurantM = RestaurantPickerManager()
    
    @ObservedObject var networkMonitor = NetworkMonitor()
    private let start: Date = Date()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                contentView()
                networkMonitor.isConnected ? nil : NoWifiConected()
            }
            .preferredColorScheme(ColorScheme.light)
        }
    }
    

    private func contentView() -> AnyView {
        return AnyView(
            ContentView()
                .environmentObject(userVM)
                .environmentObject(restaurantVM)
                .environmentObject(employeeVM)
                .environmentObject(spendingVM)
                .environmentObject(accentColor)
                .environmentObject(depositVM)
                .environmentObject(conectionVM)
                .environmentObject(loadingVM)
                .environmentObject(alertVM)
                .environmentObject(restaurantM)
        )
    }
}

struct NoWifiConected: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.white.opacity(0.3))
            Image(systemName: "wifi.slash")
                .symbolEffect(.pulse)
                .foregroundStyle(Color.red)
                .font(.system(size: 350))
        }
    }
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected: Bool = true

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
