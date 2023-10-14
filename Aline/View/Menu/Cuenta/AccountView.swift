//
//  Cuenta.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI

struct AccountView: View {
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            UserInformationView()
            NavigationLink(destination: RestaurantsListView()) {
                WhiteArea(spacing: 8) {
                    HStack {
                        Text("Restaurantes").foregroundStyle(Color.text)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }
                }
            }.padding(.vertical, 30)
            ConectionsListView(isLoading: $isLoading)
        }
    }
}
