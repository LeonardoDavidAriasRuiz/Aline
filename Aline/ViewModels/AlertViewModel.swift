//
//  AlertViewModel.swift
//  Aline
//
//  Created by Leonardo on 08/09/23.
//

import Foundation

class AlertViewModel: ObservableObject {
    @Published var alertType: AlertType = .dataObtainingError
    @Published var alertInfoShowed: Bool = false
    @Published var alertDeleteShowed: Bool = false
    @Published var alertCancelShowed: Bool = false
    @Published var alertDeclineShowed: Bool = false
    @Published var action: () -> Void = {}
    
    func show(_ alertType: AlertType) {
        self.alertType = alertType
        alertInfoShowed = true
    }
    
    func delete(action: () -> Void ) {
        self.action = action
        alertDeleteShowed = true
    }
    
    func cancel(action: () -> Void ) {
        self.action = action
        alertCancelShowed = true
    }
    
    func decline(action: () -> Void ) {
        self.action = action
        alertDeclineShowed = true
    }
}
