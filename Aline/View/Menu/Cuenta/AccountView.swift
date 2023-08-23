//
//  Cuenta.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var isLoading: Bool = false
    
    private let title = "Cuenta"
    private let tint = Color.green
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(title: title) {
                UserInformationView()
                NavigationLink(destination: RestaurantsListView()) {
                    WhiteArea {
                        HStack {
                            Text("Restaurantes").foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                        }
                    }
                }
                .padding(.vertical, 30)
                
                ConectionsListView(isLoading: $isLoading)
            }
            .tint(tint)
            .onAppear(perform: accentColor.green)
        }
    }
}
