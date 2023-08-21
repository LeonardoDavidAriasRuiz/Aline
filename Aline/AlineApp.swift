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
    private let monitor = NWPathMonitor()
    private let conectionVM = ConectionViewModel()
    
    @ObservedObject var networkMonitor = NetworkMonitor()
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var count: Int = 0
    @State private var step: Int = 0
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if count > 2 {
                    ContentView()
                        .environmentObject(userVM)
                        .environmentObject(restaurantVM)
                        .environmentObject(employeeVM)
                        .environmentObject(spendingVM)
                        .environmentObject(accentColor)
                        .environmentObject(depositVM)
                        .environmentObject(conectionVM)
                } else {
                    LoadingView()
                        .onReceive(timer, perform: { _ in
                            step = step == 10 ? 0 : step+1
                            if step == 10 {
                                count += 1
                            }
                        })
                }
                if !networkMonitor.isConnected {
                    NoWifiConected()
                }
            }.preferredColorScheme(ColorScheme.light)
        }
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
    let queue = DispatchQueue(label: "Monitor")
    
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
