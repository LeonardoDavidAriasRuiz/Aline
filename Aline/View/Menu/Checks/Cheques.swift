//
//  ChecksView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct ChecksView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    var body: some View {
        VStack {
            Text("Hello")
        }
        .onAppear(perform: accentColor.blue)
    }
}
