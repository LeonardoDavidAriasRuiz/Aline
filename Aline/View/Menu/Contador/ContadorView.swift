//
//  Contador.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct ContadorView: View {
    
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var contador = Contador()
    
    var body: some View {
        VStack {
            contadorArea
            messageArea
        }
        .onAppear(perform: accentColor.blue)
    }
    
    private var messageArea: some View {
        TextEditor(text: $contador.message)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.top, 10)
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
    }
    
    private var contadorArea: some View {
        HStack {
            TextField("Nombre", text: $contador.name)
                .modifier(HeaderAreas())
                .padding(.leading, 20)
            TextField("Email", text: $contador.email)
                .modifier(HeaderAreas())
                .padding(.horizontal, 10)
            Button("Actualizar", action: {})
                .modifier(HeaderAreas())
                .padding(.trailing, 20)
        }
    }
}
