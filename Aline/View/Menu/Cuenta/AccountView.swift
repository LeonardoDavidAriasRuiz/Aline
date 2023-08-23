//
//  Cuenta.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct AccountView: View {
    @State private var isLoading: Bool = false
    
    private var section: MenuSection = .account
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(title: section.title, tint: section.color) {
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
        }
    }
}
