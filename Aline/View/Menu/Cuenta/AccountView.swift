//
//  Cuenta.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var dataNotObtained: Bool = false
    @State private var done: Bool = false
    
    private let title = "Cuenta"
    private let tint = Color.green
    
    var body: some View {
        LoadingIfNotReady(done: $done) {
            Sheet(title: title) {
                UserInformationView()
                RestaurantsListView(done: $done, dataNotObtained: $dataNotObtained)
                    .padding(.vertical, 30)
                ConectionsListView(done: $done, dataNotObtained: $dataNotObtained)
            }
            .tint(tint)
            .onAppear(perform: accentColor.green)
            .alertInfo(.dataObtainingError, show: $dataNotObtained)
        }
    }
}
