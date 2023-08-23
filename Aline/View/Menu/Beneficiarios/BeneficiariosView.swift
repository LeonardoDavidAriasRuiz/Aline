//
//  Beneficiarios.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct BeneficiariosView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    var body: some View {
        VStack {
            Text("Hello")
        }
        .onAppear(perform: accentColor.green)
    }
}
