//
//  SalesView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct SalesView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    var body: some View {
        FullSheet(section: .tips) {
            NavigationLink(destination: FiltersView()) {
                WhiteArea {
                    HStack {
                        Text("Filtros").foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.black.secondary)
                    }
                }
            }
        }
        .onAppear(perform: withAnimation{accentColor.green})
    }
}
