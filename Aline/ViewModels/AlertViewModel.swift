//
//  AlertViewModel.swift
//  Aline
//
//  Created by Leonardo on 08/09/23.
//

import Foundation

class AlertViewModel: ObservableObject {
    @Published var alertType: AlertType = .dataObtainingError
    @Published var alertShowed: Bool = false
    
    func show(_ alertType: AlertType) {
        self.alertType = alertType
        alertShowed = true
    }
}
