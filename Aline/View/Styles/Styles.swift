//
//  Styles.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct HeaderAreas: ViewModifier {
    private var padding: CGFloat = 10
    private var background: Color = Color.white
    private var cornerRadius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct ButtonColor: ViewModifier {
     let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(Color.white)
    }
}


struct TextFieldSpendings: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .padding(.leading, 10)
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
