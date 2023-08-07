//
//  CashOutView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 05/04/23.
//

import SwiftUI

struct CashOutView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    var body: some View {
        VStack {
            Text("Hello")
        }
        .onAppear(perform: accentColor.red)
    }
}

