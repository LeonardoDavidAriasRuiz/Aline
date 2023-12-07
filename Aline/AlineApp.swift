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
    private let spendingVM = SpendingViewModel()
    private let accentColor = AccentColor()
    private let conectionVM = ConectionViewModel()
    @State private var alertVM = AlertViewModel()
    let employeeVM = EmployeeViewModel()
    private let restaurantM = RestaurantPickerManager()
    
    @ObservedObject private var networkMonitor = NetworkMonitor()
    private let start: Date = Date()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                contentView().alertInfo(alertVM.alertType, showed: $alertVM.alertInfoShowed)
                networkMonitor.isConnected ? nil : NoWifiConected()
            }
        }
    }
    

    private func contentView() -> AnyView {
        return AnyView(
            ContentView()
                .environmentObject(userVM)
                .environmentObject(spendingVM)
                .environmentObject(accentColor)
                .environmentObject(conectionVM)
                .environmentObject(employeeVM)
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
            Image(systemName: "wifi")
                .symbolEffect(.variableColor.iterative.dimInactiveLayers.reversing)
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
