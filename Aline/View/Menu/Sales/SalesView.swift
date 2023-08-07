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
        FullSheet(color: .blue, title: "Ventas") {
            
        }
        .onAppear(perform: withAnimation{accentColor.green})
    }
}
